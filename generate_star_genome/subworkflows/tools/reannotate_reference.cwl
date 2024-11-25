#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
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
      shellQuote: false

  - id: regexp_extended
    type: ["null", boolean]
    inputBinding:
      prefix: --regexp-extended
      position: 0

  - id: search
    type: string

  - id: replace
    type: string

arguments:
  - valueFrom: $("s/" + inputs.search + "/" + inputs.replace + "/g")
    position: 1
    shellQuote: true
      
outputs:
  - id: output
    type: stdout

stdout: $(inputs.input.basename).test

baseCommand: [sed]
