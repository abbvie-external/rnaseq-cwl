#!/usr/bin/env python3

import concurrent.futures
import getpass
import itertools
import json
import logging
import os
from copy import deepcopy
from pathlib import Path
import pprint
import shlex
import shutil
import subprocess
import sys
import time

import arvados
import ruamel

from .util import get_last_n_line
from .status_jobs import get_jobs_status, wait_jobs_complete

def delete_job_cache(job: dict) -> None:
    shutil.rmtree(job['cwl_cachedir'], ignore_errors=True)
    shutil.rmtree(job['cwl_tmpdir'], ignore_errors=True)
    return

def do_arvados_job(job: dict, arv_client: dict) -> dict:
    cmd = ['arvados-cwl-runner']
    params = job['parameters_arvados']
    if params.get('collection_cache_size', 0) != 0:
        cmd.append('--collection-cache-size')
        cmd.append(str(params['collection_cache_size']))
    if params.get('copy_deps', False):
        cmd.append('--copy-deps')
    if params.get('enable_preemptible', False):
        cmd.append('--enable-preemptible')
    if params.get('eval_timeout', 0) != 0:
        cmd.append('--eval-timeout')
        cmd.append(str(params['eval_timeout']))
    if params.get('debug', False):
        cmd.append('--debug')
    if params.get('defer_downloads', False):
        cmd.append('--defer-downloads')
    if params.get('disable_preemptible', False):
        cmd.append('--disable-preemptible')
    if params.get('disable_reuse', False):
        cmd.append('--disable-reuse')
    if params.get('http_timeout', 0) != 0:
        cmd.append('--http-timeout')
        cmd.append(str(params['http_timeout']))
    if params.get('log_timestamps', False):
        cmd.append('--log-timestamps')
    if params.get('metrics', False):
        cmd.append('--metrics')
    if params.get('no_copy_deps', False):
        cmd.append('--no-copy-deps')
    if params.get('no_log_timestamps', False):
        cmd.append('--no-log-timestamps')
    if params.get('no_wait', False):
        cmd.append('--no-wait')
    if params.get('prefer_cached_downloads', False):
        cmd.append('--prefer-cached-downloads')
    if params.get('priority', 0) != 0:
        cmd.append('--priority')
        cmd.append(str(params['priority']))
    if params.get('project_uuid', 0) != '0':
        cmd.append('--project-uuid')
        cmd.append(params['project_uuid'])
    if params.get('intermediate_output_ttl', 0) != 0:
        cmd.append('--intermediate-output-ttl')
        cmd.append(str(params['trashintermediate_ttl']))
    if params.get('skip_schemas', 0):
        cmd.append('--skip-schemas')
    if params.get('thread_count', 0) != 0:
        cmd.append('--thread-count')
        cmd.append(str(params['thread_count']))
    if params.get('trash_intermediate', False):
        cmd.append('--trash-intermediate')

    cmd.append('--name')
    cmd.append(job['name']+'_'+str(job['try_count_current']))
    cmd.append('--output-name')
    cmd.append('Output_'+job['name']+'_'+str(job['try_count_current']))
    cmd.append(params['workflow_uuid'])
    cmd.append(str(job['cwl_job']))

    logging.info(f'cmd: {cmd}')
    job['cwl_stdout'].parent.mkdir(parents=True, exist_ok=True)
    job['cwl_stderr'].parent.mkdir(parents=True, exist_ok=True)
    with job['cwl_stdout'].open(mode='w') as f_out:
        with job['cwl_stderr'].open(mode='w') as f_err:
            try:
                res = subprocess.run(cmd, stdout=f_out,stderr=f_err, shell=False)
            except Exception as e:
                logging.error(f'\n\nFAILED job: {cmd}')
                logging.debug(f'res: {res}')
                logging.error(f'Last 50 lines of the standard error file {job["cwl_stderr"]}:{pprint.pformat(get_last_n_line(job["cwl_stderr"], False, 50))}')
                logging.error(f'exception: {e}')
                sys.exit(1)
            if res.returncode != 0:
                logging.error(f'\n\nFAILED job: {cmd}')
                logging.debug(f'res: {res}')
                logging.error(f'Last 50 lines of the standard error file {job["cwl_stderr"]}:{pprint.pformat(get_last_n_line(job["cwl_stderr"], False, 50))}')
                sys.exit(1)
    with open(job['cwl_stdout'], 'r') as f_out:
        cr_uuid = f_out.readline().strip('\n')
        job['parameters_arvados']['containerrequest_uuid'] = cr_uuid
    return job

