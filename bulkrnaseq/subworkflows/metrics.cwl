#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/gtf_type.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: featurecounts_GTF_attrType
    type:
      type: array
      items: tools/gtf_type.cwl#GTF_attrType
  - id: featurecounts_GTF_featureType
    type:
      type: array
      items: tools/gtf_type.cwl#GTF_featureType
  - id: featurecounts_junccounts
    type: boolean
  - id: aggregate_kallisto
    type: boolean
  - id: project_id
    type: string
  - id: tars
    type:
      type: array
      items: File

outputs:
  - id: html
    type: File
    outputSource: multiqc/html
  - id: data
    type: Directory
    outputSource: multiqc/data
  - id: counts
    type:
      type: array
      items: File
    outputSource: aggregate_featurecounts_counts/counts
  - id: junccounts
    type:
      - "null"
      - type: array
        items: File
    outputSource: aggregate_featurecounts_junccounts/junccounts
  - id: kallisto_quant_tpm
    type: ["null", File]
    outputSource: aggregate_kallisto_wf/tpm_tsv
  - id: kallisto_quant_scaledcounts_tpm
    type: ["null", File]
    outputSource: aggregate_kallisto_wf/scaledcounts_tsv
  - id: kallisto_tpm_zpca
    type: ["null", Directory]
    outputSource: aggregate_kallisto_wf/zpca_tpm_dir
  - id: kallisto_scaledcounts_zpca
    type: ["null", Directory]
    outputSource: aggregate_kallisto_wf/zpca_scaledcounts_dir
  - id: rnaseqc_tpm
    type: File
    outputSource: aggregate_rnaseqc_tpm/counts
  - id: samtools_idxstats
    type: File
    outputSource: aggregate_samtools_idxstats/output

steps:
  - id: untar
    run: tools/untar.cwl
    scatter: input
    in:
      - id: input
        source: tars
    out:
      - id: dir

  - id: multiqc
    run: tools/multiqc.cwl
    in:
      - id: filename
        source: project_id
      - id: input
        source: untar/dir
    out:
      - id: html
      - id: data

  - id: aggregate_featurecounts_counts
    run: tools/aggregate_featurecounts.cwl
    scatter: [attribute_type, feature_type]
    scatterMethod: "flat_crossproduct"
    in:
      - id: sample_dir
        source: untar/dir
      - id: project_id
        source: project_id
      - id: attribute_type
        source: featurecounts_GTF_attrType
      - id: feature_type
        source: featurecounts_GTF_featureType
      - id: aggregation_type
        valueFrom: counts
    out:
      - id: counts

  - id: aggregate_featurecounts_junccounts
    run: tools/aggregate_featurecounts.cwl
    scatter: [attribute_type, feature_type]
    scatterMethod: "flat_crossproduct"
    in:
      - id: sample_dir
        source: untar/dir
      - id: project_id
        source: project_id
      - id: attribute_type
        source: featurecounts_GTF_attrType
      - id: feature_type
        source: featurecounts_GTF_featureType
      - id: aggregation_type
        valueFrom: junccounts
      - id: aggregate_junccounts
        source: featurecounts_junccounts
    out:
      - id: junccounts
    when: $(inputs.aggregate_junccounts)

  - id: aggregate_rnaseqc_tpm
    run: tools/aggregate_rnaseqc_tpm.cwl
    in:
      - id: sample_dir
        source: untar/dir
      - id: project_id
        source: project_id
    out:
      - id: counts

  - id: aggregate_kallisto_wf
    run: aggregate_kallisto.cwl
    in:
      - id: aggregate_kallisto
        source: aggregate_kallisto
      - id: project_id
        source: project_id
      - id: sample_dirs
        source: untar/dir
    out:
      - id: tpm_tsv
      - id: scaledcounts_tsv
      - id: zpca_tpm_dir
      - id: zpca_scaledcounts_dir
    when: $(inputs.aggregate_kallisto)

  - id: aggregate_samtools_idxstats
    run: tools/aggregate_samtools_idxstats.cwl
    in:
      - id: sample_dir
        source: untar/dir
      - id: project_id
        source: project_id
    out:
      - id: output
