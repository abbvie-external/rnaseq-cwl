import glob
import json
import os
from pathlib import Path
import pprint
import sys
import logging

import pandas as pd
from ruamel.yaml import YAML

def get_yml_samples_data(yml_path: Path) -> dict:
    yaml = YAML()
    with open(yml_path, 'r') as f_read:
        samples_data = yaml.load(f_read)
    return samples_data        

def get_sample_fastq_dict(sample_list: list, fastq_dir: Path, fastq_sep: str = '_') -> dict:
    sample_fastq_dict = dict()
    for sample in sorted(sample_list):
        logging.debug(f'sample: {sample}')
        fastq_pattern = sample+fastq_sep+'*'
        logging.debug(f'fastq_pattern: {fastq_pattern}')
        fastq_list = list(fastq_dir.glob(fastq_pattern))
        logging.debug(f'fastq_list: {fastq_list}')
        if len(fastq_list) == 0: # failed fastq_sep
            return None
        sample_fastq_dict[sample] = sorted([str(fastq) for fastq in fastq_list])
    return sample_fastq_dict    

def get_sample_list(samples_tsv: Path, samples_tsv_column: str) -> list:
    tsv_df = pd.read_csv(samples_tsv, sep='\t',dtype={samples_tsv_column: str})
    sample_list = list(tsv_df[samples_tsv_column])
    sample_list = [x for x in sample_list if len(x) > 0]
    return sample_list

def get_pe_sample_readgroup_dict(sample_fastq_dict: dict) -> dict:
    sample_readgroup_dict = dict()
    for sample in sorted(sample_fastq_dict.keys()):
        sample_readgroup_dict[sample] = list()
        sample_fastq_list = sorted(sample_fastq_dict[sample])
        if len(sample_fastq_list) % 2 != 0:
            logging.error(f'fastq_list has odd number of files: {len(sample_fastq_list)}')
            logging.error(pprint.pformat(sample_fastq_list))
            logging.error('automatic fastq-to-sample was specified with')
            logging.error('"fastq_type: paired" but has an odd number of')
            logging.error('fastq files per readgroup')
            logging.error('please specify --sample-yml for mixed SE/PE readgroups')
            logging.error('or set "fastq_type: single"')
            sys.exit(1)
        readgroup_count = int(len(sample_fastq_list)/2)
        for i in range(readgroup_count):
            r1_index = i * 2
            r2_index = (i * 2) + 1
            r1 = sample_fastq_list[r1_index]
            r2 = sample_fastq_list[r2_index]
            readgroup_dict = dict()
            readgroup_dict['forward_fastq'] = r1
            readgroup_dict['reverse_fastq'] = r2
            sample_readgroup_dict[sample].append(readgroup_dict)
    return sample_readgroup_dict

def get_se_sample_readgroup_dict(sample_fastq_dict: dict) -> dict:
    sample_readgroup_dict = dict()
    for sample in sorted(sample_fastq_dict.keys()):
        sample_readgroup_dict[sample] = list()
        sample_fastq_list = sorted(sample_fastq_dict[sample])
        readgroup_count = len(sample_fastq_list)
        for i in range(readgroup_count):
            r1_index = i
            r1 = sample_fastq_list[r1_index]
            readgroup_dict = dict()
            readgroup_dict['forward_fastq'] = r1
            sample_readgroup_dict[sample].append(readgroup_dict)
    return sample_readgroup_dict

def write_samples_yml(batch_name: str, jobs_dir: Path, sample_readgroup_dict: dict) -> Path:
    yaml = YAML()
    yaml.indent(sequence=4, offset=2)
    yml_path = Path(jobs_dir, batch_name + '_sample_fastq.yml')
    logging.info(f'generated sample yaml file {yml_path}')
    if not jobs_dir.exists():
        jobs_dir.mkdir(parents=True, exist_ok=True)
    with open(yml_path, 'w') as f:
        genome_data = yaml.dump(sample_readgroup_dict, f)
    return yml_path

def create_samples_yml(batch_name: str, fastq_dir: Path, samples_tsv: Path, samples_tsv_column: str, fastq_type: str, fastq_sep_list: list, jobs_dir: Path) -> Path:
    sample_list = get_sample_list(samples_tsv, samples_tsv_column)
    sample_fastq_dict = get_sample_fastq_dict(sample_list, fastq_dir)
    if sample_fastq_dict is None:
        for fastq_sep in fastq_sep_list:
            sample_fastq_dict = get_sample_fastq_dict(sample_list, fastq_dir, fastq_sep)
            if sample_fastq_dict is not None:
                break
        if sample_fastq_dict is None:
            logging.error(f'Can not find fastq file under {fastq_dir} whose name begins with {sample_list} and followed by {fastq_sep_list}. Check your fastq file names!')
            logging.error('Only compressed fastq are supported in the pipeline so far')
            sys.exit(1)
    if fastq_type == 'paired':
        sample_readgroup_dict = get_pe_sample_readgroup_dict(sample_fastq_dict)
    elif fastq_type == 'single':
        sample_readgroup_dict = get_se_sample_readgroup_dict(sample_fastq_dict)
    else:
        logging.error(f'unrecognized fastq_type: {fastq_type}.')
        logging.error('valid values are "paired" or "single"')
        sys.exit(1)
    yml_path = write_samples_yml(batch_name, jobs_dir, sample_readgroup_dict)
    return yml_path


def get_bcl_samples_yml(bcl2fq_job: Path) -> Path:
    with open(bcl2fq_job['cwl_stdout'], 'r') as f_open:
        bcl2fq_samples = json.load(f_open)['samples']
    samples = dict()
    for sample in bcl2fq_samples:
        SM = sample[0]['readgroup_meta']['SM']
        readgroup_list = list()
        for readgroup in sample:
            forward_fastq = readgroup['forward_fastq']['path']
            reverse_fastq = readgroup['reverse_fastq']['path']
            new_readgroup = dict()
            new_readgroup['forward_fastq'] = forward_fastq
            new_readgroup['reverse_fastq'] = reverse_fastq
            readgroup_list.append(new_readgroup)
        samples[SM] = readgroup_list
    samples_yml = write_samples_yml(bcl2fq_job['project_name'], bcl2fq_job['cwl_jobdir'], samples)
    return samples_yml
