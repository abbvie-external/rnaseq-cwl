#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement

inputs:
  - id: bam
    type: File

outputs:
  - id: fastq_bam_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_bam
    outputSource: emit_readgroup/output

steps:
  - id: samtofastq
    run: tools/picard_samtofastq.cwl
    in:
      - id: input
        source: bam
      - id: output_per_rg
        valueFrom: "true"
      - id: compress_outputs_per_rg
        valueFrom: "true"
    out:
      - id: output

  - id: bam_readgroup_to_json
    run: tools/bam_readgroup_to_json.cwl
    in:
      - id: bam
        source: bam
    out:
      - id: json

  - id: emit_readgroup
    run: tools/emit_readgroup_fastq_bam.cwl
    in:
      - id: bam
        source: bam
      - id: fastq1
        source: samtofastq/output
        valueFrom: $(self[0])
      - id: fastq2
        source: samtofastq/output
        valueFrom: $(self[1])
      - id: readgroup_json
        source: bam_readgroup_to_json/json
    out:
      - id: output
