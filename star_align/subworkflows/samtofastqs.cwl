#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bams
    type:
      type: array
      items: File

outputs:
  - id: fastqs
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: samtofastq/output

steps:
  - id: samtofastq
    run: tools/picard_samtofastq.cwl
    scatter: input
    in:
      - id: input
        source: bams
      - id: output_per_rg
        valueFrom: "true"
      - id: compress_outputs_per_rg
        valueFrom: "true"
    out:
      - id: output
