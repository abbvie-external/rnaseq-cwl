#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/illuminabcl.cwl
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bcls
    type:
      type: array
      items: tools/illuminabcl.cwl#bcl
  - id: sequencing_center
    type: string
  - id: thread_count
    type: long

outputs:
  - id: samples
    type:
      type: array
      items:
        type: array
        items: tools/readgroup.cwl#readgroup_fastq_file
    outputSource: merge_samples/samples

steps:
  - id: bcl2fastqreadgroups.cwl
  
  - id: bclconvert
    run: tools/bclconvert.cwl
    scatter: bcl
    in:
      - id: bcl
        source: bcls
#      - id: runfolder-dir
#        source: basecalls_dir
#      - id: sample-sheet
#        source: samplesheet
      - id: loading-threads
        source: thread_count
      - id: processing-threads
        source: thread_count
      - id: writing-threads
        source: thread_count
#      - id: use-bases-mask
#        source: read_structure
      - id: mask-short-adapter-reads
        valueFrom: $(0)
      - id: barcode-mismatches
        valueFrom: $(1)
      - id: no-lane-splitting
        valueFrom: $(true)
      - id: projectid
        source: get_projects_samples/projectids
        valueFrom: $(self[0])
    out:
      - id: fastqs
      - id: report_dir
      - id: stats_dir

  - id: fastqs2samples
    run: tools/expression_fastqs2samples.cwl
    in:
      - id: fastqs
        source: bcl2fastq/fastqs
      - id: sampleids
        source: get_projects_samples/sampleids
    out:
      - id: readgroups_umi

  - id: umireadgroup2pairedreadgroup
    run: umireadgroup2pairedreadgroup.cwl
    scatter: readgroup_umi
    in:
      - id: readgroup_umi
        source: fastqs2samples/readgroups_umi
      - id: sequencing_center
        source: sequencing_center
      - id: thread_count
        source: thread_count
    out:
      - id: fastq_readgroup

  - id: merge_samples
    run: tools/emit_readgroup_fastq_samples.cwl
    in:
      - id: array_fastq_readgroups
        source: umireadgroup2pairedreadgroup/fastq_readgroup
    out:
      - id: samples
