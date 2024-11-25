import getpass
import json
import logging
import os
from pathlib import Path
import pprint
import sys
import uuid

import arvados
from ruamel.yaml import YAML

def any_arvados_machines(jobs_meta) -> bool:
    '''
    determine if any jobs have machine_type arvados
    '''
    any_arvados = False
    for job in jobs_meta:
        if job['machine_type'] == 'arvados':
            any_arvados = True
            break
    return any_arvados

def write_cwl_job(job: dict) -> None:
    yaml = YAML()
    yaml.indent(sequence=4, offset=2)
    job['cwl_job'].parent.mkdir(parents=True,exist_ok=True)
    with open(job['cwl_job'], 'w') as f_write:
        documents = yaml.dump(job['cwl_data'], f_write)
    if job['machine_type'] == 'slurm':
        create_slurm_job(job)
    return

def get_arv_workflow_uuid(cwl_workflow_name: str) -> str:
    workflow_uuid_dict = Path(Path(__file__).parent, 'static_files', 'yml_files', 'arvados_workflow_uuid.yml')
    yaml = YAML()
    with open(workflow_uuid_dict, 'r') as f_open:
        workflow_uuid_data = yaml.load(f_open)
    workflow_uuid = workflow_uuid_data[cwl_workflow_name]
    return workflow_uuid

def get_cwl_vals(cwl_out_list: list, cwl_item: str) -> list:
    logging.info(f'cwl_out_list: {cwl_out_list}')
    logging.info(f'cwl_item: {cwl_item}')
    cwl_path_list = list()
    for cwl_out in cwl_out_list:
        logging.info(f'cwl_out: {cwl_out}')
        with open(cwl_out, 'r') as f_open:
            cwl_stdout_data = json.load(f_open)
        cwl_val = cwl_stdout_data[cwl_item]
        logging.info(f'cwl_val: {cwl_val}')
        cwl_path_list.append(cwl_val)
    return cwl_path_list

def include_ui_parameters(job: dict, ui_parameters: dict) -> dict:
    for parameter in sorted(list(ui_parameters.keys())):
        if not parameter in job:
            job[parameter] = dict()
        job[parameter] = ui_parameters[parameter]
    return job

def create_job(job_name: str, species: list, job_dir: Path, out_dir: Path, work_dir: Path,
               keep_cache: bool,  machine_type: str, concurrent_jobs: int, thread_count: int, container: str,
               try_count_max: int, use_existing_job: bool, job_outputs: list, singularity_dir: Path,
               slurm_partition: str, slurm_template: Path, slurm_resource_mem: int, slurm_timeout_hours: int,
               conda_env_name: str, project_name: str, cwl_workflow: Path, cwl_workflow_name: str,
               ui_parameters: dict, remove_failed_samples: bool, decoys: list, arvados_disable_reuse: bool) -> dict:
    
    arvados_workflow_uuid = get_arv_workflow_uuid(cwl_workflow_name)
    job = dict()
    job = include_ui_parameters(job, ui_parameters)
    job['parameters_arvados']['workflow_uuid'] = arvados_workflow_uuid
    job['parameters_arvados']['containerrequest_uuid'] = None
    job['parameters_arvados']['disable_reuse'] = arvados_disable_reuse
    TRY_COUNT_CURRENT = 1
    job['conda_env_name'] = conda_env_name
    job['concurrent_jobs'] = concurrent_jobs
    job['container'] = container
    job['cwl_engine'] = cwl_engine_path = Path(Path(sys.executable).parent, 'cwltool')
    job['cwl_cachedir'] = Path(work_dir, job_name, 'cachedir')
    job['cwl_data'] = dict()
    job['cwl_job'] = Path(job_dir, job_name + '.yml')
    job['cwl_jobdir'] = job_dir
    job['cwl_outdir'] = out_dir
    job['cwl_outputs'] = dict()
    job['cwl_tmpdir'] = Path(work_dir, job_name, 'tmp')
    job['cwl_stderr'] = Path(work_dir, job_name + '.' + str(TRY_COUNT_CURRENT) + '.err')
    job['cwl_stdout'] = Path(work_dir, job_name + '.out')
    job['cwl_workflow'] = cwl_workflow
    job['cwl_workflow_name'] = cwl_workflow_name
    job['decoys'] = sorted(decoys)
    job['keep_cache'] = keep_cache
    job['local_workdir'] = Path(work_dir, job_name)
    job['name'] = job_name
    job['machine_type'] = machine_type
    job['project_name'] = project_name
    job['output_keys'] = job_outputs
    job['remove_failed_samples'] = remove_failed_samples
    job['required_outputs'] = None
    job['run_uuid'] = str(uuid.uuid3(namespace=uuid.NAMESPACE_URL,name='abbvie.com'))
    job['singularity_dir'] = singularity_dir
    job['sample_yml'] = None
    job['slurm_job'] =  Path(job_dir, job_name + '.' + str(TRY_COUNT_CURRENT) + '.sh')
    job['slurm_job_id'] = None
    job['slurm_job_id_file'] = Path(work_dir, job_name + '.slurm.id')
    job['slurm_partition'] = slurm_partition
    job['slurm_resource_mem'] = slurm_resource_mem
    job['slurm_timeout_hours'] = slurm_timeout_hours
    job['slurm_stdout'] = None
    job['slurm_template'] = slurm_template
    job['species'] = species
    job['status'] = None # running, failed, cancelled, complete
    job['thread_count'] = thread_count
    job['try_count_current'] = TRY_COUNT_CURRENT
    job['try_count_max'] = try_count_max
    job['use_existing_job'] = use_existing_job
    job['username'] = getpass.getuser()
    job['verified'] = None
    return job

