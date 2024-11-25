#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: genome_name
    type: string
  - id: fasta
    type: File
  - id: gtf
    type: File

outputs:
  - id: fasta_compat
    type: File
    outputSource: fasta_compat_chr/output
  - id: gtf_compat
    type: File
    outputSource: gtf_compat_chr/output

steps:
  - id: fasta_compat_chr
    run: tools/sed.cwl
    in:
      - id: expression
        source: genome_name
        valueFrom: $("s/^>/>"+self+"_/g")
      - id: input
        source: fasta
    out:
      - id: output

  - id: gtf_compat_chr
    run: tools/sed.cwl
    in:
      - id: expression
        source: genome_name
        valueFrom: $("s/(^[^#])/"+self+"_\\1/g")
      - id: regexp-extended
        valueFrom: $(true)
      - id: input
        source: gtf
    out:
      - id: output

