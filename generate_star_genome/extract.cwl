#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: decoy_tsv_array
    type:
      type: array
      items: File
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

outputs:
  - id: dbsnp_array
    type:
      type: array
      items: File
    outputSource: decompress_dbsnp/output
  - id: fasta_array
    type:
      type: array
      items: File
    outputSource: decompress_fasta/output
  - id: fasta_cdna_array
    type:
      type: array
      items: File
    outputSource: decompress_fasta_cdna/output
  - id: gtf_array
    type:
      type: array
      items: File
    outputSource: decompress_gtf/output

  - id: decoy_fasta_array
    type:
      type: array
      items: File
    outputSource: output_array_fastas/output
  - id: decoy_fasta_cdna_array
    type:
      type: array
      items: File
    outputSource: output_array_fasta_cdnas/output
  - id: decoy_gtf_array
    type:
      type: array
      items: File
    outputSource: output_array_gtfs/output

steps:
  - id: extract_dbsnp
    run: subworkflows/tools/curl.cwl
    scatter: [url, file_size]
    scatterMethod: "dotproduct"
    in:
      - id: url
        source: dbsnp_url_array
      - id: file_size
        source: dbsnp_size_array
    out:
      - id: output

  - id: decompress_dbsnp
    run: subworkflows/tools/gunzip.cwl
    scatter: input
    in:
      - id: input
        source: extract_dbsnp/output
    out:
      - id: output

  - id: extract_fasta
    run: subworkflows/tools/curl.cwl
    scatter: [url, file_size]
    scatterMethod: "dotproduct"
    in:
      - id: url
        source: fasta_url_array
      - id: file_size
        source: fasta_size_array
    out:
      - id: output

  - id: decompress_fasta
    run: subworkflows/tools/gunzip.cwl
    scatter: input
    in:
      - id: input
        source: extract_fasta/output
    out:
      - id: output

  - id: extract_fasta_cdna
    run: subworkflows/tools/curl.cwl
    scatter: [url, file_size]
    scatterMethod: "dotproduct"
    in:
      - id: url
        source: fasta_cdna_url_array
      - id: file_size
        source: fasta_cdna_size_array
    out:
      - id: output

  - id: decompress_fasta_cdna
    run: subworkflows/tools/gunzip.cwl
    scatter: input
    in:
      - id: input
        source: extract_fasta_cdna/output
    out:
      - id: output

  - id: extract_gtf
    run: subworkflows/tools/curl.cwl
    scatter: [url, file_size]
    scatterMethod: "dotproduct"
    in:
      - id: url
        source: gtf_url_array
      - id: file_size
        source: gtf_size_array
    out:
      - id: output

  - id: decompress_gtf
    run: subworkflows/tools/gunzip.cwl
    scatter: input
    in:
      - id: input
        source: extract_gtf/output
    out:
      - id: output

  - id: extract_decoys
    run: subworkflows/extract_decoys.cwl
    scatter: decoy_tsv
    in:
      - id: decoy_tsv
        source: decoy_tsv_array
    out:
      - id: fastas
      - id: fasta_cdnas
      - id: gtfs

  - id: output_array_fastas
    run: subworkflows/tools/expr_output_array.cwl
    in:
      - id: input
        source: extract_decoys/fastas
    out:
      - id: output

  - id: output_array_fasta_cdnas
    run: subworkflows/tools/expr_output_array.cwl
    in:
      - id: input
        source: extract_decoys/fasta_cdnas
    out:
      - id: output

  - id: output_array_gtfs
    run: subworkflows/tools/expr_output_array.cwl
    in:
      - id: input
        source: extract_decoys/gtfs
    out:
      - id: output
