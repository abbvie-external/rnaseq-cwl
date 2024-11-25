#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: $(Math.ceil (inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.input.size / 1048576))
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 0

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).md5

stdout: $(inputs.input.nameroot).md5

baseCommand: [md5sum]
