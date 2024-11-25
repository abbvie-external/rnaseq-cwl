#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: $(Math.ceil (inputs.input.size * 2.1 / 1048576))
    tmpdirMax: $(Math.ceil (inputs.input.size * 2.1 / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size * 2.1 / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size * 2.1 / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 0

outputs:
  - id: dir
    type: Directory
    outputBinding:
      glob: "*"

baseCommand: [tar, xf]
