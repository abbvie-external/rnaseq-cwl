#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/ncbi_datasets:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 100
    tmpdirMax: 100
    outdirMin: 100
    outdirMax: 100
  - class: NetworkAccess
    networkAccess: true

class: CommandLineTool

inputs:
  - id: genome_accession
    type: string
    inputBinding:
      prefix: accession
      position: 98

  - id: include
    type:
      - "null"
      - type: array
        items: string

  - id: download
    type: boolean
    inputBinding:
      prefix: download
      position: 1

  - id: genome
    type: boolean
    inputBinding:
      prefix: genome
      position: 2

arguments:
  - valueFrom:
    prefix: --include

outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*'
      
baseCommand: [curl]
