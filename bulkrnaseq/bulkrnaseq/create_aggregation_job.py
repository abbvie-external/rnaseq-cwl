import json
import logging
from pathlib import Path

from .create_jobs import any_arvados_machines, write_cwl_job

import arvados

def set_job_tars(job: dict, samples_tar_paths: list) -> dict:
    tars = list()
    for sample_tar in samples_tar_paths:
        tar = {'class':'File','location': sample_tar}
        tars.append(tar)
    job['cwl_data']['tars'] = tars
    return job

def get_samples_item_paths(sample_jobs: list, itemname: str, arv_client: dict) -> list:
    logging.info(f'sample_jobs: {sample_jobs}')
    samples_item_paths = list()
    for sample_job in sample_jobs:
        if sample_job['status'] == 'removed':
            continue
        if sample_job['machine_type'] == 'arvados':
            with open(sample_job['cwl_stdout'], 'r') as f_open:
                c_uuid = f_open.readline().strip()
            cr_req = arv_client.container_requests().get(uuid = c_uuid).execute()
            cwl_output_collection = arvados.collection.Collection(cr_req['output_uuid'])
            logging.info(f"output_uuid:{cr_req['output_uuid']}")
            with cwl_output_collection.open('cwl.output.json') as cwl_output_file:
                cwl_output = json.load(cwl_output_file)
            logging.info(f'cwl_output: {cwl_output}')
            item_path = 'keep:'+ cr_req['output_uuid']+'/'+cwl_output[itemname]['location']
        else:
            logging.info(f'sample_job: {sample_job}')
            with open(sample_job['cwl_stdout'], 'r') as f_open:
                job_data = json.load(f_open)
            item_path  = job_data[itemname]['path']
        samples_item_paths.append(item_path)
    logging.info(f'samples_item_paths: {samples_item_paths}')
    return samples_item_paths

def set_job_outputs(job: dict, kallisto_enabled: bool, run_tpmcalculator: bool,
                    transform_parameters: dict) -> dict:
    tp = transform_parameters
    outputs = ['html', 'data', 'rnaseqc_tpm']
    if run_tpmcalculator:
        pass
    if kallisto_enabled:
        outputs.append('kallisto_quant_tpm')
    if 'featurecounts_gtf_attrtype' in tp:
        outputs.append('counts')
        if 'featurecounts_junccounts' in tp and bool(tp['featurecounts_junccounts']):
            outputs.append('junccounts')
    job['output_keys'] = outputs
    return job

def include_metadata(job: dict) -> dict:
    job['cwl_data']['project_id'] = job['project_name']
    return job

def set_job_data(job: dict, kallisto_enabled: bool, run_tpmcalculator: bool,
                 transform_parameters: dict) -> dict:
    tp = transform_parameters
    if kallisto_enabled:
        job['cwl_data']['aggregate_kallisto'] = True
    else:
        job['cwl_data']['aggregate_kallisto'] = False
    if 'featurecounts_gtf_attrtype' in tp:
        job['cwl_data']['featurecounts_GTF_attrType'] = tp['featurecounts_gtf_attrtype']
        job['cwl_data']['featurecounts_GTF_featureType'] = tp['featurecounts_gtf_featuretype']
        if 'featurecounts_junccounts' in tp:
            job['cwl_data']['featurecounts_junccounts'] = bool(tp['featurecounts_junccounts'])
    else:
        job['cwl_data']['featurecounts_GTF_attrType'] = []
        job['cwl_data']['featurecounts_GTF_featureType'] = []
        job['cwl_data']['featurecounts_junccounts'] = False
    if run_tpmcalculator:
        job['cwl_data']['run_tpmcalculator'] = True
    else:
        job['cwl_data']['run_tpmcalculator'] = False
    return job

def create_project_job(job_meta: dict, sample_jobs: list, kallisto_enabled: bool,
                       run_tpmcalculator: bool, transform_parameters: dict) -> dict:
    if any_arvados_machines(sample_jobs):
        arv_client = arvados.api('v1', ...)
    else:
        arv_client = dict()
    samples_tar_paths = get_samples_item_paths(sample_jobs, 'tar', arv_client)
    job = include_metadata(job_meta)
    job = set_job_tars(job, samples_tar_paths)
    job = set_job_data(job, kallisto_enabled, run_tpmcalculator, transform_parameters)
    job = set_job_outputs(job, kallisto_enabled, run_tpmcalculator, transform_parameters)
    write_cwl_job(job)
    return job
