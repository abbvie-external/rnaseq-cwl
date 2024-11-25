#!/usr/bin/env cwl-runner

cwlVersion: v1.1

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: $(Math.ceil (2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size / 1048576))


class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*'

baseCommand: [tar, xf]
