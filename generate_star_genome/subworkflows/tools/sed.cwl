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
    tmpdirMin: $(Math.ceil (2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 99

  - id: expression
    type: string
    inputBinding:
      prefix: -e
      position: 1

  - id: regexp-extended
    type: ["null", boolean]
    inputBinding:
      prefix: -E
      position: 0

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)

stdout: $(inputs.input.basename)

baseCommand: [sed]
