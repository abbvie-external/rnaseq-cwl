#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/bedops:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (2 * inputs.gtf.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.gtf.size / 1048576))
    outdirMin: $(Math.ceil (inputs.gtf.size / 1048576))
    outdirMax: $(Math.ceil (inputs.gtf.size / 1048576))

class: CommandLineTool

inputs:
  - id: gtf
    type: File

outputs:
  - id: bed
    type: File
    outputBinding:
      glob: $(inputs.gtf.nameroot).bed

stdin: $(inputs.gtf.path)

stdout: $(inputs.gtf.nameroot).bed

arguments:
  - valueFrom: .
    prefix: -r

baseCommand: [gtf2bed]
