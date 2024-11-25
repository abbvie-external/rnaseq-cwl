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
    tmpdirMin: $(Math.ceil (2 * inputs.infile.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.infile.size / 1048576))
    outdirMin: $(Math.ceil (inputs.infile.size / 1048576))
    outdirMax: $(Math.ceil (inputs.infile.size / 1048576))

class: CommandLineTool

inputs:
  - id: infile
    type: File
    inputBinding:
      position: 99

  - id: extended_regexp
    type: ["null", boolean]
    inputBinding:
      prefix: --extended-regexp
      position: 1

  - id: invert_match
    type: ["null", boolean]
    inputBinding:
      prefix: --invert-match
      position: 2

  - id: word_regexp
    type: ["null", string]
    inputBinding:
      prefix: --word-regexp
      position: 3

outputs:
  - id: outfile
    type: File
    outputBinding:
      glob: $(inputs.infile.basename)

stdout: $(inputs.infile.basename)

baseCommand: [grep]
