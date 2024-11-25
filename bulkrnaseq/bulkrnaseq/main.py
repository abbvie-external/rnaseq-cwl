#!/usr/bin/env python3

import argparse
import getpass
import os
import pathlib
import pprint
import sys
import logging
import socket
import shutil
from pathlib import Path
from ruamel.yaml import YAML

from .create_jobs import create_jobs_meta
from .create_sample_jobs import create_sample_jobs
from .create_genome_job import create_star_genome
from .create_aggregation_job import create_project_job
from .create_bcl2fq_job import create_bcl2fq_job, get_bcl_project_id, get_runparameters_key
from .create_joint_variantcall_job import create_joint_vc_job

from .create_samples import create_samples_yml, get_yml_samples_data, get_bcl_samples_yml
from .run_jobs import run_jobs
from .verify_genome import verify_star_genome_installed, set_star_genome_outputs
from .util import (
    get_transform_parameters,
    get_ui_parameters,
    get_installed_version,
    parse_input,
    write_launching_metrics,
    try_or_None,
    arg_parser,
    check_config,
    whether_something,
    load_default_config_from_static,
    input_validation,
    check_cli_config,
    overwrite_default_config,
    save_useful_dict,
    update_status,
    add_line
)

from shutil import copytree
from functools import reduce


def main():
    # Replace this with input parameter parsing, default verboase shall be False
    verbose = True
    logging.basicConfig(
        level=logging.DEBUG if verbose is True else logging.INFO,
        format="%(asctime)s - {} - %(levelname)s - {} - %(module)s - %(funcName)s - %(lineno) - d[%(message)s]".format(
            getpass.getuser(), socket.gethostname()
        ),
        datefmt="%m/%d/%Y %I:%M:%S %p %Z",
        handlers=[logging.StreamHandler()],
    )
    commandline = " ".join(sys.argv)
    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
    )
    pkg_version = get_installed_version('bulkrnaseq')
    
    logging.info(f'bulkrnaseq version: {pkg_version}')
    logging.info(
        "**************************start preparing bulkrnaseq processing**************************"
    )
    logging.info(f"commandline:{commandline}")

    #####################################################################################
    namespace = arg_parser().parse_args()
    cli_config = check_cli_config(namespace)

    logging.debug(f"commandline config {cli_config}")

    #####################################################################################
    if whether_something("input_yml", cli_config):
        input_file_config = parse_input(cli_config["input_yml"])
        logging.debug(f"user config file config {input_file_config}")
    else:
        input_file_config = {}
    logging.debug(f"input yml config {input_file_config}")

    ############################################################################
    input_data = overwrite_default_config(cli_config, input_file_config)
    work_dir = Path(input_data["work_dir"])
    if not work_dir.exists():
        work_dir.mkdir(exist_ok=True, parents=True)
    launching_metrics_file = os.path.abspath(
        os.path.join(str(work_dir), "launching_metrics.tsv")
    )
    save_useful_dict(
        final_dict=input_data,
        default_dict=load_default_config_from_static(),
        out_yml_file=Path(work_dir, "used_setting.yml"),
    )
    yaml = YAML()
    with open(Path(work_dir, "full_settings.yml"), "w") as outfile:
        yaml.dump(input_data, outfile)
    thisrun_uuid = write_launching_metrics(
        launching_metrics_file, input_data["central_launching_stats"]
    )    
    add_line(stringline=f'commandline\t{commandline}',
             thisrun_uuid=thisrun_uuid, 
             metrics_file=launching_metrics_file, 
             central_folder=input_data["central_launching_stats"]
             )
    
    update_status(
        launching_metrics_file,
        "started",
        thisrun_uuid,
        input_data["central_launching_stats"],
    )
    conda_list = (
        try_or_None(["conda", "list"]) if try_or_None(["conda", "list"]) else ""
    )
    logging.info("conda_list")
    conda_list_file = Path(work_dir, "conda_list.txt")
    with open(conda_list_file, "a") as out_f:
        out_f.write(conda_list)
    if input_data['umi_enabled'] is True:
        try_or_None(['ulimit', '-s', 'unlimited'])
    #####################################################################
    # End CLI-vs-YML override setup
    #####

    (
        arvados_disable_reuse,
        bcl_inputs,
        bcl_only_lane,
        central_genome_dir,
        concurrent_jobs,
        conda_env_name,
        container,
        decoys,
        fastq_type,
        fastq_project_id,
        kallisto_enabled,
        kallisto_quant_bootstrap_samples,
        keep_cache,
        machine_type,
        read_type,
        remove_failed_samples,
        retry_max,
        run_markduplicates,
        run_tpmcalculator,
        run_variantcall_joint,
        run_variantcall_single,
        sequencing_center,
        sequencing_date,
        sequencing_model,
        sequencing_platform,
        slurm_partition,
        slurm_resource_mem,
        slurm_timeout_hours,
        sp_list,
        star_limitBAMsortRAM,
        star_outBAMsortingBinsN,
        sys_conda_path,
        thread_count,
        umi_enabled,
        umi_separator,
        use_existing_jobs,
        variantcall_contigs
    ) = (
        input_data["arvados_disable_reuse"],
        input_data["bcl_inputs"],
        input_data["bcl_only_lane"],
        input_data["central_genome_dir"],
        input_data["concurrent_jobs"],
        input_data["conda_env_name"],
        input_data["container"],
        input_data["decoys"],
        input_data["fastq_type"],
        input_data["fastq_project_id"],
        input_data["kallisto_enabled"],
        input_data["kallisto_quant_bootstrap_samples"],
        input_data["keep_cache"],
        input_data["machine_type"],
        input_data["read_type"],
        input_data["remove_failed_samples"],
        input_data["retry_max"],
        input_data["run_markduplicates"],
        input_data["run_tpmcalculator"],
        input_data["run_variantcall_joint"],
        input_data["run_variantcall_single"],
        input_data["sequencing_center"],
        input_data["sequencing_date"],
        input_data["sequencing_model"],
        input_data["sequencing_platform"],
        input_data["slurm_partition"],
        input_data["slurm_resource_mem"],
        input_data["slurm_timeout_hours"],
        input_data["species"],
        input_data["star_limitBAMsortRAM"],
        input_data["star_outBAMsortingBinsN"],
        input_data["sys_conda_path"],
        input_data["thread_count"],
        input_data["umi_enabled"],
        input_data["umi_separator"],
        input_data["use_existing_jobs"],
        input_data["variantcall_contigs"]
    )

    jobs_dir = Path(input_data["jobs_dir"])
    singularity_dir = Path(input_data["singularity_dir"])
    generate_star_genome_cwl = Path(input_data["generate_star_genome_cwl"])
    bcl2fq_cwl = Path(input_data["bcl2fq_cwl"])
    joint_variantcall_cwl = Path(input_data["joint_variantcall_cwl"])
    project_cwl = Path(input_data["project_cwl"])
    star_align_cwl = Path(input_data["star_align_cwl"])
    slurm_template = Path(input_data["slurm_template"])

    ui_parameters = get_ui_parameters(input_data)
    transform_parameters = get_transform_parameters(input_data)

    stranded = input_data.get("stranded") or None
    samples_tsv_column = input_data.get("samples_tsv_column")
    fastq_dir = Path(input_data.get("fastq_dir")) if input_data.get("fastq_dir") else None
    samples_yml = Path(input_data.get("samples_yml")) if input_data.get("samples_yml") else None
    samples_tsv = Path(input_data.get("samples_tsv")) if input_data.get("samples_tsv") else None
    species = reduce(lambda a,b:a+b, sp_list if isinstance(sp_list[0], list) else [sp_list]) if isinstance(sp_list, list) else [sp_list]
    species = [ x.replace(" ", "_").lower() for x in species ]
    species_concat = "_".join(species)
    if len(decoys) > 0:
        species_concat = species_concat+'.'+'.'.join(sorted(decoys))
    #######################
    # END GATHERING OPTIONS
    #######################

    ####################
    ### OPTION VALIDATION
    if run_variantcall_single and run_variantcall_joint:
        logging.error(
            "Both run_variantcall_single and run_variantcall_joint were activated."
        )
        logging.error("Only one variant call method may be activated")
        sys.exit(1)
    ####################
    logging.debug(f'work_dir: {work_dir}')

    star_out_dir = Path(work_dir, species_concat + '_star')
    star_work_dir = star_out_dir
    star_outputs = None
    star_project_name = None
    star_genome_meta = create_jobs_meta([species_concat], species, jobs_dir, star_out_dir, star_work_dir,
                                        keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                        retry_max, use_existing_jobs, star_outputs, singularity_dir,
                                        slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                        conda_env_name, star_project_name, generate_star_genome_cwl,
                                        'generate_star_genome_cwl', ui_parameters,
                                        remove_failed_samples, decoys, arvados_disable_reuse)[0]

    logging.debug('\n\nstar_genome_meta:')
    logging.debug(pprint.pformat(star_genome_meta))
    star_genome_meta = set_star_genome_outputs(star_genome_meta)
    star_genome_meta = verify_star_genome_installed(star_genome_meta)
    if (not star_genome_meta['verified']) and (
        Path(central_genome_dir, species_concat + "_star").exists()
    ):
        logging.info("star genome not verified, will be synced")
        copytree(
            Path(central_genome_dir, species_concat + "_star"),
            Path(work_dir, species_concat + "_star"),
            dirs_exist_ok=True
        )
        star_genome_meta = verify_star_genome_installed(star_genome_meta)
        logging.debug('\n\nstar_genome_meta:')
        logging.debug(pprint.pformat(star_genome_meta))

    logging.info(f'star_genome_meta["verified"]: {star_genome_meta["verified"]}')

    if not star_genome_meta['verified']:
        logging.info('create genome job and run:')
        star_genome_job = create_star_genome(star_genome_meta)
        star_genome_job = run_jobs([star_genome_job])[0]
        star_genome_job = verify_star_genome_installed(star_genome_job)
        if not star_genome_job['verified']:
            logging.error("star genome build failed")
            sys.exit(1)

    if read_type == "bcl":
        bcl_project_id = get_bcl_project_id(bcl_inputs)
        project_id = bcl_project_id
        bcl2fq_work_dir = Path(work_dir, bcl_project_id + '_bcl2fq')
        bcl2fq_out_dir = bcl2fq_work_dir
        bcl2fq_outputs = None
        bcl2fq_job_meta = create_jobs_meta([bcl_project_id], species, jobs_dir, bcl2fq_out_dir, bcl2fq_work_dir,
                                            keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                            retry_max, use_existing_jobs, bcl2fq_outputs, singularity_dir,
                                            slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                            conda_env_name, bcl_project_id, bcl2fq_cwl, 'bcl2fq_cwl',
                                            ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)[0]
        bcl2fq_job = create_bcl2fq_job(bcl2fq_job_meta, bcl_inputs, bcl_only_lane, sequencing_center)
        bcl2fq_job = run_jobs([bcl2fq_job])[0]
        bcl_samples_yml = get_bcl_samples_yml(bcl2fq_job)
        bcl_samples_data = get_yml_samples_data(bcl_samples_yml)
        sample_names = sorted(list(bcl_samples_data.keys()))

        sample_bcl_work_dir = Path(work_dir, bcl_project_id)
        sample_bcl_out_dir = sample_bcl_work_dir
        sample_bcl_outputs = None        
        sample_bcl_jobs_meta = create_jobs_meta(sample_names, species, jobs_dir, sample_bcl_out_dir, sample_bcl_work_dir,
                                                keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                                retry_max, use_existing_jobs, sample_bcl_outputs, singularity_dir,
                                                slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                                conda_env_name, bcl_project_id, star_align_cwl, 'star_align_cwl',
                                                ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)
        sample_jobs = create_sample_jobs(sample_bcl_jobs_meta, bcl_samples_yml, star_genome_meta, fastq_type,
                                         stranded, star_outBAMsortingBinsN, star_limitBAMsortRAM,
                                         run_markduplicates, run_tpmcalculator,
                                         run_variantcall_joint, run_variantcall_single, variantcall_contigs,
                                         sequencing_center, sequencing_date, sequencing_model, sequencing_platform,
                                         umi_enabled, umi_separator, kallisto_enabled, kallisto_quant_bootstrap_samples,
                                         transform_parameters)

    elif read_type == "fastq":
        project_id = fastq_project_id
        if not samples_yml:
            if not samples_tsv:
                logging.error(
                    "if --samples-yml is not specified, --samples_tsv, --samples_tsv_column and fastq_dir must be specified"
                )
                logging.error(f"{samples_tsv} is missing")
                sys.exit(1)
            if not samples_tsv_column:
                logging.error(
                    "if --samples-yml is not specified, --samples_tsv, --samples_tsv_column and fastq_dir must be specified"
                )
                logging.error(f"{samples_tsv_column} is missing")
                sys.exit(1)
            if not fastq_dir:
                logging.error(
                    "if --samples-yml is not specified, --samples_tsv, --samples_tsv_column and fastq_dir must be specified"
                )
                logging.error(f"{fastq_dir} is missing")
                sys.exit(1)
            samples_yml = create_samples_yml(
                fastq_project_id,
                fastq_dir,
                samples_tsv,
                samples_tsv_column,
                fastq_type,
                ["_", "."],
                jobs_dir,
            )

        samples_data = get_yml_samples_data(samples_yml)
        sample_names = sorted(list(get_yml_samples_data(samples_yml).keys()))
        sample_work_dir = Path(work_dir, project_id)
        sample_out_dir = Path(work_dir, project_id)
        sample_outputs = None
        sample_project_name = fastq_project_id
        sample_jobs_meta = create_jobs_meta(sample_names, species, jobs_dir, sample_out_dir, sample_work_dir,
                                            keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                            retry_max, use_existing_jobs, sample_outputs, singularity_dir,
                                            slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                            conda_env_name, sample_project_name, star_align_cwl, 'star_align_cwl',
                                            ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)
        sample_jobs = create_sample_jobs(sample_jobs_meta, samples_yml, star_genome_meta, fastq_type,
                                         stranded, star_outBAMsortingBinsN, star_limitBAMsortRAM,
                                         run_markduplicates, run_tpmcalculator,
                                         run_variantcall_joint, run_variantcall_single, variantcall_contigs,
                                         sequencing_center, sequencing_date, sequencing_model, sequencing_platform,
                                         umi_enabled, umi_separator, kallisto_enabled, kallisto_quant_bootstrap_samples,
                                         transform_parameters)
    else:
        logging.info(f"unknown `read_type`: {read_type} \t use `bcl` or `fastq`")
    update_status(
        launching_metrics_file,
        "preprocess_complete",
        thisrun_uuid,
        input_data["central_launching_stats"],
    )
    logging.info(
        "**************************finished preparing bulkrnaseq processing**************************"
    )
    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
    )

    # ALIGN SAMPLES

    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
    )
    logging.info(
        "**************************starting bulkrnaseq per sample processing**************************"
    )
    sample_jobs = run_jobs(sample_jobs)

    logging.info(
        "**************************finished bulkrnaseq per sample processing**************************"
    )
    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
    )

    update_status(
        launching_metrics_file,
        "sample_complete",
        thisrun_uuid,
        input_data["central_launching_stats"],
    )

    # JOINT GENOTYPING
    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------"
    )
    logging.info(
        "**************************starting bulkrnaseq joint variantcall processing**************************"
    )
    if run_variantcall_joint:
        project_work_dir = work_dir
        project_out_dir = Path(work_dir, project_id)
        project_outputs = None
        vc_project_name = fastq_project_id
        vc_job_name = vc_project_name+'.joint_variantcall'
        joint_vc_meta = create_jobs_meta([vc_job_name], species, jobs_dir, project_out_dir, project_work_dir,
                                          keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                          retry_max, use_existing_jobs, project_outputs, singularity_dir,
                                          slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                          conda_env_name, vc_project_name, joint_variantcall_cwl, 'joint_variantcall_cwl',
                                          ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)[0]
        joint_vc_job = create_joint_vc_job(joint_vc_meta, sample_jobs, star_genome_meta)
        joint_vc_job = run_jobs([joint_vc_job])
    logging.info('**************************finished bulkrnaseq joint variantcall processing**************************')
    print('-----------------------------------------------------------------------------------------------------------------------------------------------------------------')

    # MULTIQC and MERGE STATS
    print('-----------------------------------------------------------------------------------------------------------------------------------------------------------------')
    logging.info('**************************starting bulkrnaseq per project processing**************************')
    project_work_dir = Path(work_dir, project_id)
    project_out_dir = project_work_dir
    project_outputs = None
    aggr_project_name = project_id
    aggr_job_name = aggr_project_name+'.project'
    project_meta = create_jobs_meta([aggr_job_name], species, jobs_dir, project_out_dir, project_work_dir,
                                    keep_cache, machine_type, concurrent_jobs, thread_count, container,
                                    retry_max, use_existing_jobs, project_outputs, singularity_dir,
                                    slurm_partition, slurm_template, slurm_resource_mem, slurm_timeout_hours,
                                    conda_env_name, aggr_project_name, project_cwl, 'project_cwl',
                                    ui_parameters, remove_failed_samples, decoys, arvados_disable_reuse)[0]
    project_job =  create_project_job(project_meta, sample_jobs, kallisto_enabled, run_tpmcalculator,
                                      transform_parameters)
    project_job = run_jobs([project_job])[0]
    logging.info('**************************finished bulkrnaseq per project processing**************************')
    print('-----------------------------------------------------------------------------------------------------------------------------------------------------------------')
    if read_type == 'bcl':
        logging.info(f'SUCCESSFULY COMPLETE BCL PROJECT: {bcl_project_id}')
    elif read_type == 'fastq':
        logging.info(f'SUCCESSFULY COMPLETE FASTQ PROJECT: {fastq_project_id}')

    end_time = try_or_None(['date']) if try_or_None(['date']) else None
    update_status(launching_metrics_file, 'project_complete', thisrun_uuid, input_data['central_launching_stats'])
    with open(launching_metrics_file, 'a') as out_f:
        out_f.write(f'end_time\t{end_time}\n')
    if Path(input_data['central_launching_stats']).exists():
        with open(Path(input_data['central_launching_stats'], thisrun_uuid), 'a') as out_f:
            out_f.write(f'end_time\t{end_time}\n')
    return


if __name__ == "__main__":
    main()
