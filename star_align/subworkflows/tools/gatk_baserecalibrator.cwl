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
  - id: input
    type: File
    inputBinding:
      prefix: --input

  - id: known_sites
    type: File
    inputBinding:
      prefix: --known-sites
    secondaryFiles:
      - .tbi

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
      glob: $(inputs.input.nameroot)_bqsr.grp
    secondaryFiles:
      - ^.bai

arguments:
  - valueFrom: $(inputs.input.nameroot)_bqsr.grp
    prefix: --output

baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, BaseRecalibrator]
