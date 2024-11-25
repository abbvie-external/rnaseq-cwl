import json
import logging
import pprint
import subprocess
import sys
import time

from copy import deepcopy
from pathlib import Path
from typing import Union

import arvados

from .create_jobs import create_incremented_job
from .util import get_last_n_line


def all_outputs_exist(stdout_data: dict, outputs: list) -> bool:
    logging.info(f'all_outputs_exist()')
    logging.info(f'stdout_data:')
    logging.info(pprint.pformat(stdout_data))
    logging.info('outputs:')
    logging.info((pprint.pformat(outputs)))
    outputs_exist = True
    for output in outputs:
        logging.info(f'output: {output}')
        if output in stdout_data and stdout_data[output] is not None:
            logging.info(f'outputs_exist: {outputs_exist}')
            logging.info(f'stdout_data[output]: {stdout_data[output]}')
        else:
            outputs_exist &= False
            logging.info(f'outputs_exist: {outputs_exist}')
    logging.info(f'final outputs_exist: {outputs_exist}')
    return outputs_exist


def query_slurm_state(job_id: int) -> Union[str, None]:
    cmd = ["sacct", "--format", "State", "-j", str(job_id)]
    res = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    lines = list()
    for line in res.stdout:
        newline = line.strip().decode('utf-8').rstrip('+')
        logging.debug(f'newline: {newline}')
        lines.append(newline)
    logging.debug(f'lines: {lines}')
    logging.debug(pprint.pformat(lines))
    if len(lines) < 3:
        job_state = None
    else:
        job_state = lines[2]
        logging.debug(f'job_state: {job_state}')
    return job_state


def get_slurm_status(job: dict) -> dict:
    running_states = [
        'PENDING',
        'REQUEUED',
        'RESIZING',
        'RUNNING',
        'SUSPENDED'
    ]

    complete_states = [
        'COMPLETE',
        'COMPLETED'
    ]

    canceled_states = [
        'CANCELLED',
    ]

    failed_states = [
        'BOOT_FAIL',
        'DEADLINE',
        'END',
        'FAILED',
        'NODE_FAIL',
        'OOM',
        'OUT_OF_MEMORY',
        'PREEMPTED',
        'REVOKED',
        'TIMEOUT',
    ]

    job_status = None
    slurm_job_id = None
    if job['slurm_job_id'] is not None:
        slurm_job_id = job['slurm_job_id']
    elif job['slurm_job_id_file'].exists():
        with open(job['slurm_job_id_file']) as f:
            slurm_job_id = int(f.readline())
    if slurm_job_id is not None:
        job_status = query_slurm_state(slurm_job_id)
        if job_status is None:
            SLP = 7
            while job_status is None:
                time.sleep(SLP)
                job_status = query_slurm_state(slurm_job_id)
        if job_status in failed_states:
            job['status'] = 'failed'
        elif job_status in running_states:
            job['status'] = 'running'
        elif job_status in complete_states:
            job['status'] = 'complete'
        elif job_status in canceled_states:
            job['status'] = 'canceled'
    return job


def get_arv_status(job: dict, arv_client: dict = {}) -> dict:
    logging.debug(f'\tjob name: {job["name"]}')
    logging.debug(f"\tjob cr uuid: {job['parameters_arvados']['containerrequest_uuid']}")
    if job['parameters_arvados']['containerrequest_uuid'] is not None:
        cr_uuid = job['parameters_arvados']['containerrequest_uuid']
    elif job['cwl_stdout'].exists():
        logging.debug(f'\tjob cwl_stdout: {job["cwl_stdout"]}')
        with open(job['cwl_stdout'], 'r') as f_open:
            cr_uuid = f_open.readline().strip()
        job['parameters_arvados']['containerrequest_uuid'] = cr_uuid
    else:
        logging.debug(f'returning job: {job["name"]} without API check')
        return job

    if job['name'] == job['project_name']+'.project':
        logging.debug(f'cohort_containerrequest_uuid: {cr_uuid}')
    else:
        logging.debug(f'sample_containerrequest_uuid: {cr_uuid}')
    container_request = arv_client.container_requests().get(uuid=cr_uuid,).execute()
    # logging.debug(f'container_request: {container_request}')
    if container_request['container_uuid'] is None:
        job['status'] = container_request['state']
        logging.debug(f'NO container_uuid: job status: {job["status"]}')
    else:
        container = arv_client.containers().get(uuid=container_request['container_uuid'],).execute()
        container_state = container['state']
        logging.debug(f'container_state: {container_state}')
        if container_state == 'Queued' or container_state == 'Locked':
            job['status'] = 'running'
        elif container_state == 'Running':
            if container['runtime_status'].get('error'):
                job['status'] = "failed"
            elif container['runtime_status'].get('warning'):
                job['status'] = "running"
            else:
                job['status'] = 'running'
        elif container_state == 'Cancelled':
            job['status'] = 'canceled'
        elif container_state == 'Complete':
            if container['exit_code'] == 0:
                job['status'] = 'complete'
                logging.debug(f'job status: {job["status"]}')
            else:
                job['status'] = "failed"
    if job['status'] == 'complete':
        if not arv_outputs_exist(job, arv_client):
            job['status'] = 'failed'
    return job


