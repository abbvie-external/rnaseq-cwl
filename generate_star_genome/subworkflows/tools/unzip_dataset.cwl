#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/unzip:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (10 * inputs.zip.size / 1048576))
    tmpdirMax: $(Math.ceil (10 * inputs.zip.size / 1048576))
    outdirMin: $(Math.ceil (10 * inputs.zip.size / 1048576))
    outdirMax: $(Math.ceil (10 * inputs.zip.size / 1048576))

class: CommandLineTool

inputs:
  - id: zip
    type: File
    inputBinding:
      position: 1

outputs:
  - id: dir
    type: Directory
    outputBinding:
      glob: $(inputs.zip.nameroot)

  - id: dataset_catalog
    type: File
    outputBinding:
      glob: $(inputs.zip.nameroot)/data/dataset_catalog.json

  - id: assembly_data_report
    type: File
    outputBinding:
      glob: $(inputs.zip.nameroot)/data/assembly_data_report.jsonl
      
baseCommand: [unzip]
