#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 8000
    ramMax: 8000
    tmpdirMin: 100
    tmpdirMax: 100
    outdirMin: 100
    outdirMax: 100

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 10

class: CommandLineTool

inputs:
  - id: sample_dir
    type:
      type: array
      items: Directory
      inputBinding:
        prefix: --sample-dir

  - id: project_id
    type: string
    inputBinding:
      prefix: --project-id

  - id: data_type
    type:
      type: enum
      symbols:
        - eff_length
        - est_counts
        - length
        - tpm
    inputBinding:
      prefix: --data-type

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.project_id).kallisto_quant.abundance.$(inputs.data_type).tsv

baseCommand: [join_kallisto_quant.py]
