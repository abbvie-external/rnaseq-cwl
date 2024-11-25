#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/bcftools:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: index
    type: [boolean, "null"]
    inputBinding:
      prefix: --index

  - id: input
    type: File
    inputBinding:
      position: 0

  - id: stdout
    type: boolean
    default: true
    inputBinding:
      prefix: --stdout

  - id: threads
    type: [long, "null"]
    inputBinding:
      prefix: --threads
      
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename).gz
    secondaryFiles:
      - .gzi

stdout: $(inputs.input.basename).gz

baseCommand: [bgzip]
