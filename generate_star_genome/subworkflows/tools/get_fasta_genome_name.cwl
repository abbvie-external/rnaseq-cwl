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
    tmpdirMin: $(Math.ceil (inputs.fasta.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.fasta.size / 1048576))
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: fasta
    type: File

arguments:
  - valueFrom: |
      ${
      var cmd = "head -n 1 " + inputs.fasta.path + " | awk '{print $3}' | awk -F ':' '{print $2}'";
      return cmd;
      }
    position: 1
    shellQuote: true
      
outputs:
  - id: genome_name
    type: string
    outputBinding:
      glob: $(inputs.fasta.basename).name
      loadContents: true
      outputEval: $(self[0].contents.replace(/\n/g, ''))

stdout: $(inputs.fasta.basename).name

baseCommand: [bash, -c]
