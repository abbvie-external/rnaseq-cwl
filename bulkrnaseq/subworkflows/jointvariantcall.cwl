#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: fasta
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
  - id: project_id
    type: string
  - id: vcfs
    type:
      type: array
      items: File

outputs:
  - id: vcf
    type: File
    outputSource: genotypegvcfs/outvcf

steps:
  - id: combinegvcfs
    run: tools/gatk_combinegvcfs.cwl
    in:
      - id: output
        source: project_id
        valueFrom: $(self).g.vcf.gz
      - id: variant
        source: vcfs
      - id: reference
        source: fasta
    out:
      - id: outgvcf

  - id: index_gvcf
    run: tools/bcftools_tabix.cwl
    in:
      - id: input
        source: combinegvcfs/outgvcf
      - id: preset
        valueFrom: vcf
    out:
      - id: output
        
  - id: genotypegvcfs
    run: tools/gatk_genotypegvcfs.cwl
    in:
      - id: output
        source: project_id
        valueFrom: $(self).vcf.gz
      - id: reference
        source: fasta
      - id: variant
        source: index_gvcf/output
    out:
      - id: outvcf