def do_local_job(job: dict) -> dict:
    ## TODO CHECK FOR STATUS
    if job['status'] in ('complete', 'running'):
        return job

    if not job['use_existing_job']:
        delete_job_cache(job)

    job['cwl_stdout'].parent.mkdir(parents=True, exist_ok=True)
    job['cwl_stderr'].parent.mkdir(parents=True, exist_ok=True)
    condadir = Path(str(sys.exec_prefix))
    condarc = Path(condadir.parent.parent, 'etc', 'profile.d', 'conda.sh')
    activate_conda_cmd = ['.', str(condarc), '&&',
           'conda', 'activate', job['conda_env_name'], '&&']
    engine_cmd = ['cwltool',
           '--debug',
           '--timestamps']
    if job['container'] == 'singularity':
        engine_cmd.append('--'+job['container'])
    job_cmd = ['--tmpdir-prefix', str(job['cwl_tmpdir'])+os.sep,
               '--cachedir', str(job['cwl_cachedir'])+os.sep,
               '--outdir', str(job['cwl_outdir'])+os.sep,
               str(job['cwl_workflow']),
               str(job['cwl_job'])]
    cmd = activate_conda_cmd + engine_cmd + job_cmd
    logging.info(f'cmd: {cmd}')
    cmd_str = ' '.join(cmd)
    logging.info(f'cmd_str: {cmd_str}')

    with job['cwl_stdout'].open(mode='w') as f_out:
        with job['cwl_stderr'].open(mode='w') as f_err:
            try:
                res = subprocess.run(cmd_str, stdout=f_out,stderr=f_err, shell=True)
            except Exception as e:
                logging.error(f'FAILED job {cmd}')
                logging.error(f'Last 50 lines of the standard error file {job["cwl_stderr"]}:{pprint.pformat(get_last_n_line(job["cwl_stderr"], False, 50))}')
                logging.error(sys.exc_info()[0])
                logging.error(f'exception: {e}')
                sys.exit(1)

    if res.returncode != 0:
        logging.info(f'retry {cmd}')
        for i in range(job['try_count_current'],job['try_count_max']):
            job['try_count_current'] += 1
            job['cwl_stderr'] = Path(job['local_workdir'], job['name'] + '.' + str(job['try_count_current']) + '.stderr')
            with job['cwl_stdout'].open(mode='w') as f_out:
                with job['cwl_stderr'].open(mode='w') as f_err:
                    try:
                        res = subprocess.run(cmd_str, stdout=f_out,stderr=f_err, shell=True)
                    except Exception as e:
                        logging.error(f'FAILED job {cmd} on TRY, {i + 1}')
                        logging.error(
                            f'Last 50 lines of the standard error file {job["cwl_stderr"]}:{pprint.pformat(get_last_n_line(job["cwl_stderr"], False, 50))}')
                        if i > retry_count:
                            logging.error(f'exception: {e}')
                            logging.error('no more retries')
                            sys.exit(1)
                    if res.returncode == 0:
                        job['status'] = 'complete'
                    else:
                        logging.error(f'FAILED job {cmd} on TRY {i + 1}')
                        logging.error(
                            f'Last 50 lines of the standard error file {job["cwl_stderr"]}:{pprint.pformat(get_last_n_line(job["cwl_stderr"], False, 50))}')
                        if i == retry_count-1:
                            logging.error(f'exception: {e}')
                            logging.error('no more retries')
                            sys.exit(1)
    if not job['keep_cache']:
        delete_job_cache(job)
    return job

