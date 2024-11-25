import os

import pathlib
import shlex
import shutil
import subprocess
import sys
import logging
from pathlib import Path
import pprint
import socket
from typing import Optional
import argparse
from jsonschema import validate, SchemaError, ValidationError
import json

from distutils.util import strtobool

import ruamel.yaml
import yaml
import pkg_resources
import uuid

from bulkrnaseq import __version__

def remove(path: str) -> None:
    """ param <path> could either be relative or absolute. """
    if os.path.isfile(path) or os.path.islink(path):
        os.remove(path)  # remove the file
    elif os.path.isdir(path):
        shutil.rmtree(path)  # remove dir and all contains
    else:
        raise ValueError("file {} is not a file or dir.".format(path))


def generate_job_init_kwargs(input_data) -> dict:
    job_init_kwargs = dict()
    job_init_kwargs['arvados_project_uuid'] = input_data['arvados_project_uuid']
    job_init_kwargs['job_dir'] = input_data['job_dir']
    job_init_kwargs['keep_cache'] = input_data['keep_cache']
    job_init_kwargs['machine_type'] = input_data['machine_type']
    job_init_kwargs['out_dir'] = input_data['out_dir']
    job_init_kwargs['sbatch_template'] = input_data['sbatch_template']
    job_init_kwargs['singularity_dir'] = input_data['singularity_dir']
    job_init_kwargs['use_existing_jobs'] = input_data['use_existing_jobs']
    job_init_kwargs['work_dir'] = input_data['work_dir']
    job_init_kwargs[''] = input_data['work_try_max']
    job_init_kwargs['job_dir'] = input_data['job_dir']
    return job_init_kwargs


def parse_input(input_yml: str) -> dict:
    yaml = ruamel.yaml.YAML()
    with open(input_yml, 'r') as f:
        input_data = yaml.load(f)
    for key in input_data:
        value = input_data[key]
        if isinstance(value, str) and value.startswith('~'):
            value = value.replace('~', str(pathlib.Path.home()))
        input_data[key] = value

    # if 'species' in input_data:
    #     species_count = len(input_data['species']) if isinstance(input_data['species'], list) else 1
    #     if (species_count > 1):
    #         logging.error(f'Only one species is supported right now {input_data["species"]}')
    #         sys.exit(1)
    return input_data

def get_arvados_parameters(parameters: dict, input_data: dict) -> dict:
    for input_item in sorted(list(input_data.keys())):
        if input_item.startswith('arvados_'):
            if not 'parameters_arvados' in parameters:
                parameters['parameters_arvados'] = dict()
            parameters['parameters_arvados'][input_item.lstrip('arvados_')] = input_data[input_item]    
    return parameters

def get_featurecounts_parameters(parameters: dict, input_data: dict) -> dict:
    for input_item in sorted(list(input_data.keys())):
        if input_item.startswith('featurecounts_'):
            parameters[input_item] = input_data[input_item]
    return parameters

def get_ui_parameters(input_data: dict) -> dict:
    parameters = dict()
    parameters = get_arvados_parameters(parameters, input_data)
    return parameters

def get_transform_parameters(input_data: dict) -> dict:
    parameters = dict()
    parameters = get_featurecounts_parameters(parameters, input_data)
    return parameters


def validate_input(input_data: dict) -> None:
    required_input_list = [
        'conda-env-name',
        'container',
        'generate-genome-cwl',
        'joint_variantcal_cwl',
        'jobs-dir',
        'keep_cache',
        'machine_type',
        'project_cwl',
        'project-id',
        'species',
        'star-align-cwl'
        'thread-count',
        'work-dir',
        'fastq-dir',
        'fastq-type'
    ]

    optional_input_list = [
        'arvados_disable_reuse',
        'arvados_project_uuid',
        'batch_id',
        'concurrent_jobs',
        'decoy_tsv_array',
        'kallisto_enabled',
        'kallisto_quant_bootstrap_samples',
        'run-markduplicates',
        'samples-tsv',
        'samples-tsv-column',
        'samples-yml',
        'sequencing-center',
        'sequencing-date',
        'sequencing-model',
        'sequencing-platform',
        'slurm_partition',
        'slurm_resource_mem',
        'slurm_timeout_hours',
        'use_existing_jobs'
    ]
    for req_item in required_input_list:
        if req_item not in input_data:
            logging.info('missing required input: {}'.format(req_item))
            sys.exit(1)
    for input_item in input_data:
        if (input_item not in required_input_list) or (input_item not in optional_input_list):
            logging.info('unrecognized input: {}'.format(input_item))
            sys.exit(1)
    return


