#  BulkRnaSeq Pipeline

<strong> This pipeline is not intended for unexperienced users and does convey a level of responsibility to the user to be aware of fundamental issues, such as proper experimental design, which no pipeline can ascertain or rectify by itself. Further there might be data set specific steps required, e.g. accounting for donor effects, which cannot be covered in general.</strong>

This BulkRnaSeq Pipeline is created by the Abbive Bioinformatics Team to provide an accessible best-practices pipeline amenable to broad utilization for conventional RNAseq analyses.

This pipeline utilizes multiple open source bioinformatics software and uses as the workflow manager to connect those tools together.

# Introduction

The current supported computational environments are:

- slurm
- arvados
- single system

N.B. If you were using the `aggregate_counts` or `aggregate_jcounts` features, these options were changed `featurecounts_gtf_attrtype` and `featurecounts_junccount`, respectively. See the featureCounts sections below for more details.


# Process Flowchart

## BulkRnaSeq Workflow Overview
The BulkRnaSeq Workflow has four sub workflows. The orange boxes are inputs and blue boxes are outputs. 


#  Installation

```
cd ~
git clone https://<replace-me>/rnaseq-cwl.git
bash ~/rnaseq-cwl/install.sh
```

#  Usage

## Launch a test run using command line but not specifying work_dir:

The following starts a test run with the FASTQ directory as input (only gz compressed FASTQ files are supported). 
The result will be saved at the default location, which is /scratch/users/{username}.
The standard output will be printed to the screen.

```
cd ~
conda activate be_bulk_rnaseq
bulkrnaseq --fastq_dir  ~/rnaseq-cwl/demo/data/fastq --samples_tsv ~/rnaseq-cwl/demo/data/samples.tsv --samples_tsv_column SampleID

```


## Launch a test run using command line and specifying work_dir in command line:

The following starts a test run with the FASTQ directory as input (only gz compressed FASTQ files are supported). 
The result will be saved to the specified location (--work_dir).
The standard output can also be redirected to a specified file using '>'.
The user can also use `nohup` at the start and `&` at the end of the command to send the process to the background, and make it so that the process will not be killed if the terminal is closed. 
It is highly recommended to set your working directory in /scratch as the pipeline is much faster there. As files on /scratch are deleted after 30 days, please remember to move necessary output files to a different directory on completion.

```
cd ~
conda activate be_bulk_rnaseq
nohup bulkrnaseq --work_dir /scratch/users/${USER}/mytest --fastq_dir  ~/rnaseq-cwl/demo/data/fastq --samples_tsv ~/rnaseq-cwl/demo/data/samples.tsv --samples_tsv_column SampleID > ${HOME}/project.out &

```

## Launch a test run using yml file and specify work_dir in yml file

if you specify a parameter in both yml file and command line, the command line argument will overwrite the yml file argument.

```
cd ~
bash
conda activate be_bulk_rnaseq
nohup bulkrnaseq --input-yml ~/rnaseq-cwl/demo/config/minimal-bcl.yml > ${HOME}/project.out &

```

## Launch a run with umi turn on using yml file and specify work_dir in yml file

```
cd ~
conda activate be_bulk_rnaseq
nohup bulkrnaseq --input-yml ~/rnaseq-cwl/demo/config/minimal-bcl-umi.yml > ${HOME}/project.out &

```

## Check status of test run

```
# Check project level status
less -RM +F ${HOME}/project.out

```

#  Input

## Raw Data

Raw data should be either BCL or FASTQ (gz compressed).

### BCL
If you are using BCL raw data, rather than FASTQ, you must use a yml file to specify your input files, since a parameter such as `--bcl_inputs` is not yet supported on the command line.
For a BCL input run, the required parameters are `read_type` and `bcl_inputs`. An example of a BCL project using these parameters [is here](demo/config/minimal-bcl.yml)
Note that each `basecalls_dir` should be paired with one `samplesheet` file. 

If your project has more than one Illumina Flowcell, you may utilize each of those Flowcells within the context of a single run of the pipeline, which is called a multi-Flowcell project. Each of the BCL directories of a multi-Flowcell project will be converted to FASTQ files, those FASTQ files will be mapped with STAR, generating a BAM file for each read group, and then BAM files which belong to the same sample will be merged. All metrics and gene counts are performed on the final merged BAM. This will be done without any intervention required by the user - only the initial configuration must be made.

