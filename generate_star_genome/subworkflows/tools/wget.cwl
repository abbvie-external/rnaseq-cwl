#!/usr/bin/env cwl-runner

cwlVersion: v1.1

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/wget:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (inputs.file_size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.file_size / 1048576))
    outdirMin: $(Math.ceil (inputs.file_size / 1048576))
    outdirMax: $(Math.ceil (inputs.file_size / 1048576))

class: CommandLineTool

inputs:
  - id: url
    type: string
    inputBinding:
      # prefix: --url
      position: 99

  - id: file_size
    type: long
    default: 1

  - id: content-disposition
    type: boolean
    default: true
    inputBinding:
      prefix: --content-disposition

outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*'

baseCommand: [wget]
