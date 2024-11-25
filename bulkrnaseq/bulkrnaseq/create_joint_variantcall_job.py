import ruamel.yaml

from .create_jobs import get_cwl_vals, write_cwl_job

def create_joint_vc_job(job: dict, sample_jobs: list, star_genome_meta: dict) -> dict:
    job_data = dict()
    job_data['project_id'] = job['project_name']
    sample_out_list = [job['cwl_stdout'] for job in sample_jobs if job['status'] == 'complete']
    vcfs_cwl = get_cwl_vals(sample_out_list, 'variants')
    job_data['vcfs'] = vcfs_cwl
    fasta_data = star_genome_meta['cwl_outputs']['fasta']
    job_data['fasta'] = fasta_data
    job['cwl_data'] = job_data
    write_cwl_job(job)
    job['outputs'] = ['vcf']
    return job
