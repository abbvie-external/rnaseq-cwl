#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: project_id
    type: string
  - id: sample_dirs
    type:
      type: array
      items: Directory

outputs:
  - id: tpm_tsv
    type: File
    outputSource: aggregate_tpm/output
  - id: scaledcounts_tsv
    type: File
    outputSource: aggregate_scaledcounts/output
  - id: zpca_tpm_dir
    type: Directory
    outputSource: zpca_tpm/output
  - id: zpca_scaledcounts_dir
    type: Directory
    outputSource: zpca_scaledcounts/output

steps:
  - id: aggregate_tpm
    run: tools/aggregate_kallisto_quant.cwl
    in:
      - id: data_type
        valueFrom: "tpm"
      - id: project_id
        source: project_id
      - id: sample_dir
        source: sample_dirs
    out:
      - id: output

  - id: aggregate_scaledcounts
    run: tools/aggregate_kallisto_quant_scaledcounts.cwl
    in:
      - id: project_id
        source: project_id
      - id: sample_dir
        source: sample_dirs
    out:
      - id: output

  - id: zpca_tpm
    run: tools/zpca_tpm.cwl
    in:
      - id: tpm
        source: aggregate_tpm/output
      - id: out
        valueFrom: zpca_tpm
    out:
      - id: output
    
  - id: zpca_scaledcounts
    run: tools/zpca_tpm.cwl
    in:
      - id: tpm
        source: aggregate_scaledcounts/output
      - id: out
        valueFrom: zpca_scaledcounts
    out:
      - id: output