def do_slurm_job(job: dict) -> dict:
    if not job['use_existing_job']:
       delete_job_cache(job)
    cmd = ['sbatch', job['slurm_job']]
    logging.info(f'submitting job: {job["name"]}')
    logging.info(f'cmd: {cmd}')
    res = subprocess.run(cmd,stdout=subprocess.PIPE)
    logging.debug(f'res: {res}')
    logging.debug(f'res.stdout: {res.stdout}')
    job_id_str = res.stdout.decode("utf-8").strip()
    if not job_id_str.startswith(''):
        logging.error(f'not able to sbatch a job: {job_path}')
        sys.exit(1)
    job['slurm_job_id'] = int(job_id_str.split(' ')[-1])
    job['slurm_job_id_file'].parent.mkdir(exist_ok=True, parents=True)
    with open(job['slurm_job_id_file'], 'w') as f_write:
        f_write.write(str(job['slurm_job_id']))
    job['slurm_stdout'] = Path(job['cwl_jobdir'], 'slurm-' + str(job['slurm_job_id']) + '.out')
    return job

def check_any_arv_jobs(jobs: dict) -> bool:
    '''
    check if any of the jobs have machine_type arvados
    '''
    any_arv_jobs = False
    for job in jobs:
        if job['machine_type'] == 'arvados':
            any_arv_jobs = True
            break
    return any_arv_jobs

def do_jobs(jobs: list, arv_client: dict) -> list:
    '''
    run all jobs that aren't running or complete
    '''
    run_jobs = list()
    for job in list(jobs):
        run_job = deepcopy(job)
        logging.debug(f'job: name={job["name"]} cr_uuid={job["parameters_arvados"]["containerrequest_uuid"]}')
        logging.debug(f'run_job: name={run_job["name"]} cr_uuid={run_job["parameters_arvados"]["containerrequest_uuid"]}\n\n')
        if job['status'] not in ('complete', 'running'):
            if job['machine_type'] == 'slurm':
                run_jobs.append(do_slurm_job(run_job))
            elif job['machine_type'] == 'arvados':
                run_jobs.append(do_arvados_job(run_job, arv_client))
            else:
                logging.error(f'unknown machine_type: {job["machine_type"]}')
                sys.exit(1)
        else:
            run_jobs.append(run_job)
    for i in range(len(run_jobs)):
        logging.debug(f'run_jobs[i] i={i} name: {run_jobs[i]["name"]} cr_uuid: {run_jobs[i]["parameters_arvados"]["containerrequest_uuid"]}')
    return run_jobs

def run_jobs(jobs: list) -> list:
    '''
    any any jobs that aren't running or complete, and wait for completion
    '''

    any_arv_jobs = check_any_arv_jobs(jobs)
    if any_arv_jobs:
        arv_client = arvados.api('v1', ...)
    else:
        arv_client = None
    if jobs[0]['machine_type'] != 'single':
        jobs = get_jobs_status(jobs, arv_client)
        jobs = do_jobs(jobs, arv_client)
        jobs = wait_jobs_complete(jobs, arv_client)
    elif jobs[0]['machine_type'] == 'single':
        jobs_complete = dict()
        for job in jobs:
            logging.info(f'job: {job}')
        if len(jobs) == 1:
            job = do_local_job(jobs[0])
            jobs[0] = job
        else:
            res_jobs = list()
            with concurrent.futures.ProcessPoolExecutor(max_workers=job['concurrent_jobs']) as executor:
                futures = {
                    executor.submit(do_local_job, job)
                    for i, job in enumerate(jobs)
                }

                for fut in concurrent.futures.as_completed(futures):
                    res_jobs.append(fut.result())
            jobs = res_jobs
        import time
        time.sleep(37)
    logging.debug('\n\njobs:')
    logging.debug(pprint.pformat(jobs))
    return jobs
