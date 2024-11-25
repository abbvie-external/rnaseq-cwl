#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/edaseq-scripts:latest
  - class: InlineJavascriptRequirement

class: CommandLineTool

inputs:
  - id: bam
    type:
      type: array
      items: File
      inputBinding:
        prefix: --bam

outputs: []

baseCommand: [bam_reads_barplot.r]
