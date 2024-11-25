#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement

inputs:
  - id: gtf
    type: File
  - id: fasta
    type: File
  - id: fastq_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_bam
  - id: kallisto_index
    type: File

outputs:
  - id: strand
    type:
      - "null"
      - type: enum
        symbols:
          - forward
          - reverse
          - unstranded
    outputSource: emit_strandedness/output
  - id: ss_len_med
    type: ["null", double]
    outputSource: emit_single_strand_len/output
  - id: ss_len_sd
    type: ["null", double]
    outputSource: emit_single_strand_sd/output

steps:
  - id: check_strandedness
    run: tools/check_strandedness.cwl
    in:
      - id: fastq1
        source: fastq_readgroup
        valueFrom: $(self.forward_fastq)
      - id: fastq2
        source: fastq_readgroup
        valueFrom: $(self.reverse_fastq)
      - id: transcript
        source: fasta
      - id: gtf
        source: gtf
      - id: kallisto_index
        source: kallisto_index
    out:
      - id: output

  - id: emit_strandedness
    run: tools/emit_strandedness.cwl
    in:
      - id: input
        source: check_strandedness/output
    out:
      - id: output

  - id: emit_single_strand_len
    run: tools/emit_single_strand_len_med.cwl
    in:
      - id: input
        source: check_strandedness/output
    out:
      - id: output

  - id: emit_single_strand_sd
    run: tools/emit_single_strand_len_sd.cwl
    in:
      - id: input
        source: check_strandedness/output
    out:
      - id: output
