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
    tmpdirMin: $(inputs.input.dsize)
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  - id: input
    type: Directory
    inputBinding:
      position: 50
      shellQuote: False

  - id: human
    type: ["null", boolean]
    inputBinding:
      prefix: --human-readable
      shellQuote: False

  - id: maxdepth
    type: ["null", int]
    inputBinding:
      prefix: --max-depth
      shellQuote: False

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename).du

stdout: $(inputs.input.basename).du

arguments:
  - valueFrom: |
      ${
        return " | tail -n1 | awk '{print $1}'";
      }
    position: 99
    shellQuote: False

baseCommand: [du]
