#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(Math.ceil(inputs.thread_count / 4))
    coresMax: $(Math.ceil(inputs.thread_count / 4))
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl


class: CommandLineTool

inputs:
  - id: readgroup_umi
    type: readgroup.cwl#readgroup_umi

  - id: thread_count
    type: long

outputs:
  - id: forward_fastq
    type: File
    outputBinding:
      glob: "*_R1_*"

  - id: reverse_fastq
    type: File
    outputBinding:
      glob: "*_R2_*"

arguments:
  - valueFrom: $(inputs.readgroup_umi["forward_fastq"])
    prefix: --forward_fastq

  - valueFrom: $(inputs.readgroup_umi["reverse_fastq"])
    prefix: --reverse_fastq

  - valueFrom: $(inputs.readgroup_umi["umi_fastq"])
    prefix: --umi_fastq
      
baseCommand: [python3, /usr/local/bin/reheader_fastq.py]
