#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/sambamba:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 14000
    ramMax: 16000

class: CommandLineTool

inputs:
  - id: remove-duplicates
    type: [boolean, "null"]
    inputBinding:
      prefix: --remove-duplicates
      position: 1

  - id: nthreads
    type: [int, "null"]
    inputBinding:
      prefix: --nthreads
      position: 2

  - id: compression_level
    type: [int, "null"]
    inputBinding:
      prefix: --compression-level
      position: 3

  - id: show-progress
    type: [boolean, "null"]
    inputBinding:
      prefix: --show-progress
      position: 4
    
  - id: tmpdir
    default: .
    type: string
    inputBinding:
      prefix: --tmpdir
      position: 5

  - id: hash-table-size
    type: [long, "null"]
    inputBinding:
      prefix: --hash-table-size
      position: 6

  - id: overflow-list-size
    type: [long, "null"]
    inputBinding:
      prefix: --overflow-list-size
      position: 7

  - id: io-buffer-size
    type: [int, "null"]
    inputBinding:
      prefix: --io-buffer-size
      position: 8

  - id: input
    type: File
    inputBinding:
      position: 90

outputs:
  - id: output
    type:
      type: array
      items: File
    outputBinding:
      glob: "*"

  # - id: metrics
  #   type: File
  #   outputBinding:
  #     glob: $(inputs.input.basename).metrics

arguments:
  - valueFrom: $(inputs.input.basename)
    position: 91

baseCommand: [sambamba, markdup]
