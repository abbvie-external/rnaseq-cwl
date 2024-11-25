import gzip
import logging
from pathlib import Path
import pprint
import sys

import arvados

from .create_samples import get_yml_samples_data
from .create_jobs import write_cwl_job, any_arvados_machines

'''
https://en.wikipedia.org/wiki/FASTQ_format#Illumina_sequence_identifiers
https://github.com/broadinstitute/picard/blob/master/testdata/picard/fingerprint/NA12891.over.fingerprints.shifted.for.crams.r1.sam
@A01016:49:HC5JTDRXX:2:2101:1524:1000 1:N:0:GACCTGAA+TTGGTGAG
'''
# TODO: This function needs to be rewriteen with exception handling and add unit test for it.
def get_readgroup_meta(fastq_path: Path, sample: str, arv_client: dict) -> dict:
    readgroup_meta = dict()
    if str(fastq_path).startswith('keep:'):
        c_uuid = str(fastq_path).split(':')[1].split('/')[0]
        path_string = str(fastq_path).split(':')[1]
        c_file = ('/').join(path_string.split('/')[1:])
        collection = arvados.collection.Collection(manifest_locator_or_text=c_uuid, api_client=arv_client)
        with collection.open(c_file, 'rb') as fq_open:
            if c_file.endswith('.fq') or c_file.endswith('.fastq'):
                fastq_line = fq_open.readline().decode().strip()
            elif c_file.endswith('.gz'):
                fq_decomp = gzip.GzipFile(fileobj=fq_open, mode='r')
                fastq_line = fq_decomp.readline().decode().strip()
    elif str(fastq_path).endswith('.gz'):
        with gzip.open(fastq_path, 'rb') as f_open:
            fastq_line = str(f_open.readline(), 'utf-8').strip('\n')
    elif str(fastq_path).endswith('.fq') or str(fastq_path).endswith('.fastq'):
        with open(fastq_path, 'rb') as f_open:
            fastq_line = str(f_open.readline(), 'utf-8').strip('\n')
    else:
        logging.error("fastq path does not end with .fq or .fastq")
        sys.exit(1)
    fastq_split = fastq_line.split(' ')
    # Short Read Archive (SRA/SRR) format
    if fastq_split[0].count(':') == 0 and fastq_split[1].count(':') == 6:
        #FIRST GROUP
        READ_ID = 0

        #SECOND GROUP
        UNIQUE_INSTRUMENT_NAME = 0
        FLOWCELL_ID = 2
        FLOWCELL_LANE = 3

        fastq_flowcell = fastq_split[1].split(':')
        readgroup_meta['ID'] = fastq_flowcell[FLOWCELL_ID][0:5] + '.' + fastq_flowcell[FLOWCELL_LANE]
        readgroup_meta['PU'] = readgroup_meta['ID']
        readgroup_meta['SM'] = sample
        readgroup_meta['LB'] = sample
    #This is illumina 1.8 format
    elif fastq_split[0].count(':') == 6 or fastq_split[0].count(':') == 7:
        UNIQUE_INSTRUMENT_NAME = 0
        FLOWCELL_ID = 2
        FLOWCELL_LANE = 3
        fastq_flowcell = fastq_split[0].split(':')

        readgroup_meta['ID'] = fastq_flowcell[FLOWCELL_ID].lstrip('@')[0:5] + '.' + fastq_flowcell[FLOWCELL_LANE]
        readgroup_meta['SM'] = sample
        if len(fastq_split) == 2 and fastq_split[1].count(':') == 3:
            INDEX_SEQ = 3
            fastq_index = fastq_split[1].split(':')

            readgroup_meta['BC'] = fastq_index[INDEX_SEQ].replace('+', '-')
            readgroup_meta['PU'] = fastq_flowcell[FLOWCELL_ID].lstrip('@') + '.' + fastq_flowcell[FLOWCELL_LANE] + '.' + fastq_index[INDEX_SEQ].replace('+', '-')
            readgroup_meta['LB'] = sample + '_' + fastq_index[INDEX_SEQ].replace('+', '-')
        elif len(fastq_split) == 3 and fastq_split[1].count(':') == 3:
            INDEX_SEQ = fastq_split[2]
            readgroup_meta['BC'] = INDEX_SEQ.replace('+', '-')
            readgroup_meta['PU'] = fastq_flowcell[FLOWCELL_ID].lstrip('@') + '.' + fastq_flowcell[FLOWCELL_LANE] + '.' + INDEX_SEQ
            readgroup_meta['LB'] = sample + '_' + INDEX_SEQ
        elif len(fastq_split) == 1:
            readgroup_meta['PU'] = fastq_flowcell[FLOWCELL_ID].lstrip('@') + '.' + fastq_flowcell[FLOWCELL_LANE]
            readgroup_meta['LB'] = sample
    elif fastq_split[0].count(':') == 4:
        UNIQUE_INSTRUMENT_NAME = 0
        FLOWCELL_LANE = 1
        fastq_flowcell = fastq_split[0].split(':')

        readgroup_meta['ID'] = fastq_flowcell[UNIQUE_INSTRUMENT_NAME].lstrip('@')[0:5] + '.' + fastq_flowcell[FLOWCELL_LANE]
        readgroup_meta['SM'] = sample
        readgroup_meta['PU'] = fastq_flowcell[UNIQUE_INSTRUMENT_NAME].lstrip('@') + '.' + fastq_flowcell[FLOWCELL_LANE]
        readgroup_meta['LB'] = sample

        if '#' in fastq_flowcell[4]:
            multiplex_pair = fastq_flowcell[4].split('#')[1]
            multiplex = multiplex_pair.split('/')[0]
            if (not multiplex.isdigit()) and len(multiplex) > 0:
                readgroup_meta['BC'] = multiplex                
    elif fastq_split[0].count(':') == 9:
        fastq_flowcell = fastq_split[0].split(':')
        FLOWCELL_id = 2
        FLOWCELL_LANE_id = 3

        Y_COORD, pair = fastq_split[0].split(':')[6].split('_')

        INDEX_SEQ,FORBACK = fastq_split[0].split(':')[9].split('/')

        readgroup_meta['ID'] = fastq_flowcell[FLOWCELL_id].lstrip('@')[0:5] + '.' + fastq_flowcell[FLOWCELL_LANE_id]
        readgroup_meta['SM'] = sample
        readgroup_meta['PU'] = fastq_flowcell[FLOWCELL_id].lstrip('@') + '.' + fastq_flowcell[FLOWCELL_LANE_id]+ '.' + INDEX_SEQ
        readgroup_meta['LB'] = sample + '_' + INDEX_SEQ
        readgroup_meta['BC'] = INDEX_SEQ
    else:
        logging.warning(f'WARNING: This fastq {fastq_path} does not contain Casava metadata')
        logging.warning(fastq_line)
        readgroup_meta['ID'] = readgroup_meta['LB'] = readgroup_meta['PU'] = readgroup_meta['SM'] = sample
    return readgroup_meta

