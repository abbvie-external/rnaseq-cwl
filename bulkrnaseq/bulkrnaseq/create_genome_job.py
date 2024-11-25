import logging
from pathlib import Path
import sys
import uuid

from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import DoubleQuotedScalarString as DQ

from .create_jobs import create_slurm_job, write_cwl_job

def include_metadata(job: dict) -> dict:
    job['cwl_data']['thread_count'] = job['thread_count']
    job['cwl_data']['run_uuid'] = job['run_uuid']
    return job

def create_genome_job(job: dict, genome_dict: dict) -> Path:
    dbsnp_url_array = list()
    fasta_url_array = list()
    fasta_cdna_url_array = list()
    gtf_url_array = list()

    dbsnp_size_array = list()
    fasta_size_array = list()
    fasta_cdna_size_array = list()
    gtf_size_array = list()

    sp_list = list()
    for i, sp in enumerate(list(genome_dict.keys())):
        logging.info(f'sp: {sp}')
        sp_list.append(sp)
        if i == 0:
            bedcutstring = genome_dict[sp]['bedcutstring']
            gtf_keyvalues = genome_dict[sp]['gtf_keyvalues']
            gtf_modname = genome_dict[sp]['gtf_modname']
            species = genome_dict[sp]['species']
            thread_count = genome_dict[sp]['thread_count']
            run_uuid = str(uuid.uuid3(namespace=uuid.NAMESPACE_URL,name='abbvie.com'))
        if 'dbsnp_url' in genome_dict[sp]:
            dbsnp_url_array.append(genome_dict[sp]['dbsnp_url'])
            dbsnp_size_array.append(genome_dict[sp]['dbsnp_size'])
        fasta_url_array.append(genome_dict[sp]['fasta_url'])
        fasta_cdna_url_array.append(genome_dict[sp]['fasta_cdna_url'])
        gtf_url_array.append(genome_dict[sp]['gtf_url'])
        fasta_size_array.append(genome_dict[sp]['fasta_size'])
        fasta_cdna_size_array.append(genome_dict[sp]['fasta_cdna_size'])
        gtf_size_array.append(genome_dict[sp]['gtf_size'])
    job_data = dict()
    job_data['decoy_type_array'] = job['decoys']
    job_data['decoy_tsv_array'] = get_decoy_tsvs(job['decoys'], sp_list)
    job_data['dbsnp_url_array'] = dbsnp_url_array
    job_data['fasta_url_array'] = fasta_url_array
    job_data['fasta_cdna_url_array'] = fasta_cdna_url_array
    job_data['gtf_url_array'] = gtf_url_array
    job_data['dbsnp_size_array'] = dbsnp_size_array
    job_data['fasta_size_array'] = fasta_size_array
    job_data['fasta_cdna_size_array'] = fasta_cdna_size_array
    job_data['gtf_size_array'] = gtf_size_array
    job_data['bedcutstring'] = DQ(bedcutstring)
    job_data['gtf_keyvalues'] = gtf_keyvalues
    job_data['gtf_modname'] = gtf_modname
    job_data['run_uuid'] = str(run_uuid)
    job_data['species'] = species
    job_data['thread_count'] = thread_count
    job['cwl_data'] = job_data
    job['output_keys'] = ['collapsed_bed', 'collapsed_gtf', 'dbsnp_index', 'fasta_cdna', 'fasta_index_dict', 'genome_Genome', 'genome_Log_out', 'genome_SA', 'genome_SAindex', 'genome_chrLength_txt', 'genome_chrNameLength_txt', 'genome_chrName_txt', 'genome_chrStart_txt', 'genome_exonGeTrInfo_tab', 'genome_exonInfo_tab', 'genome_geneInfo_tab', 'genome_genomeParameters_txt', 'genome_sjdbInfo_txt', 'genome_sjdbList_fromGTF_out_tab', 'genome_sjdbList_out_tab', 'genome_transcriptInfo_tab', 'gtf', 'kallisto_hawsh_index', 'kallisto_index', 'ref_flat', 'rrna_intervallist']
    write_cwl_job(job)
    return job

def get_decoy_tsvs(decoys: list, sp_list: list) -> list:
    decoy_tsvs = list()
    for decoy in sorted(decoys):
        decoy_tsv_found = False
        for sp in sorted(sp_list):
            decoy_tsv =  Path(Path(__file__).parent, 'static_files', 'decoy', sp+'.'+decoy+'.tsv')
            logging.debug(f'decoy_tsv: {decoy_tsv}')
            if decoy_tsv.exists():
                decoy_cwl = {'class': 'File', 'location': str(decoy_tsv)}
                decoy_tsvs.append(decoy_cwl)
                decoy_tsv_found = True
        if not decoy_tsv_found:
            logging.error(f'decoy: {decoy} not found')
            sys.exit(1)
    return decoy_tsvs

def create_star_genome(job: dict) -> dict:
    genome_dict = dict()
    for sp in job['species']:
        sp_yml = Path(Path(__file__).parent, 'static_files', 'yml_files', job['cwl_workflow'].stem+'_'+sp+'_star.yml')
        logging.debug(f'sp_yml: {sp_yml}')
        yaml = YAML()
        with open(sp_yml, 'r') as f_open:
            sp_data = yaml.load(f_open)
        genome_dict[sp] = sp_data
    job = include_metadata(job)
    job = create_genome_job(job, genome_dict)
    return job
