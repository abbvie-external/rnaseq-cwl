#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/samtools:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 99
    secondaryFiles:
      - ^.bai

  - id: min-read-len
    type: ["null", long]
    inputBinding:
      prefix: --min-read-len
      position: 0

  - id: min-MQ
    type: ["null", long]
    inputBinding:
      prefix: --min-MQ
      position: 1

  - id: min-BQ
    type: ["null", long]
    inputBinding:
      prefix: --min-BQ
      position: 2

  - id: incl-flags
    type: ["null", string]
    inputBinding:
      prefix: --incl-flags
      position: 3

  - id: excl-flags
    type:
      - "null"
      - type: enum
        symbols:
          - UNMAP
          - SECONDARY
          - QCFAIL
          - DUP
    inputBinding:
      prefix: --excl-flags
      position: 4

  - id: depth
    type: ["null", long]
    inputBinding:
      prefix: --depth
      position: 5

  - id: histogram
    type: ["null", boolean]
    inputBinding:
      prefix: --histogram
      position: 6

  - id: ascii
    type: ["null", boolean]
    inputBinding:
      prefix: --ascii
      position: 7

  - id: output
    type: ["null", string]
    inputBinding:
      prefix: --output
      position: 8

  - id: no-header
    type: ["null", boolean]
    inputBinding:
      prefix: --no-header
      position: 9

  - id: n-bins
    type: ["null", long]
    inputBinding:
      prefix: --n-bins
      position: 10

  - id: region
    type: ["null", string]
    inputBinding:
      prefix: --region
      position: 11          

outputs:
  - id: coverage_output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).coverage

stdout: $(inputs.input.nameroot).coverage

baseCommand: [samtools, coverage]