To specify a multi-Flowcell project, you must make use of the 2 specific options mentioned above: `read_type` and `bcl_inputs`. See [this file](demo/config/multi-bcl-umi.yml) as example. The spacing and syntax must be preserved as in the example. Each Flowcell is specified by 2 entries: a `basecalls_dir` and a `samplesheet`. Each Flowcell must be preceeded by a `-`, as shown in the example, even if there is just one Flowcell in the project. Any number of Flowcells are supported.


### FASTQ

There are two ways sample information can be setup for FASTQ input.
For users who want to use a `samples_yml` file, the required parameters are: `fastq_dir` and `samples_yml`. 
Or, if you don't want to use samples_yml, you can use the command line parameters `fastq_dir` , `samples_tsv` and `samples_tsv_column`. 
It is also strongly recommended for the user to use a `fastq_project_id`. This `fastq_project_id` will be used for output naming. Otherwise, the default is `smoketest`

#### Option 1.`samples_tsv`  +  `samples_tsv_column`

`samples_tsv` is a single-column or multi-column file with sample names. 
`samples_tsv_column` is the header column in the `samples_tsv` which corresonds to "sample name". 
The basename of the FASTQ files must start with their associated sample name. 
This pipeline will search for all FASTQ files in the directory, and match them up with the samples in the tsv.

<bold>If you have multiple readgroups per sample, some PE and some SE, then you have to use Option 2 to set up sample information </bold>.

Using this method, you can launch the application like this:

```
bulkrnaseq --work_dir /scratch/users/${USER}/mytest --fastq_dir  ~/rnaseq-cwl/demo/data/fastq --samples_tsv ~/rnaseq-cwl/demo/data/samples.tsv --samples_tsv_column SampleID
```

#### Option 2. `samples_yml`

`samples_yml` sets up forward and reverse FASTQ files for each sample individually.  Note: the `reverse_fastq` entries in the yml file is optional.

  [smoketest_sample_fastq.yml](rnaseq-cwl/blob/master/demo/data/smoketest_sample_fastq.yml)

Using this method, you can launch the application like this:

```
bulkrnaseq --work_dir /scratch/users/${USER}/mytest --samples_yml ~/rnaseq-cwl/demo/data/smoketest_sample_fastq.yml
```  

## Unique Molecular Identifiers (UMI) Information (Optional)

UMI-labeled reads are supported, and are deduplicated using UMI-tools. There are two configuration parameters that users may set to enable UMI processing: `umi_enabled` and `umi_separator`.

### BCL input

If UMI processing is to be configured with BCL reads, then simply setting `umi_enabled: True` in the yml config file, will enable the feature, as shown in [this example](demo/config/multi-bcl-umi.yml). If utilizing the CLI, then passing the flag `--umi_enabled True` will enable the same setting. With this setting alone, the BCL reads will be converted to FASTQ, mapped using STAR, deduplicated using UMI-tools, followed by the gathering of metrics and gene counts.

### FASTQ input

The pipeline uses Illumina's BCL Convert to convert BCL reads to FASTQ reads, and these reads contain the UMI tag as a string in [Field 1 of the FASTQ file](https://en.wikipedia.org/wiki/FASTQ_format#Format). BCL Convert places a `:` delimiter in Field 1 between the [Illumina Sequence Identified](https://en.wikipedia.org/wiki/FASTQ_format#Illumina_sequence_identifiers) and the UMI sequence. When the pipeline uses UMI-tools to deduplicate reads, the `umi_separator` flag is set to `:` by default, so users do not need to set `umi_separator` if their FASTQ files were generated with BCL Convert.

The older Illumina demultiplexing tool, bcl2fastq, places the UMI string in R2, with forward reads placed in R1 and reverse reads placed in R3. Some users run a script to merge the UMI strings from R2 into Field 1 of the forward and reverse reads. In this case, the script might use a `_` delimiter between the Illumina Sequence Identifier and the UMI string, which will require the user to set `umi_separator: _` in the yml config file, or set `--umi_separator _` on the CLI.


