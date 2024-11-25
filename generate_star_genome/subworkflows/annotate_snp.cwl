#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: genome_name
    type: string
  - id: dbsnp
    type: File

outputs:
  - id: dbsnp_compat
    type: ["null", File]
    outputSource: dbsnp_compat_chr/output

steps:
  - id: dbsnp_compat_chr
    run: tools/sed.cwl
    in:
      - id: expression
        source: genome_name
        valueFrom: $("s/(^[^#])/"+self+"_\\1/g")
      - id: regexp-extended
        valueFrom: $(true)
      - id: input
        source: dbsnp
    out:
      - id: output
