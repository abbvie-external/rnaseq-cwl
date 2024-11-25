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
    ramMax: 50000
    tmpdirMin: $(Math.ceil ((inputs.reference.size + inputs.variant.size) * 1.2 / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.reference.size + inputs.variant.size) * 1.2 / 1048576))
    outdirMin: $(Math.ceil ((inputs.reference.size + inputs.variant.size) * 1.2 / 1048576))
    outdirMax: $(Math.ceil ((inputs.reference.size + inputs.variant.size) * 1.2 / 1048576))

class: CommandLineTool

inputs:
  - id: output
    type: string
    inputBinding:
      prefix: --output

  - id: reference
    type: File
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict

  - id: variant
    type: File
    inputBinding:
      prefix: --variant
    secondaryFiles:
      - .tbi

outputs:
  - id: outvcf
    type: File
    outputBinding:
      glob: $(inputs.output)

baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, GenotypeGVCFs]
