#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/qualimap-sqlite:latest
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
  - id: metrics_path
    type: File
    inputBinding:
      prefix: --metrics_path

  - id: run_uuid
    type: string
    inputBinding:
      prefix: --run_uuid

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).log

  - id: sqlite
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).db

baseCommand: [qualimap_sqlite]
