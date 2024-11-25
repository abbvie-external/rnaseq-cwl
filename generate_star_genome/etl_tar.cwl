#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bedcutstring
    type: string
  - id: fasta_url
    type: string
  - id: gtf_keyvalues
    type:
      type: array
      items: string
  - id: gtf_modname
    type: string
  - id: gtf_url
    type: string
  - id: run_uuid
    type: string
  - id: species
    type: string
  - id: thread_count
    type: long

outputs:
  - id: genome_chrLength_txt
    type: File
    outputSource: transform/genome_chrLength_txt
  - id: genome_chrNameLength_txt
    type: File
    outputSource: transform/genome_chrNameLength_txt
  - id: genome_chrName_txt
    type: File
    outputSource: transform/genome_chrName_txt
  - id: genome_chrStart_txt
    type: File
    outputSource: transform/genome_chrStart_txt
  - id: genome_exonGeTrInfo_tab
    type: File
    outputSource: transform/genome_exonGeTrInfo_tab
  - id: genome_Genome
    type: File
    outputSource: transform/genome_Genome
  - id: genome_genomeParameters_txt
    type: File
    outputSource: transform/genome_genomeParameters_txt
  - id: genome_Log_out
    type: File
    outputSource: transform/genome_Log_out
  - id: genome_SA
    type: File
    outputSource: transform/genome_SA
  - id: genome_SAindex
    type: File
    outputSource: transform/genome_SAindex
  - id: genome_sjdbInfo_txt
    type: File
    outputSource: transform/genome_sjdbInfo_txt
  - id: genome_sjdbList_fromGTF_out_tab
    type: File
    outputSource: transform/genome_sjdbList_fromGTF_out_tab
  - id: genome_sjdbList_out_tab
    type: File
    outputSource: transform/genome_sjdbList_out_tab
  - id: genome_transcriptInfo_tab
    type: File
    outputSource: transform/genome_transcriptInfo_tab
  - id: refflat
    type: File
    outputSource: transform/refflat
  - id: rrna_gtf
    type: File
    outputSource: transform/rrna_gtf

steps:
  - id: extract_fasta
    run: subworkflows/tools/curl.cwl
    in:
      - id: url
        source: fasta_url
    out:
      - id: output

  - id: untar_fasta
    run: subworkflows/tools/tar_extract_single.cwl
    in:
      - id: input
        source: extract_fasta/output
    out:
      - id: output

  - id: extract_gtf
    run: subworkflows/tools/curl.cwl
    in:
      - id: url
        source: gtf_url
    out:
      - id: output

  - id: decompress_gtf
    run: subworkflows/tools/gunzip.cwl
    in:
      - id: input
        source: extract_gtf/output
    out:
      - id: output

  - id: transform
    run: transform.cwl
    in:
      - id: bedcutstring
        source: bedcutstring
      - id: fasta
        source: untar_fasta/output
      - id: gtf
        source: decompress_gtf/output
      - id: gtf_keyvalues
        source: gtf_keyvalues
      - id: gtf_modname
        source: gtf_modname
      - id: run_uuid
        source: run_uuid
      - id: species
        source: species
      - id: thread_count
        source: thread_count
    out:
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
