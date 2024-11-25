#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: fastq_readgroups
    type:
      type: array
      items: tools/readgroup.cwl#readgroup_fastq_file
  - id: gtf
    type: File
  - id: kallisto_index
    type: File
  - id: kallisto_quant_bootstrap_samples
    type: long
  - id: fragment_length
    type: ["null", double]
  - id: sample_id
    type: string
  - id: std_dev
    type: ["null", double]
  - id: strand
    type:
      - "null"
      - type: enum
        symbols:
          - forward
          - reverse
          - unstranded
  - id: thread_count
    type: long

outputs:
  - id: tar
    type: File
    outputSource: tar_kallisto_quant/output

steps:
  - id: emit_fastqs
    run: tools/emit_fastqs.cwl
    in:
      - id: fastq_readgroups
        source: fastq_readgroups
    out:
      - id: fastqs

  - id: emit_is_se
    run: tools/emit_is_se.cwl
    in:
      - id: fastq_readgroups
        source: fastq_readgroups
    out:
      - id: is_se

  - id: kallisto_quant
    run: tools/kallisto_quant.cwl
    in:
      - id: bootstrap_samples
        source: kallisto_quant_bootstrap_samples
      - id: fastq
        source: emit_fastqs/fastqs
      - id: gtf
        source: gtf
      - id: index
        source: kallisto_index
      - id: forward_stranded
        source: strand
        valueFrom: |
          ${
            if (self == "forward") {
              return true;
            }
            else {
              return false;
            }
          }
      - id: reverse_stranded
        source: strand
        valueFrom: |
          ${
            if (self == "reverse") {
              return true;
            }
            else {
              return false;
            }
          }
      - id: threads
        source: thread_count
      - id: single
        source: emit_is_se/is_se
      - id: fragment_length
        source: fragment_length
      - id: std_dev
        source: std_dev
    out:
      - id: abundance_tsv
      - id: abundance_h5
      - id: run_info_json

  - id: edger_scalecounts
    run: tools/edger_scalecounts.cwl
    in:
      - id: abundance_h5
        source: kallisto_quant/abundance_h5
      - id: sampleid
        source: sample_id
    out:
      - id: scaled_counts

  - id: tar_kallisto_quant
    run: tools/tar_files.cwl
    in:
      - id: input
        source: [
        kallisto_quant/abundance_tsv,
        kallisto_quant/abundance_h5,
        kallisto_quant/run_info_json,
        edger_scalecounts/scaled_counts
        ]
      - id: dirname
        source: fastq_readgroups
        valueFrom: kallisto_quant
    out:
      - id: output
