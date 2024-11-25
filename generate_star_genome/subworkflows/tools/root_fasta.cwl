#!/usr/bin/env cwl-runner

cwlVersion: v1.1

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.fasta.basename)
        entry: $(inputs.fasta)
      - entryname: $(inputs.fasta_index.basename)
        entry: $(inputs.fasta_index)
      - entryname: $(inputs.fasta_dict.basename)
        entry: $(inputs.fasta_dict)
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: $(Math.ceil ((inputs.fasta.size + inputs.fasta_index.size + inputs.fasta_dict.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.fasta.size + inputs.fasta_index.size + inputs.fasta_dict.size) / 1048576))
    outdirMin: $(Math.ceil ((inputs.fasta.size + inputs.fasta_index.size + inputs.fasta_dict.size) / 1048576))
    outdirMax: $(Math.ceil ((inputs.fasta.size + inputs.fasta_index.size + inputs.fasta_dict.size) / 1048576))

class: CommandLineTool

inputs:
  - id: fasta
    type: File

  - id: fasta_index
    type: File

  - id: fasta_dict
    type: File

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.fasta.basename)
    secondaryFiles:
      - .fai
      - ^.dict

baseCommand: ['true']
