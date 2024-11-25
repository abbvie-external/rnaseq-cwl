#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: dbsnp_array
    type:
      type: array
      items: File

  - id: decoy_fasta_array
    type:
      type: array
      items: File

  - id: fasta_array
    type:
      type: array
      items: File

  - id: fasta_cdna_array
    type:
      type: array
      items: File

  - id: decoy_fasta_cdna_array
    type:
      type: array
      items: File

  - id: gtf_array
    type:
      type: array
      items: File

  - id: decoy_gtf_array
    type:
      type: array
      items: File

  - id: decoy_type_array
    type:
      type: array
      items: string

outputs:
  - id: dbsnp_concat
    type: ["null", File]
    outputSource: concat_dbsnp/concat_ref
  - id: fasta_concat
    type: File
    outputSource: concat_fasta/concat_ref
  - id: fasta_cdna_concat
    type: File
    outputSource: concat_fasta_cdna/concat_ref
  - id: gtf_concat
    type: File
    outputSource: concat_gtf/concat_ref
  - id: gtf_nodecoy_concat
    type: File
    outputSource: concat_gtf_nodecoy/concat_ref

steps:
  - id: get_genome_names
    run: tools/get_fasta_genome_name.cwl
    scatter: fasta
    in:
      - id: fasta
        source: fasta_array
    out:
      - id: genome_name


  - id: annotate_dbsnp
    run: annotate_snp.cwl
    scatter: [genome_name, dbsnp]
    scatterMethod: "dotproduct"
    in:
      - id: genome_name
        source: get_genome_names/genome_name
      - id: dbsnp
        source: dbsnp_array
    out:
      - id: dbsnp_compat

  - id: concat_dbsnp
    run: concat_species.cwl
    in:
      - id: ref_array
        source: annotate_dbsnp/dbsnp_compat
      - id: decoy_array
        valueFrom: $([])
      - id: decoy_type_array
        source: decoy_type_array
      - id: dots_kept
        valueFrom: $(1)
    out:
      - id: concat_ref
    when: $(inputs.ref_array.length > 0)

  - id: annotate_contigs
    run: annotate_contigs.cwl
    scatter: [genome_name, fasta, gtf]
    scatterMethod: "dotproduct"
    in:
      - id: genome_name
        source: get_genome_names/genome_name
      - id: fasta
        source: fasta_array
      - id: gtf
        source: gtf_array
    out:
      - id: fasta_compat
      - id: gtf_compat

  - id: concat_fasta
    run: concat_species.cwl
    in:
      - id: ref_array
        source: annotate_contigs/fasta_compat
      - id: decoy_array
        source: decoy_fasta_array
      - id: decoy_type_array
        source: decoy_type_array
      - id: dots_kept
        valueFrom: $(4)
    out:
      - id: concat_ref

  - id: concat_fasta_cdna
    run: concat_species.cwl
    in:
      - id: ref_array
        source: fasta_cdna_array
      - id: decoy_array
        source: decoy_fasta_cdna_array
      - id: decoy_type_array
        source: decoy_type_array
      - id: dots_kept
        valueFrom: $(4)
    out:
      - id: concat_ref

  - id: concat_gtf
    run: concat_species.cwl
    in:
      - id: ref_array
        source: annotate_contigs/gtf_compat
      - id: decoy_array
        source: decoy_gtf_array
      - id: decoy_type_array
        source: decoy_type_array
      - id: dots_kept
        valueFrom: $(3)
    out:
      - id: concat_ref

  - id: concat_gtf_nodecoy
    run: concat_species.cwl
    in:
      - id: ref_array
        source: annotate_contigs/gtf_compat
      - id: decoy_array
        valueFrom: $([])
      - id: decoy_type_array
        valueFrom: $([])
      - id: dots_kept
        valueFrom: $(3)
    out:
      - id: concat_ref
