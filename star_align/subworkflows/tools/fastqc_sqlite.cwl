#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/fastqc-sqlite:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: $(Math.ceil (2 * (inputs.fastqc_data_txt.size + inputs.summary_txt.size) / 1048576))
    tmpdirMax: $(Math.ceil (2 * (inputs.fastqc_data_txt.size + inputs.summary_txt.size) / 1048576))
    outdirMin: $(Math.ceil ((inputs.fastqc_data_txt.size + inputs.summary_txt.size) / 1048576))
    outdirMax: $(Math.ceil ((inputs.fastqc_data_txt.size + inputs.summary_txt.size) / 1048576))

class: CommandLineTool

inputs:
  - id: fastqc_data_txt
    type: File
    inputBinding:
      prefix: --fastqc_data_txt

  - id: summary_txt
    type: File
    inputBinding:
      prefix: --summary_txt

  - id: job_uuid
    type: string
    inputBinding:
      prefix: --job_uuid

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".log")

  - id: output
    type: File
    outputBinding:
      glob: fastqc.db

          
baseCommand: [fastqc_sqlite]
