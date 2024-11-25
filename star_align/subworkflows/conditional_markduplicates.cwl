#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: bam
    type: File
  - id: run_uuid
    type: string

outputs:
  - id: output
    type: File
    outputSource: picard_markduplicates/output
  - id: sqlite
    type: File
    outputSource: picard_markduplicates_to_sqlite/sqlite
  - id: tar
    type: File
    outputSource: tar_picard_markduplicates/output

steps:
  - id: picard_markduplicates
    run: tools/picard_markduplicates.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output
      - id: metrics

  - id: picard_markduplicates_to_sqlite
    run: tools/picard_markduplicates_to_sqlite.cwl
    in:
      - id: bam
        source: bam
        valueFrom: $(self.basename)
      - id: input_state
        valueFrom: "markduplicates_readgroups"
      - id: metric_path
        source: picard_markduplicates/metrics
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: tar_picard_markduplicates
    run: tools/tar_files.cwl
    in:
      - id: input
        source:
          - picard_markduplicates/metrics
        valueFrom: $([self])
      - id: dirname
        valueFrom: picard_markduplicates
    out:
      - id: output
