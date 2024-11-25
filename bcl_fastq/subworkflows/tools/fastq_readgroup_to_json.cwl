#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: fastq
    type: File
    inputBinding:
      prefix: --fastq_path

  - id: sample
    type: string
    inputBinding:
      prefix: --sample

outputs:
  - id: json
    type: File
    outputBinding:
      glob: "*.json"

baseCommand: [python3, /usr/local/bin/fastq_readgroup_to_json.py]