def arv_outputs_exist(job: dict, arv_client: dict) -> bool:
    cwl_container_request = arv_client.container_requests().get(uuid=job['parameters_arvados']['containerrequest_uuid'],).execute()
    cwl_output_collection = arvados.collection.Collection(cwl_container_request['output_uuid'],)
    with cwl_output_collection.open('cwl.output.json') as cwl_output_file:
        cwl_output = json.load(cwl_output_file)
    logging.info(f'cwl_output: {cwl_output}')
    outputs_exist = all_outputs_exist(cwl_output, job['output_keys'])
    return outputs_exist
    
def get_local_job_status(job: dict) -> dict:
    if job['cwl_stdout'].exists() and (job['cwl_stdout'].stat().st_size > 0):
        with open(job['cwl_stdout'], 'r') as f_open:
            stdout_data = json.load(f_open)
            outputs_exist = all_outputs_exist(stdout_data, job['outputs'])
            if outputs_exist:
                job['status'] = complete
    return job


def get_jobs_status(jobs: list, arv_client: dict) -> list:
    status_jobs = list()
    for status_job in list(jobs):
        job = deepcopy(status_job)
        logging.debug(f'job name: {job["name"]}')
        if job['machine_type'] == 'arvados' and job['cwl_stdout'].exists():
            status_jobs.append(get_arv_status(job, arv_client))
        elif job['machine_type'] == 'slurm' and job['cwl_stdout'].exists():
            status_jobs.append(get_slurm_status(job))
        else:
            status_jobs.append(job)
    return status_jobs

def wait_jobs_complete(jobs: list, arv_client: dict) -> list:
    '''
    wait for completion of all jobs
    '''
    SLP = 47
    all_done = False
    submit_time = 0
    init_job_count = len(jobs)

    while not all_done:
        canceled_job_set = set()
        complete_job_set = set()
        running_job_set = set()
        failed_job_set = set()
        removed_job_set = set()

        for i, job in enumerate(jobs):
            logging.debug(f'\n\ni={i} job name: {job["name"]}')
            if job['status'] == 'complete':
                complete_job_set.add(job['cwl_job'])
                continue
            if job['machine_type'] == 'arvados':
                logging.debug(f'pre-check job status: {job["status"]}')
                job = get_arv_status(job, arv_client)
                logging.debug(f'post-check job status: {job["status"]}')
            elif job['machine_type'] == 'slurm':
                job = get_slurm_status(job)
            if job['status'] == 'canceled':
                canceled_job_set.add(job['cwl_job'])
                sys.exit(1)
            elif job['status'] == 'complete':
                complete_job_set.add(job['cwl_job'])
            elif job['status'] == 'running':
                running_job_set.add(job['cwl_job'])
            elif job['status'] == 'failed':                
                if (job['try_count_current'] > job['try_count_max']) and job['remove_failed_samples']:
                    logging.error(f'removing failed job: {job["name"]}')
                    logging.error(f'reached try_count_max: {job["try_count_max"]}')
                    job['status'] = 'removed' 
                    removed_job_set.add(job['cwl_job'])
                else:
                    failed_job_set.add(job['cwl_job'])
            logging.info(f'\n\njob_name: {job["name"]} status is {job["status"]}')
                    

            if job['status'] == 'failed':
                if job['cwl_stdout'].exists():
                    logging.error(f'cwl_stdout message last 50 lines: {get_last_n_line(job["cwl_stdout"], False, 50)}')
                if job['cwl_stderr'].exists():
                    logging.error(f'cwlstderr message last 50 lines: {get_last_n_line(job["cwl_stderr"], False, 50)}')
                
                job = create_incremented_job(job)
                from .run_jobs import do_jobs
                retry_jobs = do_jobs([job], arv_client)
                jobs[i] = retry_jobs[0]
            elif job['status'] == 'complete':
                logging.debug(f'job: {job["name"]} completed')
                if not job['keep_cache']:
                    logging.info(f'deleting job: {job["name"]} cache')
                    from .run_jobs import delete_job_cache
                    delete_job_cache(job)

        logging.info('\n\n')
        logging.info('current project status')
        logging.info('----------------------')
        logging.info(f'complete samples: {len(complete_job_set)}')
        logging.info(f'running samples: {len(running_job_set)}')
        logging.info(f'failed samples: {len(failed_job_set)}')
        logging.info(f'removed samples: {len(removed_job_set)}')
        logging.info(f'time since submission: {submit_time} seconds')
        if (len(complete_job_set) + len(removed_job_set)) == init_job_count:
            logging.info('workflow complete')
            all_done = True
        else:
            logging.info(f'sleep {SLP} seconds')
            time.sleep(SLP)
            logging.info('done sleeping')
            submit_time += SLP
    return jobs