def clean_cache_tmp(work_dir: Path) -> None:
    cache_dir = Path(work_dir, 'cache')
    tmp_dir = Path(work_dir, 'tmp')
    shutil.rmtree(cache_dir, ignore_errors=True)
    shutil.rmtree(tmp_dir, ignore_errors=True)
    return


def get_conda() -> str:
    conda_env = dict(os.environ)
    condadir = str(sys.exec_prefix)
    conda_script = Path(condadir, 'etc', 'profile.d', 'conda.sh')
    cmd = shlex.split(f"env -i bash -c 'source " +str(conda_script)+ " && env -0'")
    pipe = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    output = pipe.communicate()[0].decode('utf-8')
    output = output[:-1]
    pre_filter_env = dict()
    for line in output.split('\x00'):
        if '=' in line:
            line = line.split('=', 1)
            pre_filter_env[line[0]] = line[1]
    for item in pre_filter_env:
        conda_env[item] = pre_filter_env[item]
    return conda_env


def get_last_n_line(file_path: str, head: bool, n: int) -> str:
    """ Extract first or last n lines from the text file

    Args:
        file_path: text file path
        head: True for head, False for tail
        n:  the number of line be extracted from file

    Returns:
        string content of the n lines
    """
    nlines = []
    with open(file_path) as file:
        if not head:
            for line in (file.readlines()[-n:]):
                nlines.append(line)
        else:
            for line in (file.readlines()[n:]):
                nlines.append(line)
    return nlines

def get_installed_version(pkg_name):
    cmd = ['pip', 'list']
    res = try_or_None(cmd).split('\n')
    for line in res:
        if pkg_name in line:
            break
    version_str = line.split()[1].strip()
    return version_str

def try_or_None(command_list: list[str]) -> Optional[str]:
    """ try run the command list and return standard out as string, atherwise, return None

    Args:
        command_list: command line, shall be a list of string

    Returns: standout or None

    """
    try:
        return subprocess.run(command_list, capture_output=True, text=True).stdout.strip()
    except Exception as e:
        logging.warning(str(e))
        return None


def write_launching_metrics(output_file: str, central_folder: str) -> str:
    """ generate application launching metrics and save them to the file
    Args:
        output_file: file path to store the metrics result

    """
    hostname = socket.gethostname()
    with open("/etc/os-release") as f:
        os_versions = {}
        for line in f:
            if "=" in line:
                k, v = line.rstrip().split("=")
                os_versions[k] = v
    system_core = os_versions['PRETTY_NAME']
    slurm_version = try_or_None(['sinfo', '-v']).split(' ')[1] if try_or_None(['sinfo', '-v']) else None
    conda_version = try_or_None(['conda', '-V']).split(' ')[1] if try_or_None(['conda', '-V']) else None
    git_version = try_or_None(['git', '--version']).split(' ')[2] if try_or_None(['git', '--version']) else None
    user = try_or_None(['whoami']) if try_or_None(['whoami']) else 'unknown'
    start_time = try_or_None(['date']) if try_or_None(['date']) else None
    current_directory = os.getcwd()
    current_git_commit = try_or_None(['git', 'rev-parse', 'HEAD'])
    installed_bulkrnaseq_version = pkg_resources.get_distribution('bulkrnaseq').version
    thisrun_uuid = str(uuid.uuid1())

    with open(output_file, 'w') as out_f:
        out_f.write(f'name\tvalue\n')
        out_f.write(f'hostname\t{hostname}\n')
        out_f.write(f'user\t{user}\n')
        out_f.write(f'system_core\t{system_core}\n')
        out_f.write(f'slurm_version\t{slurm_version}\n')
        out_f.write(f'current_git_commit\t{current_git_commit}\n')
        out_f.write(f'installed_bulkrnaseq_version\t{installed_bulkrnaseq_version}\n')
        out_f.write(f'conda_version\t{conda_version}\n')
        out_f.write(f'git_version\t{git_version}\n')
        out_f.write(f'start_time\t{start_time}\n')
        out_f.write(f'current_directory\t{current_directory}\n')
        out_f.write(f'uuid\t{thisrun_uuid}\n')

    if Path(central_folder).exists():
        shutil.copy2(output_file, Path(central_folder,thisrun_uuid))
    return thisrun_uuid



