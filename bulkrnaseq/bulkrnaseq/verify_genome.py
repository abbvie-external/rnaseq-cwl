#!/usr/bin/env python3

import argparse
import os
import pathlib
import pprint
import sys
import logging

from pathlib import Path
from typing import Optional

import ruamel.yaml
import arvados
import re

def check_path_list(path_list: list) -> bool:
    verified = True
    for path in path_list:
        if not path.exists():
            logging.info(f'path: {path}')
            logging.info('does NOT exist')
            verified &= False
        else:
            logging.info(f'path: {path}')
            logging.info('DOES exist')
    return verified

def to_cwl(file_path: Path, cwl_key: str, secondary_files: list() = []) -> dict:
    file_cwl = dict()
    file_cwl['class'] = 'File'
    file_cwl['location'] = str(file_path)
    if secondary_files:
        file_list = list()
        for f in secondary_files:
            cwl_obj = dict()
            cwl_obj['class'] = 'File'
            cwl_obj['location'] = str(f)
            file_list.append(cwl_obj)
        file_cwl['secondaryFiles'] = file_list
    cwl_data = {cwl_key: file_cwl}
    return cwl_data

def get_concat_name(genome_dict: dict, cwl_key: str, url_key: str, decoys: list) -> str:
    basename_list = list()
    for sp in genome_dict:
        url = Path(genome_dict[sp][url_key])
        basename_list.append(url.name)
    logging.info(f'basename_list: {basename_list}')
    concat_list = list()
    for filename in basename_list:
        if url_key == 'dbsnp_url':
            dots_kept = [1,-2]
        elif url_key == 'fasta_url':
            if filename.count('.') == 5:
                dots_kept = [4, -2]
            elif filename.count('.') == 6:
                dots_kept = [5, -2]
        elif url_key == 'fasta_cdna_url':
            if filename.count('.') == 5:
                dots_kept = [4, -2]
            elif filename.count('.') == 6:
                dots_kept = [5, -2]
        elif url_key == 'gtf_url':
            if filename.count('.') == 4:
                dots_kept = [3, -2]
            elif filename.count('.') == 5:
                dots_kept = [4, -2]
        filename_split = filename.split('.')
        filename_kept = filename_split[:dots_kept[0]]
        concat_list.extend(filename_kept)
    if url_key == 'fasta_url':
        concat_list.extend(decoys)
    elif url_key == 'fasta_cdna_url':
        concat_list.extend(decoys)
    elif url_key == 'gtf_url':
        if cwl_key == 'gtf':
            concat_list.extend(decoys)
        elif cwl_key == 'ref_flat':
            concat_list.extend(decoys)
    filename_sfx = filename_split[dots_kept[1]:]
    concat_list.extend(filename_sfx)
    logging.info(f'concat_list: {concat_list}')
    concat_name = '.'.join(concat_list)
    return concat_name

