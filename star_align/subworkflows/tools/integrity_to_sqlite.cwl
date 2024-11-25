#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/integrity-to-sqlite:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: $(Math.ceil (2 * (inputs.ls_l_path.size + inputs.md5sum_path.size + inputs.sha256sum_path.size) / 1048576))
    tmpdirMax: $(Math.ceil (2 * (inputs.ls_l_path.size + inputs.md5sum_path.size + inputs.sha256sum_path.size) / 1048576))
    outdirMin: $(Math.ceil ((inputs.ls_l_path.size + inputs.md5sum_path.size + inputs.sha256sum_path.size) / 1048576))
    outdirMax: $(Math.ceil ((inputs.ls_l_path.size + inputs.md5sum_path.size + inputs.sha256sum_path.size) / 1048576))

class: CommandLineTool

inputs:
  - id: input_state
    type: string
    inputBinding:
      prefix: "--input_state"

  - id: ls_l_path
    type: File
    inputBinding:
      prefix: "--ls_l_path"

  - id: md5sum_path
    type: File
    inputBinding:
      prefix: "--md5sum_path"

  - id: sha256sum_path
    type: File
    inputBinding:
      prefix: "--sha256sum_path"

  - id: run_uuid
    type: string
    inputBinding:
      prefix: "--run_uuid"

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).log

  - id: output
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).db

baseCommand: [integrity_to_sqlite]
