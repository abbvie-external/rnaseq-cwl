from pathlib import Path
import logging
import pprint

from .create_jobs import write_cwl_job

import xml.etree.ElementTree as ET

def get_runparameters_key(runparameters: str, xmlkey: str) -> str:
    tree = ET.parse(runparameters)
    root = tree.getroot()
    items = root.find('Setup')
    xmlitem = items.find(xmlkey)
    keyval = xmlitem.text
    return keyval

def get_bcl_project_id(bcl_inputs: list) -> str:
    '''
    get project name from list of bcl dirs, prefered from runParameters.xmls
    '''
    project_id = str()
    for bcl_input in bcl_inputs:
        run_parameters_xml = Path(bcl_input['basecalls_dir'], 'runParameters.xml')
        if run_parameters_xml.exists():
            run_id = get_runparameters_key(run_parameters_xml, 'RunID')
        else:
            run_id = Path(bcl_input['basecalls_dir']).parent.name
        project_id += run_id + '_'
    project_id = project_id.rstrip('_')
    return project_id

def get_bcl2fq_job_data(bcl_inputs: list, sequencing_center: str, thread_count: int, bcl_only_lane: str) -> dict:
    bcl2fq_job_inputs = dict()
    if str(bcl_only_lane).isdigit():
        bcl2fq_job_inputs['bcl-only-lane'] = int(bcl_only_lane)
    bcl2fq_job_inputs['basecalls_array'] =  [{'class': 'Directory', 'path': x['basecalls_dir']} for x in bcl_inputs]
    bcl2fq_job_inputs['samplesheets'] = [{'class': 'File', 'path': x['samplesheet']} for x in bcl_inputs]
    bcl2fq_job_inputs['sequencing_center'] = sequencing_center
    bcl2fq_job_inputs['thread_count'] = thread_count
    return bcl2fq_job_inputs

def create_bcl2fq_job(job: dict, bcl_inputs: list, bcl_only_lane: str, sequencing_center: str) -> dict:
    job['cwl_data'] = get_bcl2fq_job_data(bcl_inputs, sequencing_center, job['thread_count'], bcl_only_lane)
    write_cwl_job(job)
    return job
