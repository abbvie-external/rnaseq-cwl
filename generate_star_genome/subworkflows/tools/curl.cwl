#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/curl:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: $(Math.ceil (1.1 * inputs.file_size / 104857))
    tmpdirMax: $(Math.ceil (1.1 * inputs.file_size / 104857))
    outdirMin: $(Math.ceil (1.1 * inputs.file_size / 104857))
    outdirMax: $(Math.ceil (1.1 * inputs.file_size / 104857))
  - class: NetworkAccess
    networkAccess: true

class: CommandLineTool

inputs:
  - id: url
    type: string
    inputBinding:
      prefix: --url
      ## position: 99

  - id: continue-at
    type: ["null", string]
    inputBinding:
      prefix: --continue-at

  - id: connect-timeout
    type: ["null", long]
    inputBinding:
      prefix: --connect-timeout

  - id: file_size
    type: long
    default: 1

  - id: remote-name
    type: boolean
    default: true
    inputBinding:
      prefix: --remote-name

  - id: remote-header-name
    type: boolean
    default: true
    inputBinding:
      prefix: --remote-header-name

  - id: retry
    type: long
    default: 3
    inputBinding:
      prefix: --retry

outputs:
  - id: output
    type: File
    outputBinding:
      glob: '*'
      
baseCommand: [curl]
