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
  - class: SubworkflowFeatureRequirement

inputs:
  - id: basecalls
    type: Directory
  - id: samplesheet
    type: File
  - id: sequencing_center
    type: string
  - id: thread_count
    type: long
  - id: bcl-only-lane
    type: ["null", int]

outputs:
  - id: samples
    type:
      type: array
      items: tools/readgroup.cwl#readgroup_fastq_file
    outputSource: samples2readgroups/readgroup

steps:
  - id: get_projects_samples
    run: tools/samplesheet2projects_samples.cwl
    in:
      - id: samplesheet
        source: samplesheet
    out:
      - id: projectids
      - id: sampleids

  - id: bclconvert
    run: tools/bclconvert.cwl
    in:
      - id: bcl-input-directory
        source: basecalls
      - id: sample-sheet
        source: samplesheet
      - id: bcl-num-parallel-tiles
        source: thread_count
      - id: bcl-num-conversion-threads
        source: thread_count
      - id: bcl-num-compression-threads
        source: thread_count
      - id: bcl-num-decompression-threads
        source: thread_count
      - id: force
        valueFrom: $(true)
      - id: strict-mode
        valueFrom: "true"
      - id: bcl-only-lane
        source: bcl-only-lane
    out:
      - id: fastqs
      - id: reports
      - id: logs

  - id: fastqs2samples
    run: tools/expression_fastqs2samples.cwl
    in:
      - id: fastqs
        source: bclconvert/fastqs
      - id: sampleids
        source: get_projects_samples/sampleids
    out:
      - id: samples

  - id: samples2readgroups
    run: sample2readgroup.cwl
    scatter: sample
    in:
      - id: sample
        source: fastqs2samples/samples
      - id: sequencing_center
        source: sequencing_center
    out:
      - id: readgroup
