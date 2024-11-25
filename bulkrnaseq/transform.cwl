#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: SchemaDefRequirement
    types:
      - $import: subworkflows/tools/sample.cwl

inputs:
  - id: fastq_dir
    type: [Directory, "null"]
  - id: samples_tsv
    type: [File, "null"]
  - id: samples_tsv_column
    type: [string, "null"]
  - id: fastq_yml
    type: [File, "null"]
  - id: genome_yml
    type: [File, "null"]
  - id: genome_dir
    type: [Directory, "null"]
  - id: generate_genome_cwl
    type: File
  - id: star_align_cwl
    type: File
  - id: project_id
    type: string
  - id: work_dir
    type: Directory
  - id: species
    type:
      - type: enum
        symbols:
          - Cricetulus griseus
          - Homo sapiens
          - Mus musculus
          - Rattus norvegicus
  - id: thread_count
    type: long
  - id: run_markduplicates
    type: boolean
  - id: sequencing_center
    type: string
  - id: sequencing_date
    type: string
  - id: sequencing_platform
    type: enum
    symbols:
      - CAPILLARY
      - HELICOS
      - IONTORRENT
      - ILLUMINA
      - LS454
      - ONT
      - PACBIO
      - SOLID
  - id: sequencing_model
    type:
      - type: enum
        symbols:
          - GAII
          - GAIIx
          - HiSeq 1500
          - HiSeq 2000
          - HiSeq 2500
          - HiSeq 3000
          - HiSeq 4000
          - HiSeq X Ten
          - MiniSeq
          - MiSeq
          - NextSeq 550
          - NextSeq 550Dx
          - NextSeq 2000
          - NovaSeq 6000

outputs:
  - id: genome
    type: [Directory, "null"]
    outputSource: 
  - id: aligned_samples
    type:
      type: array
      items: subworkflows/tools/sample.cwl#aligned_sample
  - id: multiqc_html
    type: File
    outputSource: metrics/multiqc_html
  - id: multiqc_data
    type: Directory
    outputSource: metrics/multiqc_data
  - id: project_featurecounts_ensg
    type: File
    outputSource: metrics/featurecounts_ensg
  - id: project_featurecounts_ense
    type: File
    outputSource: metrics/featurecounts_ense

steps:
  - id: generate_genome
    run: subworkflows/tools/generate_genome.cwl
    in:
      - id: genome_yml
        source: genome_yml
      - id: genome_dir
        source: genome_dir
      - id: generate_genome_cwl
        source: generate_genome_cwl
      - id: species
        source: species
       id: thread_count
       source: thread_count
    out:
      - id: collapsed_gtf
      - id: collapsed_bed
      - id: dbsnp_index
      - id: fasta_index_dict
      - id: genome_chrLength_txt
      - id: genome_chrNameLength_txt
      - id: genome_chrName_txt
      - id: genome_chrStart_txt
      - id: genome_exonGeTrInfo_tab
      - id: genome_Genome
      - id: genome_genomeParameters_txt
      - id: genome_Log_out
      - id: genome_SA
      - id: genome_SAindex
      - id: genome_sjdbInfo_txt
      - id: genome_sjdbList_fromGTF_out_tab
      - id: genome_sjdbList_out_tab
      - id: genome_transcriptInfo_tab
      - id: refflat
      - id: rrna_gtf
      - id: gtf

  - id: subworkflows/tools/align.cwl
    in:
      - id: fastq_dir
        source: fastq_dir
      - id: samples_tsv
        source: samples_tsv
      - id: samples_csv_column
        source: samples_csv_column
      - id: fastq_yml
        source: fastq_yml
      - id: star_align_cwl
        source: star_align_cwl
      - id: thread_count
        source: thread_count
      - id: run_markduplicates
        source: run_markduplicates
      - id: sequencing_center
        source: sequencing_center
      - id: sequencing_date
        source: sequencing_date
      - id: sequencing_platform
        source: sequencing_platform
      - id: sequencing_model
        source: sequencing_model
        
  - id: multiqc
    run: subworkflows/metrics.cwl
    in:
      - id: input
        source: untar/dir
    out:
      - id: html
      - id: data
      - id: ensg
      - id: ense