def add_sample_data(job: dict, fastq_readgroup_list: list,
                    star_outBAMsortingBinsN: int, star_limitBAMsortRAM: int,
                    run_markduplicates: bool, run_tpmcalculator: bool,
                    run_variantcall_joint: bool, run_variantcall_single: bool, sequencing_center: str,
                    sequencing_date: str, sequencing_model: str, sequencing_platform: str,
                    variantcall_contigs, stranded, umi_enabled: bool, umi_separator: str,
                    kallisto_enabled: bool, kallisto_quant_bootstrap_samples: int,
                    transform_parameters) -> list: # featurecounts_junccounts: bool, featurecounts_gtf_attrtype: list,
                    # featurecounts_gtf_featuretype: list) -> list:
    logging.debug(f'fastq_readgroup_list: {pprint.pformat(fastq_readgroup_list)}')
    tp = transform_parameters
    if tp['featurecounts_gtf_attrtype']:
        job['cwl_data']['featurecounts_GTF_attrType'] = tp['featurecounts_gtf_attrtype']
        job['cwl_data']['featurecounts_GTF_featureType'] = tp['featurecounts_gtf_featuretype']
        if tp['featurecounts_junccounts']:
            job['cwl_data']['featurecounts_junccounts'] = True
        else:
            job['cwl_data']['featurecounts_junccounts'] = False
    else:
        job['cwl_data']['featurecounts_GTF_attrType'] = []
        job['cwl_data']['featurecounts_GTF_featureType'] = []
        job['cwl_data']['featurecounts_junccounts'] = False
    if 'featurecounts_allowmultioverlap' in tp:
        job['cwl_data']['featurecounts_allowmultioverlap'] = bool(tp['featurecounts_allowmultioverlap'])
    if 'featurecounts_byreadgroup' in tp:
        job['cwl_data']['featurecounts_byreadgroup'] = bool(tp['featurecounts_byreadgroup'])
    if 'featurecounts_countreadpairs' in tp:
        job['cwl_data']['featurecounts_countreadpairs'] = bool(tp['featurecounts_countreadpairs'])
    if 'featurecounts_checkfraglength' in tp:
        job['cwl_data'][''] = bool(tp['featurecounts_checkfraglength'])
    if 'featurecounts_countmultimappingreads' in tp:
        job['cwl_data']['featurecounts_countmultimappingreads'] = bool(tp['featurecounts_countmultimappingreads'])
    if 'featurecounts_fraction' in tp:
        job['cwl_data']['featurecounts_fraction'] = float(tp['featurecounts_fraction'])
    if 'featurecounts_fracoverlap' in tp:
        job['cwl_data']['featurecounts_fracoverlap'] = float(tp['featurecounts_fracoverlap'])
    if 'featurecounts_fracoverlapfeature' in tp:
        job['cwl_data']['featurecounts_fracoverlapfeature'] = float(tp['featurecounts_fracoverlapfeature'])
    if 'featurecounts_ignoredup' in tp:
        job['cwl_data']['featurecounts_ignoredup'] = bool(tp['featurecounts_ignoredup'])
    if 'featurecounts_islongread' in tp:
        job['cwl_data']['featurecounts_islongread'] = bool(tp['featurecounts_islongread'])
    if 'featurecounts_largestoverlap' in tp:
        job['cwl_data']['featurecounts_largestoverlap'] = long(tp['featurecounts_largestoverlap'])
    if 'featurecounts_minfraglength' in tp:
        job['cwl_data']['featurecounts_minfraglength'] = long(tp['featurecounts_minfraglength'])
    if 'featurecounts_maxfraglength' in tp:
        job['cwl_data']['featurecounts_maxfraglength'] = long(tp['featurecounts_maxfraglength'])
    if 'featurecounts_maxmop' in tp:
        job['cwl_data']['featurecounts_maxmop'] = long(tp['featurecounts_maxmop'])
    if 'featurecounts_minmqs' in tp:
        job['cwl_data']['featurecounts_minmqs'] = long(tp['featurecounts_minmqs'])
    if 'featurecounts_minoverlap' in tp:
        job['cwl_data']['featurecounts_minoverlap'] = long(tp['featurecounts_minoverlap'])
    if 'featurecounts_minoverlap' in tp:
        job['cwl_data']['featurecounts_minoverlap'] = long(tp['featurecounts_minoverlap'])
    if 'featurecounts_nonoverlap' in tp:
        job['cwl_data']['featurecounts_nonoverlap'] = long(tp['featurecounts_nonoverlap'])
    if 'featurecounts_nonoverlapfeature' in tp:
        job['cwl_data']['featurecounts_nonoverlapfeature'] = long(tp['featurecounts_nonoverlapfeature'])
    if 'featurecounts_nonsplitonly' in tp:
        job['cwl_data']['featurecounts_nonsplitonly'] = bool(tp['featurecounts_nonsplitonly'])
    if 'featurecounts_notcountchimericfragments' in tp:
        job['cwl_data']['featurecounts_notcountchimericfragments'] = bool(tp['featurecounts_notcountchimericfragments'])
    if 'featurecounts_primary' in tp:
        job['cwl_data']['featurecounts_primary'] = bool(tp['featurecounts_primary'])
    if 'featurecounts_read2pos' in tp:
        job['cwl_data']['featurecounts_read2pos'] = long(tp['featurecounts_read2pos'])
    if 'featurecounts_readextension3' in tp:
        job['cwl_data']['featurecounts_readextension3'] = long(tp['featurecounts_readextension3'])
    if 'featurecounts_readextension5' in tp:
        job['cwl_data']['featurecounts_readextension5'] = long(tp['featurecounts_readextension5'])
    if 'featurecounts_readshiftsize' in tp:
        job['cwl_data']['featurecounts_readshiftsize'] = long(tp['featurecounts_readshiftsize'])
    if 'featurecounts_readshifttype' in tp:
        job['cwl_data']['featurecounts_readshifttype'] = tp['featurecounts_readshifttype']
    if 'featurecounts_reportreads' in tp:
        job['cwl_data']['featurecounts_reportreads'] = tp['featurecounts_reportreads']
    if 'featurecounts_requirebothendsmapped' in tp:
        job['cwl_data']['featurecounts_requirebothendsmapped'] = bool(tp['featurecounts_requirebothendsmapped'])
    if 'featurecounts_splitonly' in tp:
        job['cwl_data']['featurecounts_splitonly'] = bool(tp['featurecounts_splitonly'])
    if 'featurecounts_usemetafeatures' in tp:
        job['cwl_data']['featurecounts_usemetafeatures'] = bool(tp['featurecounts_usemetafeatures'])
    if kallisto_enabled:
        job['cwl_data']['kallisto_enabled'] = True
    else:
        job['cwl_data']['kallisto_enabled'] = False
    if stranded:
        job['cwl_data']['stranded'] = True
    else:
        job['cwl_data']['stranded'] = False
    if variantcall_contigs is not None:
        job['cwl_data']['variantcall_contigs'] = variantcall_contigs
    else:
        job['cwl_data']['variantcall_contigs'] = list()
    if run_markduplicates:
        job['cwl_data']['run_markduplicates'] = True;
    else:
        job['cwl_data']['run_markduplicates'] = False;
    if run_tpmcalculator:
        job['cwl_data']['run_tpmcalculator'] = True;
    else:
        job['cwl_data']['run_tpmcalculator'] = False;
    if run_variantcall_joint:
        job['cwl_data']['run_variantcall_joint'] = True;
    else:
        job['cwl_data']['run_variantcall_joint'] = False
    if run_variantcall_single:
        job['cwl_data']['run_variantcall_single'] = True;
    else:
        job['cwl_data']['run_variantcall_single'] = False
    if star_outBAMsortingBinsN > 0:
        job['cwl_data']['star_outBAMsortingBinsN'] = star_outBAMsortingBinsN
    if star_limitBAMsortRAM > 0:
        job['cwl_data']['star_limitBAMsortRAM'] = star_limitBAMsortRAM
    for readgroup in fastq_readgroup_list:
        logging.debug(f'readgroup: {pprint.pformat(readgroup)}')
        if sequencing_center:
            readgroup['readgroup_meta']['CN'] = sequencing_center
        if sequencing_date:
            readgroup['readgroup_meta']['DT'] = sequencing_date
        if sequencing_model:
            readgroup['readgroup_meta']['PM'] = sequencing_model
        if sequencing_platform:
            readgroup['readgroup_meta']['PL'] = sequencing_platform
    job['cwl_data']['kallisto_quant_bootstrap_samples'] = kallisto_quant_bootstrap_samples
    job['cwl_data']['fastq_readgroup_list'] = fastq_readgroup_list
    job['cwl_data']['umi_enabled'] = umi_enabled
    job['cwl_data']['umi-separator'] = umi_separator
    logging.debug(f'job: {pprint.pformat(job)}')
    return job

