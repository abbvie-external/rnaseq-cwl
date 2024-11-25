#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/hawsh:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 50000
    ramMax: 50000
    tmpdirMin: $(Math.ceil (10 * inputs.fasta.size / 1048576))
    tmpdirMax: $(Math.ceil (10 * inputs.fasta.size / 1048576))
    outdirMin: $(Math.ceil (10 * inputs.fasta.size / 1048576))
    outdirMax: $(Math.ceil (10 * inputs.fasta.size / 1048576))

class: CommandLineTool

inputs:
  - id: index
    type: string
    inputBinding:
      prefix: --index

  - id: fasta
    type: File
    inputBinding:
      position: 99

  - id: kmer-size
    type: ["null", long]
    inputBinding:
      prefix: --kmer-size

  - id: make-unique
    type: ["null", boolean]
    inputBinding:
      prefix: --make-unique

outputs:
  - id: indexed
    type: File
    outputBinding:
      glob: $(inputs.index)

baseCommand: [kallisto, index]
