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
    ramMin: 500
    ramMax: 500
    tmpdirMin: $(Math.ceil (inputs.fasta.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.fasta.size / 1048576))
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: fasta
    type: File
    inputBinding:
      position: 3
      shellQuote: false

arguments:
  - valueFrom: "head"
    position: 0
    shellQuote: false

  - valueFrom: "-n"
    position: 1
    shellQuote: false

  - valueFrom: "1"
    position: 2
    shellQuote: false

  - valueFrom: "|"
    position: 4
    shellQuote: false

  - valueFrom: "awk"
    position: 5
    shellQuote: false

  - valueFrom: "'{print $3}'"
    position: 6
    shellQuote: false

  - valueFrom: "|"
    position: 7
    shellQuote: false

  - valueFrom: "awk"
    position: 8
    shellQuote: false

  - valueFrom: "-F"
    position: 9
    shellQuote: false

  - valueFrom: "':'"
    position: 10
    shellQuote: false

  - valueFrom: "'{print $2}'"
    position: 11
    shellQuote: false
      
outputs:
  - id: output
    type: stdout

stdout: ensemble_name.txt

baseCommand: []