def arg_parser() -> argparse.ArgumentParser:
    """Parse arguments

    Returns:
        parser: ArgumentParser object
    """
    parser = argparse.ArgumentParser(description='Parse commanline for bulkranseq pipeline')

    # String argument
    parser.add_argument('--input-yml', type=str, metavar='', help='yml setting file')
    parser.add_argument('--fastq_dir', type=str, metavar='', help='fastq directory')
    parser.add_argument('--work_dir', type=str, metavar='',
                        help='Target dir. Default: /scratch/users/<user>')
    parser.add_argument('--conda_env_name', metavar='', type=str, help='conda environment name')
    parser.add_argument('--species', choices=(
        "Canis_lupus_familiaris",
        "Chlorocebus_sabaeus",
        "Cricetulus_griseus",
        "Homo_sapiens",
        "Macaca_fascicularis",
        "Macaca_mulatta",
        "Mus_musculus",
        "Ovis_aries",
        "Ovis_aries_rambouillet",
        "Rattus_norvegicus"
        "Sus_scrofa"
        ), action='append', nargs='+',
        help='Species selection. May provide multiple species from the list. Default: Homo_sapiens')
    parser.add_argument('--arvados_project_uuid', type=str,
                        help='arvados project_uuid in which to store intermediate data and final output')
    parser.add_argument('--read_type', type=str, choices=('bcl', 'fastq'),
                        help='Type of read data. Default: fastq')
    parser.add_argument('--fastq_project_id', type=str,
                        help="Used for output naming. Default: 'smoketest'")
    parser.add_argument('--fastq_type', type=str, choices=('single', 'paired'),
                        help='Type of fastq data. Default: paired')
    parser.add_argument('--jobs_dir', type=str,
                        help='Subdirectory inside working directory where slurm jobs will be launched. Default: <work_dir>/jobs')
    parser.add_argument('--machine_type', type=str, choices=('single', 'slurm'),
                        help="Whether this will be a single job, or multiple launched through slurm. Default: slurm")
    parser.add_argument('--samples_tsv', metavar='', type=str, help='sample tsv file path, only applies to fastq input')
    parser.add_argument('--samples_tsv_column', metavar='', type=str,
                        help='sample tsv file column name for sample name, only applies to fastq input')
    parser.add_argument('--samples_yml', metavar='', type=str, help='sample yml file path, only applies to fastq input')
    parser.add_argument('--sequencing_center', metavar='', type=str,
                        help="This information will be used to create the readgroup CN tag during job creation. Default: 'unknown'")
    parser.add_argument('--sequencing_date', metavar='', type=str,
                        help='This information will be used to create the readgroup DT tag during job creation. Default: null')
    parser.add_argument('--sequencing_model', metavar='', type=str,
                        help='This information will be used to create the readgroup PM tag during job creation. Default: null')
    parser.add_argument('--sequencing_platform', metavar='', type=str,
                        help="This information will be used to create the readgroup PL tag during job creation. Default: 'ILLUMINA'")
    parser.add_argument('--slurm_partition', metavar='', type=str,
                        help='This string defines which slurm partion to use.')
    parser.add_argument('--slurm_template', metavar='', type=str,
                        help='This file defines a bunch of slurm settings such as timeout and number of cores per task etc. Default: <rnaseq_installation>/bulkrnaseq/bulkrnaseq/static_files/sbatch.template.sh')
    parser.add_argument('--umi_separator', metavar='', type=str,
                        help="Needed by deduplication. Regular User shall not change it unless you knew for sure. Default: ':'")

    # Digital arguments
    parser.add_argument('--thread_count', metavar='', type=int, choices=range(1, 33),
                        help='The number of cores to be used for each sample alignment. Default: 8')
    parser.add_argument('--bcl_only_lane', metavar='', type=int, choices=range(1, 17),
                        help='The value must be less than or equal to the number of lanes specified in the RunInfo.xml. Must be a single integer value. Default: null')
    parser.add_argument('--concurrent_jobs', metavar='', type=int, choices=range(1, 33),
                        help='Number of job can be launched curently in SGI. This parameter is not used in slurm. Default: 6')
    parser.add_argument('--retry_max', metavar='', type=int, choices=range(0, 11),
                        help='Maximum number of retries. If you do not want any retries, set this to 0. Default: 1')
    parser.add_argument('--slurm_timeout_hours', metavar='', type=int, choices=range(1, 48),
                        help='Maxumum time in hours before a slurm job will be killed. Default: 12')  
    parser.add_argument('--star_outBAMsortingBinsN', metavar='', type=int, choices=range(10, 2000),
                        help='--outBAMsortingBinsN used by star sorting. Default: 50')  
    parser.add_argument('--star_limitBAMsortRAM', metavar='', type=int,
                        help='--limitBAMsortRAM used by star storing, default is set up by Genome+SA+SAindex file size automatically. Default: 0')  
    
    # Boolean arguments
    parser.add_argument('--arvados_disable_reuse', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='arvados disable_reuse will cause all steps to be run, even if completed prior')
    parser.add_argument('--keep_cache', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you want to keep cache, False if otherwise. Default: True')
    parser.add_argument('--feature_jcount', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='This setting enables juncation calls of featureCounts for all samples. Default: True')
    parser.add_argument('--decoys', metavar='', type=str, action="append",
                        help='One or more decoys, which contain a RefSeq column to be used as decoy in the reference build')
    parser.add_argument('--featurecounts_gtf_attrtype', metavar='', type=str, choices=['exon_id', 'exon_number', 'exon_version', 'gene_biotype', 'gene_id', 'gene_source', 'gene_version', 'transcript_biotype', 'transcript_id', 'transcript_source', 'transcript_version'], action="append",
                        help='a character string giving the attribute type in the GTF annotation which will be used to count features. Default: gene_id')
    parser.add_argument('--featurecounts_gtf_featuretype', metavar='', type=str, choices=['CDS', 'exon', 'five_prime_utr', 'gene', 'Selenocysteine', 'start_codon', 'stop_codon', 'three_prime_utr', 'transcript'], action="append",
                        help='a character string giving the feature type in the GTF annotation which will be used to count features. Default: exon')
    parser.add_argument('--kallisto_enabled', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you want to enable Kallisto TPM quantification of transcripts, False if otherwise. Default: True')
    parser.add_argument('--kallisto_quant_bootstrap_samples', metavar='', type=int,
                        help='. Default: 5')
    parser.add_argument('--run_markduplicates', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you want to launch picard markduplication, False if otherwise. Default: False')
    parser.add_argument('--run_tpmcalculator', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you would like NCBI TPM Calculator to output counts, False if otherwise. Default: False')
    parser.add_argument('--run_variantcall_joint', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True or False, True if you want to launch joint variant call, False if otherwise. Default: False')
    parser.add_argument('--run_variantcall_single', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True or False, True if you want to launch single variant call, False if otherwise. Default: False')
    parser.add_argument('--stranded', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you want to launch strandness check, False if otherwise. Default: True')
    parser.add_argument('--umi_enabled', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True if you want to enable UMI, False if otherwise. Default: False')
    parser.add_argument('--use_existing_jobs', metavar='True/False', type=lambda x: bool(strtobool(x)),
                        help='True or False, Developer tool for debugging and return, for regulary user, choose False. Default: False')
    parser.add_argument('-v', '--version', action='version', version='%(prog)s {version}'.format(version=__version__))

    return parser


def whether_something(key: str, adict: dict) -> bool:
    """ Check if the the len(value) of the key in the dictionary is larger than 0

    """
    if key in adict:
        if adict[key] is None:
            return False
        elif len(adict[key].strip()) > 0:
            return True
    return False


def check_config(config: dict) -> None:
    """ Check if the config make sense

    """
    required_keys = ['work_dir']
    required_not_empty_keys = ['work_dir', 'species']

    if config['read_type'].lower == 'bcl':
        required_keys.append('bcl_inputs')
        required_not_empty_keys.append(['work_dir'])
    elif config['read_type'].lower == 'fastq':
        required_keys.append('fastq_dir')
        required_not_empty_keys.append(['fastq_dir'])
        if whether_something('sample_yml', config):
            if whether_something('samples_tsv', config) or whether_something('samples_tsv_column', config):
                logging.error(
                    'Since you are using sample_yml in configuration, sample_tsv and sample_column shall be empty!')
                sys.exit(1)
        elif not (whether_something('samples_tsv', config) and whether_something('samples_tsv_column', config)):
            logging.error('Since sample_yml is empty, you need to set up sample_tsv and sample_column')
            sys.exit(1)


    for i in required_keys:
        if not i in config:
            logging.error(f'{i} is required in the config file or commandline argument')
            sys.exit(1)

    for i in required_not_empty_keys:
        if not i in config:
            logging.error(f'{i} is required in the config file or commandline argument')
            sys.exit(1)
        else:
            if config[i] is None or len(config[i]) == 0:
                logging.error(f'{i} is required to be non-emtpy in the config file or commandline argument')
                sys.exit(1)
    if config['read_type'].lower == 'fastq':
        fastq_dir = config['fastq_dir']
        if not fastq_checking(fastq_dir):
            logging.error(f'fastq directory {fastq_dir} does not pass the validation!')
            sys.exit(1)


def load_default_config_from_static() -> dict:
    """ Load default config from default config file

    Returns:
        dictionary with arguments

    """
    basic_config_file = os.path.join(os.path.dirname(__file__), 'static_files', "yml_files", "default_settings.yml")
    config = parse_input(basic_config_file)
    logging.info(f"inside: {config}")
    config['bcl2fq_cwl'] = os.path.join(os.path.dirname(__file__), 'static_files', 'cwl_files',
                                        "bcl2fastq_transform.cwl")

    config['db_creds'] = os.path.join(os.path.dirname(__file__), 'static_files', 'yml_files', "db_creds.yml")

    config['generate_star_genome_cwl'] = os.path.join(os.path.dirname(__file__), 'static_files', 'cwl_files',
                                                      "generate_star_etl.cwl")
    config['star_align_cwl'] = os.path.join(os.path.dirname(__file__), 'static_files', 'cwl_files',
                                            "star_align_transform.cwl")
    config['joint_variantcall_cwl'] = os.path.join(os.path.dirname(__file__), 'static_files', 'cwl_files',
                                                   "joint_variantcall.cwl")
    config['project_cwl'] = os.path.join(os.path.dirname(__file__), 'static_files', 'cwl_files',
                                         "metrics.cwl")

    config['slurm_template'] = os.path.join(os.path.dirname(__file__), 'static_files', 'sbatch.template.sh')
    config['input_schema'] = os.path.join(os.path.dirname(__file__), 'static_files', 'validation_schema.json')
    
    return config


def input_validation(json_schema_file: str, input_dict: dict) -> None:
    """ Validate input arguments using provided json schema

    Args:
        json_schema_file: internal schema static file
        input_dict:  input dictiornary for argument
    """
    logging.info(f'json_schema_file: {json_schema_file}')
    with open(json_schema_file, 'r') as infile:
        schema_file_data = json.load(infile)
    try:
        validate(instance=input_dict, schema=schema_file_data)
    except SchemaError as e:
        logging.error("Internal Schema Error, Report to developer")
        logging.error(e)
        sys.exit(1)
    except ValidationError as e:
        logging.error("Input argument error, check your command line argument or yml file input")
        logging.error(e)
        sys.exit(1)


def fastq_checking(fastq_dir: str) -> bool:
    """ Do some basic checking for the fastq. More add

    Args:
        fastq_dir: the directory which has the fastq file inside of

    Returns:
        True: fastq directorey passed the validation.
        False: fastq directory does not pass the validation.
    """
    if not os.path.exists(fastq_dir):
        logging.error(f'{fastq_dir} does not exists')
        return False
    files = [file for file in os.scandir(fastq_dir) if file.is_file()]
    if len(files) == 0:
        logging.error(f'{fastq_dir} has no file in it')
        return False
    uncompressed_fastq_files = [file for file in files if
                                (file.name.lower().endswith('fastq') or file.name.lower().endswith('fq'))]
    if len(uncompressed_fastq_files) > 0:
        logging.error(
            f"{fastq_dir} has uncompressed fastq file in it! The pipeline can only take compressed fastq files as input")
        return False
    return True

def check_cli_config(namespace: argparse.ArgumentParser) -> dict:
    cli_config = vars(namespace)
    if not (whether_something('fastq_dir', cli_config) or whether_something('input_yml',
                                                                            cli_config) or whether_something(
            'samples_yml', cli_config)):
        arg_parser().error(
            'Error: No input data, Minimally, specify \"fastq_dir\", OR \"samples_yml\", OR --input-yml to specify input config file')
    if whether_something('fastq_dir', cli_config):
        if not (whether_something('samples_yml', cli_config)):
            if not whether_something('samples_tsv', cli_config):
                arg_parser().error("missing sample information samples_tsv for fastq input")
        if not whether_something('samples_tsv_column', cli_config):
            arg_parser().error("missing sample information samples_tsv_column for fastq input")
    for key, value in cli_config.copy().items():
        if value is None:
            del cli_config[key]
    return cli_config

def overwrite_default_config(cli_config: dict, input_file_config: dict) -> dict:
    config = load_default_config_from_static()
    logging.info(f'default_config: {config}')
    config.update(input_file_config)
    config.update(cli_config)
    # default_config['species'] = [default_config['species'][0]] if (isinstance(default_config['species'], list)) else [
    #     default_config['species']]
    user = try_or_None(['whoami']) if try_or_None(['whoami']) else 'unknown'
    if not 'work_dir' in config:
        config['work_dir'] = os.path.join(config['base_work_dir'], user)
    elif config['work_dir'] is None:
        config['work_dir'] = os.path.join(config['base_work_dir'], user)
    if not 'jobs_dir' in config:
        config['jobs_dir'] = os.path.join(config['work_dir'], 'jobs')
    elif config['jobs_dir'] is None:
        config['jobs_dir'] = os.path.join(config['work_dir'], 'jobs')
    if 'umi_separator' in config:
        if config['umi_separator'] is not None:
            if not 'umi_enabled' in config:
                logging.warning('ignoring umi_separator setting since umi_enabled is not turned on!')
            elif config['umi_enabled'] is False:
                logging.warning('ignoring umi_separator setting since umi_enabled is not turned on!')
    logging.debug(f'final config {config}')
    check_config(config)
    config['conda_env_name'] = Path(sys.exec_prefix).name
    config['sys_conda_path'] = get_conda_path()
    input_validation(config['input_schema'], config)
    if isinstance(config['species'], str):
        config['species'] = [config['species']]
    logging.info("Input arguments are validated")
    hostname = socket.gethostname()
    if hostname == 'eos':
        if config['machine_type'] == 'slurm':
            logging.warning('setting machine type to single by force since this machine does not support slurm')
            config['machine_type'] = 'single'
    logging.info('finished parsing input')
    logging.info(pprint.pformat(config))
    return config

def save_useful_dict(final_dict: dict, default_dict: dict, out_yml_file: str) -> None:
    """ Substract default_dict from final_dict and save the left over to another file

    Returns:
        dictionary substraction result
    """
    result_dict = {}
    for final_key in final_dict.keys():
        if final_key in default_dict:
            if not default_dict[final_key] == final_dict[final_key]:
                result_dict.update({final_key: final_dict[final_key]})
        else:
            result_dict.update({final_key: final_dict[final_key]})
    with open(out_yml_file, 'w') as outfile:
        yaml.dump(result_dict, outfile, default_flow_style=False)

def update_status(metrics_file: str, latest_status: str, thisrun_uuid: str, central_folder: str) -> None:
    with open(metrics_file, 'a') as out_f:
        out_f.write(f'latest_status\t{latest_status}\n')
        latest_time_stamp = try_or_None(['date']) if try_or_None(['date']) else None
        out_f.write(f'latest_time_stamp\t{latest_time_stamp}\n')
    if Path(central_folder).exists():
        with open(Path(central_folder, thisrun_uuid), 'a') as out_f:
            out_f.write(f'latest_status\t{latest_status}\n')
            latest_time_stamp = try_or_None(['date']) if try_or_None(['date']) else None
            out_f.write(f'latest_time_stamp\t{latest_time_stamp}\n')

def add_line(stringline: str, thisrun_uuid: str, metrics_file: str, central_folder: str) -> None:
    with open(metrics_file, 'a') as out_f:
        out_f.write(f'{stringline}\n')
    if Path(central_folder).exists():
        with open(Path(central_folder, thisrun_uuid), 'a') as out_f:
            out_f.write(f'{stringline}\n')

def get_conda_path():
    conda_path = try_or_None(['which', 'conda'])
    if conda_path is not None:
        return conda_path
    else:
        raise Exception("conda is not found")