## Mark Duplication and featureCounts
Mark duplication using picard is turned on by default. However, featureCounts is configured to NOT take MD status of alignments into consideration when generating counts. This behavior is accomplished through the default settings of `run_markduplicates: True` and `featurecounts_ignoredup: False`. This combination allows users to see how many computationally predicted optical and non-optical duplicates are in their samples without affecting counts, [as many computationally identified duplicates of RNA-Seq reads are likely not to be PCR duplicates](https://www.nature.com/articles/srep25533). The MultiQC report contains the computational duplicate information in the Picard section. UMIs (section above) are the preferred method to handle PCR duplicates. If you would like featureCounts to ignore computationally identified duplicates when generating counts, then you may set `featurecounts_ignoredup: True`.

## Species selection
The workflow is designed to build an appropriate species reference genome, requiring the user to only enter the desired specicies name. By default, the workflow uses `Homo sapiens` as a reference, so most users will not need to even enter a species name.
First, the workflow will check if there is a reference subdirectory in the `<work_dir>`. For example, for human data the directory path would be `<work_dir>/homo_sapiens_star`, and for mouse data the directory path would be `<work_dir>/mus_musculus_star`.
Secondly, the workflow will verify if the necessary files exist in that reference genome folder.
Thirdly, if the reference genome folder is not validated, the workflow will try to rsync the corresponding genome directory from /projects/abv-ukb/shared-data/Engineering/ .
Fourthly, after the synchronization is done, the workflow will verify the reference genome folder again. 
Fifthly, if the reference genome folder is still not validated, the workflow will generate the index files using the config files located under `<install_dir>/rnaseq-cwl/bulkrnaseq/bulkrnaseq/static_files/yml_files`.

### Supported species, genome source and hybrid genomes
The workflow uses [ensembl](https://ensembl.orrg) fasta, gtf and vcf sources to build index files with STAR and KALLISTO. The supported species include:
 - `Canis_lupus_familiaris`
 - `Chlorocebus_sabaeus`
 - `Cricetulus_griseus`
 - `Homo_sapiens`
 - `Macaca_fascicularis`
 - `Macaca_mulatta`
 - `Mus_musculus`
 - `Ovis_aries`
 - `Ovis_aries_rambouillet`
 - `Rattus_norvegicu`
 - `Sus_scrofa`
The workflow supports read mapping to either a single genome species (typical) or to hybrid-species genomes. For example, if an experiment uses human tissue from a mouse environment, both `Homo sapiens` and `Mus musculus` references may be specified. The workflow will combine the reference fasta and gtf files before indexing them with STAR and KALLISTO.
To specify two species in the yml config, provide the species as list:
```
species:
  - Homo_sapiens
  - Mus_musculus
```
If instead of using the yml config, the user prefers to use the command line to configure their project, then the user may specify two species on the command line by providing two species flags:
```
bulkrnaseq --work_dir /scratch/users/${USER}/mytest --samples_yml ~/rnaseq-cwl/demo/data/smoketest_sample_fastq.yml --species homo_sapiens mus_musculus --samples_tsv_column SampleID
```

## Decoy Sequences
Note: If you would like to use viral decoy sequences, [please read the featureCounts section](#subread-featurecounts), and follow the instructions for the `featurecounts_gtf_featuretype` parameter.

The `decoys` parameter allows species-specific decoys to be incorporated into the fasta (genomic and cDNA) and GTF reference files, from which STAR and Kallisto indices are built. Currently, only human viral sequences are supported, but we are looking to include as many decoy sequence options as users would like. To include the viral decoys, include the following parameter in the input yml:
```
decoys:
  - virus
```
The current viral sequences that may be incorporated in the Homo sapiens reference are gien in the `RefSeq` column [of this file](rnaseq-cwl/blob/master/bulkrnaseq/bulkrnaseq/static_files/decoy/Homo_sapiens.virus.tsv).

## subread featureCounts

The workflow uses the the [subread featureCounts](https://subread.sourceforge.net/featureCounts.html) package to gather counts from the BAM, using a species-specifc GTF from ensembl as a gene model. Detailed subread documentation [is available](https://bioconductor.org/packages/release/bioc/vignettes/Rsubread/inst/doc/SubreadUsersGuide.pdf)

There are two attributes on which featureCounts may be configured: `featurecounts_gtf_attrtype` and `featurecounts_gtf_featuretype`.

If configured, `featurecounts_gtf_attrtype` *must* be set using YAML list notation. Valid values are `exon_id`, `exon_number`, `exon_version`, `gene_biotype`, `gene_id`, `gene_source`, `gene_version`, `transcript_biotype`, `transcript_id`, `transcript_source`, `transcript_version`. The default value is `['gene_id']`.

If configured, `featurecounts_gtf_featuretype` *must* be set using YAML list notation. Value values are `CDS`, `exon`, `five_prime_utr`, `gene`, `Selenocysteine`, `start_codon`, `stop_codon`, `three_prime_utr`, `transcript`. The default value is `['exon']`.

N.B. that most viral decoy sequences from NCBI are only countable if `gene` values are are counted. If you would like to count on both `exon` and `gene`, this can be done in YAML list noation as:
```
featurecounts_gtf_featuretype:
  - exon
  - gene
```


### Defaults and Configuration
No longer are featureCounts performed by default on all three of `transcript_id`, `exon_id` and `gene_id` attribute types of the GTF. Instead, the default is for counts to be performed only on the `gene_id` attribute. The `exon_id`, and `transcript_id` counts are computationally expensive in CPU-time, and were rarely used, with gene level counts being used by most scientists. Additionally, the transcript level counts are of dubious validity.

If users wish to gather counts on any of the enumerated items, other than the default `gene_id`, this may be accomplished by modifying the input yml, as in the following example, which implements the prior default behaviour:

```
featurecounts_gtf_attrtype:
  - exon_id
  - gene_id
  - transcript_id
```

Junction counts are disabled by default, but may be enabled using the parameter: `featurecounts_junccounts: True`

### Kallisto Configuration and Usage
If Kallisto is enabled with `kallisto_enabled: True`, then two outputs will be generated. The first is based upon abundance estimates *without* bootstrap estimates, and is called `<project_id>.kallisto_quant.abundance.tpm.tsv` The second is based *abundance esimates, bootstrap estimates, and transcript length information length* in which the abundance.hdf5 file is passed to `edgeR::catchKallisto()`, and the results are aggregated in `<project_id>.kallisto_quant.scaledcounts.tsv`
The default bootstrap samples is set to `10`. To modify this you may set the relevant parameter to another value, such as `kallisto_quant_bootstrap_samples: 20`. The default value of `10` was chosen, as it is [used by users who have interacted with the Kallisto author](https://github.com/pachterlab/kallisto/issues/236).


## Command line arguments
Most of the parameters can be set up through the command line except some complicated ones like 'bcl_inputs', which can only be set up through a config file.


## Config file
The config file is Optional. Instead of simply using command line parameters, the config file can provide more fine tuning to the application. If you did want to launch the application using a config file, there are multiple templates under test_config to help you start. 
To run the workflow with a config file, use the ‘-input_yml’ parameter.
Command line arguments have a higher priority than config file arguments. For example, if you are using a config file which contains “work_dir:abc” and also enter into the command line “--work_dir cdf”, the workflow will use ‘cdf’ as the work_dir.

#  Output
There are three sets of outputs: process stats outputs, project level outputs, and sample level outputs.
`work_dir` is not required to specify your output directory, but highly recommened.  If `work_dir` is not specified, /scratch/users/{user's 511} will be used as `work_dir`.

## Process Stats Outputs
Process stats output files are saved under `<work_dir>`
- launching_metrics.tsv
- conda_list.txt
- full_settings.yml
- used_setting.yml

## Project Level Outputs

Analysis output files are saved at the following location:
`<work_dir>/<project_id>/`

Project level output includes but is not limited to the following:
| Output filename | Description |
| --------------- | ----------- |
| <project_id>.<gtf_featuretype>.<gtf_attributetype>.counts.featurecount.tsv | subread featureCounts number of reads assigned to each featuretype, and grouped by attributetype |
| <project_id>.html | A MultiQC report |
| <project_id>.vcf.gz (if joint variant call is turned on) | Called variants using Broad best practices |
| <project_id>.project.<int>.err | A log file |
| <project_id>.project.<int>.out | A record of the outputs |
| <project_id>.rnaseqc.gene_tpm.tsv | TPM values reported by Broad's RNA-SeQC. |
| <project_id>_data | MultiQC metrics files |
| <project_id>.project/ | the working dir containing intermediate files generated by the workflow |
| <project_id>.kallisto_quant.abundance.tpm.tsv (if kallisto is turned on) | plaintext output from Kallisto quant |
| <project_id>.kallisto_quant.scaledcounts.tsv (if kallisto is turned on) | bootstrap output from Kallisto quant scaled with edgeR::catchKallisto() |


## Sample Level Output
Sample level output is saved under the project directory `<work_dir>/<project_id>/`.
  
Sample level output includes but is not limited to the following:
- <sample_id>.Aligned.sortedByCoord.out.bam or <sample_id>.Aligned.dedup.bam 
- <sample_id>.Aligned.sortedByCoord.out.bam.bai or <sample_id>.Aligned.dedup.bam.bai 
- <sample_id>.Aligned.sortedByCoord.out.vcf or <sample_id>.Aligned.dedup.vcf (if single variant call is turned on)
- <sample_id>_aligned.tar (all metrics files are compressed in this file, tpm results are included if tpmcalculator is turned on)
- <sample_id>.db
- <sample_id>.<int>.err
- <sample_id>.<int>.err
- <sample_id>
    - cachedir
    - tmp


#  FAQ

## Where are the logs?
The BulkRnaSeq pipeline will print out the high level log to the screen during the run, but you can redirect that log to any location as you like with the '>' operator (there are examples in the Usage Section).
There are also logs for each project and sample. 
The project logs are saved as  `<work_dir>/<project_id>/<project_id>.project.<int>.err`
The sample logs are saved as  `<work_dir>/<project_id>/<sample_id>.<int>.err`

## What if I have a problem installing or launching the application, or want to request new features?
Check [Issue Management](#issue-management)

## What are the default settings?
Check the default settings at: [default settings](rnaseq-cwl/settings.html)

# Issue Management

## Issue reporting
All issues (bugs, feature requests, etc.) should be reported as [github issues](rnaseq-cwl/issues). 
The Bioinformatics Engineer team actively monitors this issue reporting channel. 

### Potential Bug
When you report a potential bug, please include: 
1. Information to help developers reproduce the issue, such as launching command, environment, config file, sample tsv etc.
2. Why the result does not match your expectation. 
If it is identified as pipeline bug, the development team will create a hotfix version and merge into the master branch once the fix is verified. If it is a minor bug, then the fix will be included in the next release.
If it is an infrastructure or third party bug, the development team will help the user find a workaround. 

### Feature Requests
Feature requests will go through the planning meeting for next release. The issue reporter will be invited to the planning discussion meeting as a working group member.


# [Glossary](#glossary)

### [FASTA format](#fasta_format)
  Text-based format to represent genome sequences (nucleotide sequences or amino acid sequences). [source](https://en.wikipedia.org/wiki/FASTA_format)

### [FASTQ format](#fastq_format)
  Text-based format to represent nucleotide sequence and its corresponding quality scores. [source](https://en.wikipedia.org/wiki/FASTQ_format)

### [BCL binary base call Deconvolution](#bcl)
  Raw data files generated by the Illumina sequencer that can produce FASTQ files.

### [BAM Binary alignment map format](#bam)
  Binary version of a SAM file.

### [SAM format](#sam)
  TSV format that contains sequence alignment data.

### [VCF variant call format](#vcf)
  Text file for storing gene seq variations.

### [BED browser extensible data](#bed)
  Text file to store genomic regions as coordinates and associated annotations.

### [GTF gene transfer format](#gtf)
  TSV format based on GFF file format. Used to hold information about gene structure. 

### [GFF general feature format](#gff)
  Used for describing genes and other features of DNA, RNA and protein sequences.

### [featureCounts](#feature_counts)
  A tool to quantify RNA-seq and gDNA-seq data as counts. 

### [TPM transcripts per million](#tpm)
  Represents a normalized expression level that, in principle, should be comparable between samples.

### [DBSNP](#dbsnp)
  Single Nucleotide Polymorphism DB - public archive for genetic variation within and across different species.

### [Kallisto](#kallisto)
  A tool that quantifies abundances of transcripts from bulk and single-cell RNA-seq data. [github](https://pachterlab.github.io/kallisto/about)

### [Picard](#picard)
  A suite of command line tools for manipulating high-throughput sequencing data and formats such as SAM/BAM/CRAM and VCF. [github](https://broadinstitute.github.io/picard/)

### [UMI unique molecular identifier - tools](#umi)
  Contains tools for dealing with UMI/Random molecular tags (RMTs) and single cell RNA-seq cell barcodes.

### [allele](#allele)
  One or two or more alternative forms of a gene that arise by mutation and are found in the sample on a chromosome.

### [STAR spliced transcripts alignment to a reference](#star)
  A fast RNA-Seq read mapper, with support for splice-junction and fusion read detection. [source](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3530905/)

### [nucleotide](#nucleotide)
  Molecules that form the basic structural unit of nucleic acids such as DNA.

### [multiQC](#multiqc)
  A tool that aggregates results from bioinformatics analyses across many samples into a single report. [source](https://multiqc.info/)

### [UMI-tools](#umi-tools)
  Tools for handling Unique Molecular Identifiers in NGS data sets [source](https://github.com/CGATOxford/UMI-tools)

### [BCL Convert](#bclconvert)
  The Illumina BCL Convert v4.0 is a standalone local software app that converts the Binary Base Call (BCL) files produced by Illumina sequencing systems to FASTQ files. This is the replacement for bcl2fastq. [source](https://support-docs.illumina.com/SW/BCL_Convert_v4.0/Content/SW/BCLConvert/BCLConvert.htm)
  
### [bcl2fastq](#bcl2fastq)
  The Illumina bcl2fastq2 Conversion Software v2.20 demultiplexes sequencing data and converts base call (BCL) files into FASTQ files. [source](https://support.illumina.com/sequencing/sequencing_software/bcl2fastq-conversion-software.html)
