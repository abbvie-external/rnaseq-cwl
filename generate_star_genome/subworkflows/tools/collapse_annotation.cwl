#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseqc:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: $(Math.ceil (2 * inputs.gtf.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.gtf.size / 1048576))
    outdirMin: $(Math.ceil (inputs.gtf.size / 1048576))
    outdirMax: $(Math.ceil (inputs.gtf.size / 1048576))


class: CommandLineTool

inputs:
  - id: gtf
    type: File
    inputBinding:
      position: 0

outputs:
  - id: collapsed_gtf
    type: File
    outputBinding:
      glob: $(inputs.gtf.nameroot).collapsed.gtf

arguments:
  - valueFrom: $(inputs.gtf.nameroot).collapsed.gtf
    position: 1

baseCommand: [collapse_annotation.py]
