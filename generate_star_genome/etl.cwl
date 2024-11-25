#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement

inputs:
  - id: decoy_tsv_array
    type:
      type: array
      items: File
  - id: decoy_type_array
    type:
      type: array
      items: string
  - id: dbsnp_url_array
    type:
      type: array
      items: string
  - id: dbsnp_size_array
    type:
      type: array
      items: long
  - id: fasta_url_array
    type:
      type: array
      items: string
  - id: fasta_size_array
    type:
      type: array
      items: long
  - id: fasta_cdna_url_array
    type:
      type: array
      items: string
  - id: fasta_cdna_size_array
    type:
      type: array
      items: long
  - id: gtf_url_array
    type:
      type: array
      items: string
  - id: gtf_size_array
    type:
      type: array
      items: long
  - id: bedcutstring
    type: string
  - id: gtf_keyvalues
    type:
      type: array
      items: string
  - id: gtf_modname
    type: string
  - id: run_uuid
    type: string
  - id: species
    type: string
  - id: thread_count
    type: long

outputs:
  - id: dbsnp_index
    type: ["null", File]
    secondaryFiles:
      - .tbi
    outputSource: transform/dbsnp_index
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
  - id: genome_exonInfo_tab
    type: File
    outputSource: transform/genome_exonInfo_tab
  - id: genome_geneInfo_tab
    type: File
    outputSource: transform/genome_geneInfo_tab
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
  - id: ref_flat
    type: File
    outputSource: transform/ref_flat
  - id: rrna_intervallist
    type: File
    outputSource: transform/rrna_intervallist
  - id: fasta_index_dict
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    outputSource: transform/fasta_index_dict
  - id: fasta_cdna
    type: File
    outputSource: transform/fasta_cdna
  - id: gtf
    type: File
    outputSource: transform/gtf
  - id: collapsed_gtf
    type: File
    outputSource: transform/collapsed_gtf
  - id: collapsed_bed
    type: File
    outputSource: transform/collapsed_bed
  - id: kallisto_index
    type: File
    outputSource: transform/kallisto_indexed
  - id: kallisto_hawsh_index
    type: File
    outputSource: transform/kallisto_hawsh_indexed

steps:
  - id: extract
    run: extract.cwl
    in:
      - id: decoy_tsv_array
        source: decoy_tsv_array
      - id: dbsnp_url_array
        source: dbsnp_url_array
      - id: dbsnp_size_array
        source: dbsnp_size_array
      - id: fasta_url_array
        source: fasta_url_array
      - id: fasta_size_array
        source: fasta_size_array
      - id: fasta_cdna_url_array
        source: fasta_cdna_url_array
      - id: fasta_cdna_size_array
        source: fasta_cdna_size_array
      - id: gtf_url_array
        source: gtf_url_array
      - id: gtf_size_array
        source: gtf_size_array
    out:
      - id: dbsnp_array
      - id: fasta_array
      - id: fasta_cdna_array
      - id: gtf_array
      - id: decoy_fasta_array
      - id: decoy_fasta_cdna_array
      - id: decoy_gtf_array

  - id: transform
    run: transform.cwl
    in:
      - id: bedcutstring
        source: bedcutstring
      - id: dbsnp_array
        source: extract/dbsnp_array
      - id: fasta_array
        source: extract/fasta_array
      - id: decoy_fasta_array
        source: extract/decoy_fasta_array
      - id: fasta_cdna_array
        source: extract/fasta_cdna_array
      - id: decoy_fasta_cdna_array
        source: extract/decoy_fasta_cdna_array
      - id: decoy_type_array
        source: decoy_type_array
      - id: gtf_array
        source: extract/gtf_array
      - id: decoy_gtf_array
        source: extract/decoy_gtf_array
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
      - id: collapsed_bed
      - id: collapsed_gtf
      - id: dbsnp_index
      - id: fasta_cdna
      - id: fasta_index_dict
      - id: gtf
      - id: genome_chrLength_txt
      - id: genome_chrNameLength_txt
      - id: genome_chrName_txt
      - id: genome_chrStart_txt
      - id: genome_exonGeTrInfo_tab
      - id: genome_exonInfo_tab
      - id: genome_geneInfo_tab
      - id: genome_Genome
      - id: genome_genomeParameters_txt
      - id: genome_Log_out
      - id: genome_SA
      - id: genome_SAindex
      - id: genome_sjdbInfo_txt
      - id: genome_sjdbList_fromGTF_out_tab
      - id: genome_sjdbList_out_tab
      - id: genome_transcriptInfo_tab
      - id: ref_flat
      - id: rrna_intervallist
      - id: kallisto_indexed
      - id: kallisto_hawsh_indexed
