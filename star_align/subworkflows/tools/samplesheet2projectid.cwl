#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: samplesheet
    type: File
    inputBinding:
      prefix: --samplesheet

outputs:
  - id: projectid
    type: string
    outputBinding:
      glob: samplesheet_project.txt
      loadContents: true
      outputEval: $(self[0].contents)

baseCommand: [python3, /usr/local/bin/samplesheet2projectid.py]