def get_ref_filename_dict(genome_dict: dict, url_key: Optional[str], cwl_key: str, decoys: list) -> dict:
    ref_filename_dict = dict()
    if url_key is not None:
        concat_name = get_concat_name(genome_dict, cwl_key, url_key, decoys)
    secondary_files = list()
    if url_key in ['fasta_url', 'fasta_cdna_url', 'gtf_url']:
        concat_name = concat_name.rstrip('.gz')

    secondary_files = list()
    if cwl_key == 'dbsnp':
        secondary_files.append(Path(concat_name+'.tbi'))
    elif cwl_key == 'fasta':
        secondary_files.append(Path(concat_name+'.fai'))
        secondary_files.append(Path(concat_name.rstrip('.fa')+'.dict'))
    elif cwl_key == 'collapsed_bed':
        concat_name = Path(concat_name.rstrip('.gtf')+'.collapsed.bed')
    elif cwl_key == 'collapsed_gtf':
        concat_name = Path(concat_name.rstrip('.gtf')+'.collapsed.gtf')
    elif cwl_key == 'ref_flat':
        concat_name = Path(concat_name.rstrip('.gtf')+'.refflat')
    elif cwl_key == 'rrna_intervallist':
        sp = list(genome_dict.keys())[0]
        gtf_modname = genome_dict[sp]['gtf_modname']
        concat_name = Path(concat_name.rstrip('.gtf')+'.'+gtf_modname+'.list')
    elif cwl_key == 'kallisto_hawsh_index':
        concat_name = concat_name.rstrip('.fa')+'.hawsh.ki'
    elif cwl_key == 'kallisto_index':
        concat_name = concat_name.rstrip('.fa')+'.ki'
    if url_key is not None:
        cwl_files = to_cwl(concat_name, cwl_key, secondary_files)
        ref_filename_dict.update(cwl_files)

    if cwl_key == 'star':
        cwl_files_list = list()
        cwl_files_list.append(to_cwl(Path('chrLength.txt'), 'genome_chrLength_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('chrNameLength.txt'), 'genome_chrNameLength_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('chrName.txt'), 'genome_chrName_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('chrStart.txt'), 'genome_chrStart_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('exonGeTrInfo.tab'), 'genome_exonGeTrInfo_tab', secondary_files))
        cwl_files_list.append(to_cwl(Path('exonInfo.tab'), 'genome_exonInfo_tab', secondary_files))
        cwl_files_list.append(to_cwl(Path('geneInfo.tab'), 'genome_geneInfo_tab', secondary_files))
        cwl_files_list.append(to_cwl(Path('Genome'), 'genome_Genome', secondary_files))
        cwl_files_list.append(to_cwl(Path('genomeParameters.txt'), 'genome_genomeParameters_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('Log.out'), 'genome_Log_out', secondary_files))
        cwl_files_list.append(to_cwl(Path('SA'), 'genome_SA', secondary_files))
        cwl_files_list.append(to_cwl(Path('SAindex'), 'genome_SAindex', secondary_files))
        cwl_files_list.append(to_cwl(Path('sjdbInfo.txt'), 'genome_sjdbInfo_txt', secondary_files))
        cwl_files_list.append(to_cwl(Path('sjdbList.fromGTF.out.tab'), 'genome_sjdbList_fromGTF_out_tab', secondary_files))
        cwl_files_list.append(to_cwl(Path('sjdbList.out.tab'), 'genome_sjdbList_out_tab', secondary_files))
        cwl_files_list.append(to_cwl(Path('transcriptInfo.tab'), 'genome_transcriptInfo_tab', secondary_files))
        for cwl_files in cwl_files_list:
            ref_filename_dict.update(cwl_files)    
    return ref_filename_dict

def all_sp_have_url_key(genome_dict: dict, url_key: str) -> bool:
    have_url_key = True
    for sp in genome_dict:
        if url_key not in genome_dict[sp]:
            have_url_key = False
            break
    return have_url_key

def get_star_genome_filenames(genome_dict: dict, decoys: list) -> dict:
    filenames_dict = dict()

    url_key = 'dbsnp_url'
    cwl_key = 'dbsnp'
    have_dbsnp = all_sp_have_url_key(genome_dict, url_key)
    if have_dbsnp:
        dbsnp_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
        filenames_dict.update(dbsnp_ref_filename_dict)

    url_key = 'fasta_url'
    cwl_key = 'fasta'
    fasta_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(fasta_ref_filename_dict)

    url_key = 'fasta_cdna_url'
    cwl_key = 'fasta_cdna'
    fasta_cdna_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(fasta_cdna_ref_filename_dict)
    cwl_key = 'kallisto_index'
    kallisto_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(kallisto_ref_filename_dict)
    cwl_key = 'kallisto_hawsh_index'
    kallisto_hawsh_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(kallisto_hawsh_ref_filename_dict)

    url_key = 'gtf_url'
    cwl_key = 'gtf'
    gtf_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(gtf_ref_filename_dict)

    cwl_key = 'collapsed_bed'
    collapsed_bed_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(collapsed_bed_ref_filename_dict)

    cwl_key  = 'collapsed_gtf'
    collapsed_gtf_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(collapsed_gtf_ref_filename_dict)

    cwl_key = 'ref_flat'
    ref_flat_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(ref_flat_ref_filename_dict)

    cwl_key = 'rrna_intervallist'
    rrna_intervallist_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(rrna_intervallist_ref_filename_dict)

    url_key = None
    cwl_key = 'star'
    star_ref_filename_dict = get_ref_filename_dict(genome_dict, url_key, cwl_key, decoys)
    filenames_dict.update(star_ref_filename_dict)
    return filenames_dict

def get_cwl_file_list(static_data):
    file_list = list()
    for cwl_item in sorted(list(static_data.keys())):
        cwl_value = static_data[cwl_item]
        logging.debug(f'\n\ncwl_item: {cwl_item}')
        logging.debug(f'cwl_value:')
        logging.debug(pprint.pformat(cwl_value))
        if cwl_value.get('class') == 'File':
            logging.debug('\t\tis_file')
            if 'location' in cwl_value:
                file_list.append(Path(cwl_value['location']))
            elif 'path' in cwl_value:
                file_list.append(Path(cwl_value['path']))
            if 'secondaryFiles' in cwl_value:
                for secondary_file in cwl_value['secondaryFiles']:
                    if 'location' in secondary_file:
                        file_list.append(Path(secondary_file['location']))
                    elif 'path' in secondary_file:
                        file_list.append(Path(secondary_file['path']))
    logging.debug(f'file_list: {file_list}')
    return file_list

def cwl_file_to_cwl_path(static_data: dict, adir: Path) -> dict:
    logging.info(f'static_data: {static_data}')
    path_static_data = dict()
    for cwl_item in sorted(list(static_data.keys())):
        cwl_value = static_data[cwl_item]
        logging.debug(f'\n\ncwl_item: {cwl_item}')
        logging.debug(f'cwl_value: {cwl_value}')
        if cwl_value.get('class') == 'File':
            if 'location' in cwl_value:
                cwl_value['location'] = str(adir / Path(cwl_value['location']))
            elif 'path' in cwl_value:
                cwl_value['path'] = str(adir / Path(cwl_value['path']))
            if 'secondaryFiles' in cwl_value:
                for secondary_file in cwl_value['secondaryFiles']:
                    if 'location' in secondary_file:
                        secondary_file['location'] = str(adir / Path(secondary_file['location']))
                    elif 'path' in secondary_file:
                        secondary_file['path'] = str(adir / Path(secondary_file['path']))
        logging.debug(f'cwl_item: {cwl_item}')
        logging.debug(f'cwl_value: {cwl_value}')
        path_static_data[cwl_item] = cwl_value
    return path_static_data

def verify_cwl_paths(static_data: dict) -> bool:
    path_list = get_cwl_file_list(static_data)
    return check_path_list(path_list)

def build_list_collection_filter(file_list, collection_uuid):
    filter_list = list()
    for file_name in file_list:
        filter_item = ['file_names', 'ilike', '%'+str(file_name)+'%']
        filter_list.append(filter_item)
    filter_list.append(['uuid', '=', collection_uuid])
    return filter_list

def verify_arvados_collection(cwl_file_data: dict, species: list, new_collection_id: str, decoys: list) -> bool:
    species = '_'.join(species)
    if len(decoys) > 0:
        decoy_str = '.'.join(decoys)
        species = species+'.'+decoy_str
    logging.debug('\n\ncwl_file_data:')
    logging.debug(pprint.pformat(cwl_file_data))
    logging.debug(f'species: {species}')
    path_list = get_cwl_file_list(cwl_file_data)
    logging.debug('\n\npath_list:')
    logging.debug(pprint.pformat(path_list))
    file_list = [f.name for f in path_list]
    logging.debug('\n\nfile_list:')
    logging.debug(pprint.pformat(file_list))
    yaml = ruamel.yaml.YAML()
    collection_yml = Path(Path(__file__).parent, 'static_files', 'yml_files', 'arvados_collection_genomes.yml')
    with open(collection_yml, 'r') as f_open:
        collection_data = dict(yaml.load(f_open))
    logging.debug(f'collection_data: {collection_data}')
    collection_uuid = collection_data[species]
    if len(new_collection_id) > 0 and len(decoys) > 0:
        collection_uuid = new_collection_id
    logging.debug(f'new_collection_id: {new_collection_id}')
    logging.debug(f'decoys: {decoys}')
    logging.debug(f'collection_uuid: {collection_uuid}')
    list_collection_filter = build_list_collection_filter(file_list, collection_uuid)
    logging.debug('list_collection_filter')
    logging.debug(pprint.pprint(list_collection_filter))
    arv_client = arvados.api('v1', ...)
    res = arv_client.collections().list(filters=list_collection_filter).execute()
    verified = bool(res.get('items_available', 0))
    return verified

def find_n_replace_keep_id(text, new_id):
    return re.sub(r'(keep:)[^/]+', rf'\1{new_id}', text)

def replace_uuid(static_data, collection_uuid):
    for cwl_item in static_data:
        cwl_value = static_data[cwl_item]
        if cwl_value.get('class') == 'File':
            if 'location' in cwl_value:
                cwl_value['location'] = find_n_replace_keep_id(cwl_value['location'], collection_uuid)
            elif 'path' in cwl_value:
                cwl_value['path'] = find_n_replace_keep_id(cwl_value['path'], collection_uuid)
            if 'secondaryFiles' in cwl_value:
                for secondary_file in cwl_value['secondaryFiles']:
                    if 'location' in secondary_file:
                        secondary_file['location'] = find_n_replace_keep_id(secondary_file['location'], collection_uuid)
                    elif 'path' in secondary_file:
                        secondary_file['path'] =  find_n_replace_keep_id(secondary_file['path'], collection_uuid)
    return static_data


def cwl_files_to_keep_path(static_data: dict, species: list, decoys: list) -> dict:
    yaml = ruamel.yaml.YAML()
    collection_yml = Path(Path(__file__).parent, 'static_files', 'yml_files', 'arvados_collection_genomes.yml')
    with open(collection_yml, 'r') as f_open:
        collection_data = yaml.load(f_open)
    species = '_'.join(species)
    if len(decoys) > 0:
        decoy_str = '.'.join(decoys)
        species = species+'.'+decoy_str
    collection_uuid = collection_data[species]
    for cwl_item in static_data:
        cwl_value = static_data[cwl_item]
        if cwl_value.get('class') == 'File':
            if 'location' in cwl_value:
                cwl_value['location'] = 'keep:'+collection_uuid+'/'+cwl_value['location']
            elif 'path' in cwl_value:
                cwl_value['path'] = 'keep:'+collection_uuid+'/'+cwl_value['path']
            if 'secondaryFiles' in cwl_value:
                for secondary_file in cwl_value['secondaryFiles']:
                    if 'location' in secondary_file:
                        secondary_file['location'] = 'keep:'+collection_uuid+'/'+secondary_file['location']
                    elif 'path' in secondary_file:
                        secondary_file['path'] = 'keep:'+collection_uuid+'/'+secondary_file['path']
    return static_data

def set_star_genome_outputs(job_meta: dict) -> dict:
    yaml = ruamel.yaml.YAML()
    genome_dict = dict()
    for sp in job_meta['species']:
        genome_yml = Path(Path(__file__).parent, 'static_files', 'yml_files', job_meta['cwl_workflow'].stem+'_'+sp+'_star.yml')
        with open(genome_yml, 'r') as f_open:
            genome_data = yaml.load(f_open)
        genome_dict[sp] = genome_data
    logging.info(f'genome_dict: {genome_dict}')
    file_static_data = get_star_genome_filenames(genome_dict, job_meta['decoys'])
    logging.debug(f"set_star_genome_outputs, before conversion:{file_static_data}")
    if job_meta['machine_type'] == 'arvados':
        job_meta['cwl_outputs'] = cwl_files_to_keep_path(file_static_data, job_meta['species'], job_meta['decoys'])
    elif job_meta['machine_type'] in ['single', 'slurm']:
        job_meta['cwl_outputs'] = cwl_file_to_cwl_path(file_static_data, job_meta['cwl_outdir'])
    logging.debug(f"set_star_genome_outputs, after conversion:{job_meta}")
    return job_meta

def verify_star_genome_installed(job_meta: dict) -> dict:
    job_meta['verified'] = False
    if job_meta['machine_type'] == 'arvados':
        if 'outputcollection_uuid' in job_meta['parameters_arvados']:
            outputcollection_uuid = job_meta['parameters_arvados']['outputcollection_uuid']
            job_meta['cwl_outputs'] = replace_uuid(job_meta['cwl_outputs'],outputcollection_uuid)
        else:
            outputcollection_uuid = ''
        job_meta['verified'] = verify_arvados_collection(job_meta['cwl_outputs'], job_meta['species'], outputcollection_uuid, job_meta['decoys'])    
    elif job_meta['machine_type'] in ['single', 'slurm']:
        job_meta['verified'] = verify_cwl_paths(job_meta['cwl_outputs'])
    if not job_meta['verified']:
        logging.info('star genome is NOT verified')
    else:
        logging.info('star genome IS verified')
    logging.debug(f"verify_star_genome_installed: {job_meta['cwl_outputs']}")
    return job_meta
