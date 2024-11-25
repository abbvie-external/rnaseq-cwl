#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: bam
    type: File
  - id: gtf
    type: File
  - id: any_se_readgroup
    type: boolean

outputs:
  - id: tar
    type: File
    outputSource: tar_tpmcalculator/output

steps:
  - id: tpmcalculator
    run: tools/tpmcalculator.cwl
    in:
      - id: bam
        source: bam
      - id: gtf
        source: gtf
      - id: properly_paired_only
        source: any_se_readgroup
      - id: extended_output
        valueFrom: $(true)
    out:
      - id: genes_ent
      - id: genes_out
      - id: genes_uni
      - id: transcripts_ent
      - id: transcripts_out

  - id: tar_tpmcalculator
    run: tools/tar_files.cwl
    in:
      - id: input
        source: [
        tpmcalculator/genes_ent,
        tpmcalculator/genes_out,
        tpmcalculator/genes_uni,
        tpmcalculator/transcripts_ent,
        tpmcalculator/transcripts_out
        ]
      - id: dirname
        valueFrom: tpmcalculator
    out:
      - id: output
