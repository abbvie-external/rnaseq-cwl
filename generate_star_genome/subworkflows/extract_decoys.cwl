#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: decoy_tsv
    type: File

outputs:
  - id: fastas
    type:
      type: array
      items: File
    outputSource: extract_refseq/fasta
  - id: fasta_cdnas
    type:
      type: array
      items: File
    outputSource: extract_refseq/fasta_cdna
  - id: gtfs
    type:
      type: array
      items: File
    outputSource: extract_refseq/gtf

steps:
  - id: decoy_tsv_to_json
    run: tools/tsv_column_to_json_list.cwl
    in:
      - id: input_file
        source: decoy_tsv
      - id: column
        valueFrom: RefSeq
    out:
      - id: json

  - id: scatter_refseq_ids
    run: tools/expr_scatter_json_list.cwl
    in:
      - id: json
        source: decoy_tsv_to_json/json
    out:
      - id: values

  - id: extract_refseq
    run: extract_refseq.cwl
    scatter: refseq_id
    in:
      - id: refseq_id
        source: scatter_refseq_ids/values
    out:
      - id: fasta
      - id: fasta_cdna
      - id: gtf