def set_sample_outputs(job: dict, run_variantcall_joint: bool, run_variantcall_single: bool) -> dict:
    outputs = ['bam', 'sqlite', 'tar']
    if run_variantcall_joint or run_variantcall_single:
        outputs.append('variants')
    job['output_keys'] = outputs
    return job

def include_metadata(job: dict, star_genome_meta: dict) -> dict:
    logging.debug(f"inside include_metadata before update star, job-cwl_data:{job['cwl_data']}")
    logging.debug(f"inside include_metadata,before update star, star_genome_meta-cwl_outputs:{star_genome_meta['cwl_outputs']}")
    job['cwl_data'].update(star_genome_meta['cwl_outputs'])
    logging.debug(f"inside include_metadata after update star, job-cwl_data:{job['cwl_data']}")
    job['cwl_data']['thread_count'] = job['thread_count']
    job['cwl_data']['run_uuid'] = job['run_uuid']
    return job

def create_sample_jobs(samples_jobs_meta, samples_yml: Path, star_genome_meta: dict, fastq_type: str,
                       stranded: bool, star_outBAMsortingBinsN: int, star_limitBAMsortRAM: int,
                       run_markduplicates: bool, run_tpmcalculator: bool,
                       run_variantcall_joint: bool,run_variantcall_single: bool, variantcall_contigs: list, 
                       sequencing_center: str, sequencing_date: str, sequencing_model: str, sequencing_platform: str,
                       umi_enabled: bool, umi_separator: str, kallisto_enabled: bool, kallisto_quant_bootstrap_samples: int,
                       transform_parameters: dict) -> list:
    jobs = list()
    samples_data = get_yml_samples_data(samples_yml)
    if any_arvados_machines(samples_jobs_meta):
        arv_client = arvados.api('v1', ...)
    else:
        arv_client = dict()
    for i, job_meta in enumerate(samples_jobs_meta):
        logging.debug(f'\n\njob_meta:')
        logging.debug(pprint.pformat(job_meta))
        sample_readgroup_list = list()
        sample_readgroups = samples_data[job_meta['name']]
        for readgroup in sample_readgroups:
            job_readgroup = dict()
            readgroup_meta = get_readgroup_meta(readgroup['forward_fastq'], job_meta['name'], arv_client)
            job_readgroup['readgroup_meta'] = readgroup_meta
            job_readgroup['forward_fastq'] = {'class':'File','location': readgroup['forward_fastq']}
            if 'reverse_fastq' in readgroup:
                job_readgroup['reverse_fastq'] = {'class':'File','location': readgroup['reverse_fastq']}
            sample_readgroup_list.append(job_readgroup)

        job = include_metadata(job_meta, star_genome_meta)
        logging.debug(f"after include_metadata: {job['cwl_data']}")
        job = add_sample_data(job, sample_readgroup_list,
                              star_outBAMsortingBinsN, star_limitBAMsortRAM,
                              run_markduplicates, run_tpmcalculator,
                              run_variantcall_joint, run_variantcall_single, sequencing_center,
                              sequencing_date, sequencing_model, sequencing_platform,
                              variantcall_contigs, stranded, umi_enabled, umi_separator,
                              kallisto_enabled, kallisto_quant_bootstrap_samples,
                              transform_parameters)
        job = set_sample_outputs(job, run_variantcall_joint, run_variantcall_single)
        logging.debug(f"after set_sample_outputs: {job['cwl_data']}")
        write_cwl_job(job)
        jobs.append(job)
    return jobs