def create_jobs_meta(job_list: list, species, jobs_dir: Path, out_dir: Path, work_dir: Path,
                     keep_cache: bool, machine_type: str, concurrent_jobs: int, thread_count: int, container: str,
                     try_count_max: int, use_existing_jobs: bool, job_outputs: list, singularity_dir: Path,
                     slurm_partition: str, slurm_template: Path, slurm_resource_mem: int, slurm_timeout_hours: int,
                     conda_env_name: str, project_name: str, cwl_workflow: Path,
                     cwl_workflow_name: str, ui_parameters: dict, remove_failed_samples: bool, decoys: list,
                     arvados_disable_reuse: bool) -> list:
    jobs = list()
    logging.debug('\njob_list:')
    logging.debug(pprint.pformat(job_list))
    
    for job_name in sorted(job_list):
        logging.info(f'job_name: {job_name}')

        if project_name:
            sample_job_dir = Path(jobs_dir, project_name)
        else:
            sample_job_dir = jobs_dir
        sample_work_dir = work_dir
        job = create_job(job_name, species, sample_job_dir, out_dir, sample_work_dir, keep_cache, machine_type,
                         concurrent_jobs, thread_count, container, try_count_max, use_existing_jobs, job_outputs,
                         singularity_dir, slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                         conda_env_name, project_name, cwl_workflow, cwl_workflow_name,
                         ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)
        jobs.append(job)
    return jobs

def create_slurm_job(job: dict) -> Path:
    with open(job['slurm_template'], 'r') as f_open:
        sbatch_script = f_open.read()

    sbatch_script = sbatch_script.replace('XX-cwl_cachedir-XX', str(job['cwl_cachedir'])+os.sep)
    sbatch_script = sbatch_script.replace('XX-cwl_engine-XX', str(job['cwl_engine']))
    sbatch_script = sbatch_script.replace('XX-cwl_job-XX', str(job['cwl_job']))
    sbatch_script = sbatch_script.replace('XX-cwl_outdir-XX', str(job['cwl_outdir'])+os.sep)
    sbatch_script = sbatch_script.replace('XX-cwl_stderr-XX', str(job['cwl_stderr']))
    sbatch_script = sbatch_script.replace('XX-cwl_stdout-XX', str(job['cwl_stdout']))
    sbatch_script = sbatch_script.replace('XX-cwl_tmpdir-XX', str(job['cwl_tmpdir'])+os.sep)
    sbatch_script = sbatch_script.replace('XX-cwl_workflow-XX', str(job['cwl_workflow']))
    sbatch_script = sbatch_script.replace('XX-cwl_singularity_cache-XX', str(job['singularity_dir']))
    sbatch_script = sbatch_script.replace('XX-singularity_pullfolder-XX', str(job['singularity_dir']))
    sbatch_script = sbatch_script.replace('XX-slurm_cpus-XX', str(job['thread_count']))
    sbatch_script = sbatch_script.replace('XX-slurm_jobname-XX', str(job['name']))
    sbatch_script = sbatch_script.replace('XX-slurm_mem-XX', str(job['slurm_resource_mem']))
    sbatch_script = sbatch_script.replace('XX-slurm_partition-XX', str(job['slurm_partition']))
    sbatch_script = sbatch_script.replace('XX-slurm_workdir-XX', str(job['cwl_jobdir']))
    sbatch_script = sbatch_script.replace('XX-slurm_timeout_hours-XX', str(job['slurm_timeout_hours']))
    sbatch_script = sbatch_script.replace('XX-username-XX', getpass.getuser())
    sbatch_script = sbatch_script.replace('XX-workdir-XX', str(job['local_workdir']))
    if job['container'] == 'docker':
        sbatch_script = sbatch_script.replace('XX-container-XX', str())
    elif job['container'] == 'singularity':
        sbatch_script = sbatch_script.replace('XX-container-XX', '--'+job['container'])

    job['slurm_job'].parent.mkdir(exist_ok=True, parents=True)
    with open(job['slurm_job'], 'w') as f_open:
        f_open.write(sbatch_script)
    return

def create_incremented_job(job: dict) -> dict:
    '''
    create a job with an incremented try_count_current
    '''

    if job['try_count_current'] > job['try_count_max']:
        logging.error(f'job: {job["name"]} has reached max try_count_current: {job["try_count_current"]}')
        sys.exit(1)

    job['try_count_current'] += 1
    job['cwl_stderr'] = job['cwl_stderr'].parent / f"{job['name']}.{str(job['try_count_current'])}.err"
    job['slurm_job'] = Path(job['cwl_jobdir'], job['name'] + '.' + str(job['try_count_current']) + '.sh')
    job['slurm_job_id'] = None
    job['slurm_job_status'] = None
    job['verified'] = None
    if job['machine_type'] == 'slurm':
        job['slurm_resource_mem'] = int(job['slurm_resource_mem'] * (1.5))
        job['slurm_timeout_hours'] = int(job['slurm_timeout_hours'] * (3))
        create_slurm_job(job)
        
    return job
