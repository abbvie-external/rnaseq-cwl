#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: bam
    type: File
  - id: dbsnp
    type: File
    secondaryFiles:
      - .tbi
  - id: fasta
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
  - id: run_uuid
    type: string
  - id: run_variantcall_joint
    type: boolean
  - id: run_variantcall_single
    type: boolean
  - id: thread_count
    type: long
  - id: variantcall_contigs
    type:
      type: array
      items: string

outputs:
  - id: variants
    type: File
    outputSource: decider_haplotypecaller/out
  - id: bqsrbam
    type: File
    outputSource: gatk_applybqsr/output

steps:
  - id: gatk_splitncigarreads
    run: tools/gatk_splitncigarreads.cwl
    in:
      - id: input
        source: bam
      - id: reference
        source: fasta
    out:
      - id: output

  - id: gatk_baserecalibrator
    run: tools/gatk_baserecalibrator.cwl
    in:
      - id: input
        source: gatk_splitncigarreads/output
      - id: reference
        source: fasta
      - id: known_sites
        source: [dbsnp]
    out:
      - id: output

  - id: gatk_applybqsr
    run: tools/gatk_applybqsr.cwl
    in:
      - id: bqsr_recal_file
        source: gatk_baserecalibrator/output
      - id: input
        source: gatk_splitncigarreads/output
      - id: reference
        source: fasta
    out:
      - id: output

  - id: gatk_haplotypecaller_single
    run: tools/gatk_haplotypecaller.cwl
    in:
      - id: input
        source: gatk_applybqsr/output
      - id: intervals
        source: variantcall_contigs
      - id: native_pair_hmm_threads
        source: thread_count
      - id: reference
        source: fasta
      - id: run_variantcall_single
        source: run_variantcall_single
    out:
      - id: outvcf
    when: $(inputs.run_variantcall_single)

  - id: gatk_haplotypecaller_joint
    run: tools/gatk_haplotypecaller.cwl
    in:
      - id: emit_ref_confidence
        source: run_variantcall_joint
        valueFrom: GVCF
      - id: input
        source: gatk_applybqsr/output
      - id: intervals
        source: variantcall_contigs
      - id: native_pair_hmm_threads
        source: thread_count
      - id: reference
        source: fasta
      - id: run_variantcall_joint
        source: run_variantcall_joint
    out:
      - id: outvcf
    when: $(inputs.run_variantcall_joint)

  - id: decider_haplotypecaller
    run: tools/decider_when2.cwl
    in:
      - id: conditional1
        source: gatk_haplotypecaller_joint/outvcf
      - id: conditional2
        source: gatk_haplotypecaller_single/outvcf
    out:
      - id: out
