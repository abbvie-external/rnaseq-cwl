#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: $(Math.ceil (10 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (10 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (10 * inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (10 * inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

  - id: to-stdout
    type: boolean
    default: true
    inputBinding:
      prefix: --to-stdout
      
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot)

stdout: $(inputs.input.nameroot)

baseCommand: [gunzip]
