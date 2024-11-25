#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: subworkflows/tools/readgroup.cwl
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bcl-only-lane
    type: ["null", int]
  - id: basecalls_array
    type:
      type: array
      items: Directory
  - id: samplesheets
    type:
      type: array
      items: File
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
        items: subworkflows/tools/readgroup.cwl#readgroup_fastq_file
    outputSource: merge_samples/samples

steps:
  - id: bcls2fastqreadgroups
    run: subworkflows/bcl2fastqreadgroup.cwl
    scatter: [basecalls, samplesheet]
    scatterMethod: "dotproduct"
    in:
      - id: basecalls
        source: basecalls_array
      - id: samplesheet
        source: samplesheets
      - id: sequencing_center
        source: sequencing_center
      - id: thread_count
        source: thread_count
      - id: bcl-only-lane
        source: bcl-only-lane
    out:
      - id: samples

  - id: merge_samples
    run: subworkflows/tools/emit_readgroup_fastq_samples.cwl
    in:
      - id: array_fastq_readgroups
        source: bcls2fastqreadgroups/samples
    out:
      - id: samples
