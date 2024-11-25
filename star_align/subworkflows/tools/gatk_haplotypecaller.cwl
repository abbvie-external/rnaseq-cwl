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
  - id: dbsnp
    type: [File, "null"]
    inputBinding:
      prefix: --dbsnp
    secondaryFiles:
      - .tbi

  - id: emit_ref_confidence
    type:
      - "null"
      - type: enum
        symbols:
          - NONE
          - BP_RESOLUTION
          - GVCF
    inputBinding:
      prefix: --emit-ref-confidence

  - id: input
    type: File
    inputBinding:
      prefix: --input
    secondaryFiles:
      - ^.bai

  - id: intervals
    type:
      type: array
      items: string
      inputBinding:
        prefix: --intervals
      
  - id: native_pair_hmm_threads
    type: [long, "null"]
    inputBinding:
      prefix: --native-pair-hmm-threads

  - id: output-mode
    type:
      - "null"
      - type: enum
        symbols:
          - EMIT_ALL_ACTIVE_SITES
          - EMIT_ALL_CONFIDENT_SITES
          - EMIT_VARIANTS_ONLY

  - id: reference
    type: File
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict

outputs:
  - id: outvcf
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).vcf

arguments:
  - valueFrom: $(inputs.input.nameroot).vcf
    prefix: --output

baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, HaplotypeCaller]
