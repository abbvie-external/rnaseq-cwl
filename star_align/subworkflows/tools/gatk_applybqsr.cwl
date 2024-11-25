#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/gatk:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 50000
    ramMax: 60000

class: CommandLineTool

inputs:
  - id: bqsr_recal_file
    type: File
    inputBinding:
      prefix: --bqsr-recal-file

  - id: input
    type: File
    inputBinding:
      prefix: --input

  - id: reference
    type: File
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - ^.bai

arguments:
  - valueFrom: $(inputs.input.basename)
    prefix: --output

baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, ApplyBQSR]
