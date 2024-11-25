#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/bcl2fastq:bcaa047d8920b7d0a14b4b5b2a13ce75a59e941489ba36560528bdbb2fdd3fbe
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.processing-threads)
    coresMax: $(inputs.processing-threads)
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: min-log-level
    type:
      - "null"
      - type: enum
        symbols:
          - DEBUG
          - ERROR
          - FATAL
          - INFO
          - NONE
          - TRACE
          - WARNING
    inputBinding:
      prefix: --min-log-level

  - id: input-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --input-dir

  - id: runfolder-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --runfolder-dir

  - id: intensities-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --intensities-dir

  - id: output-dir
    type: string
    default: .
    inputBinding:
      prefix: --output-dir

  - id: interop-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --interop-dir

  - id: stats-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --stats-dir

  - id: reports-dir
    type: ["null", Directory]
    inputBinding:
      prefix: --reports-dir

  - id: sample-sheet
    type: ["null", File]
    inputBinding:
      prefix: --sample-sheet

  - id: loading-threads
    type: long
    default: 8
    inputBinding:
      prefix: --loading-threads

  - id: processing-threads
    type: long
    default: 8
    inputBinding:
      prefix: --processing-threads

  - id: writing-threads
    type: long
    default: 1
    inputBinding:
      prefix: --writing-threads

  - id: tiles
    type: ["null", string]
    inputBinding:
      prefix: --tiles

  - id: minimum-trimmed-read-length
    type: ["null", long]
    inputBinding:
      prefix: --minimum-trimmed-read-length

  - id: use-bases-mask
    type: ["null", string]
    inputBinding:
      prefix: --use-bases-mask

  - id: mask-short-adapter-reads
    type: ["null", long]
    inputBinding:
      prefix: --mask-short-adapter-reads

  - id: adapter-stringency
    type: ["null", float]
    inputBinding:
      prefix: --adapter-stringency

  - id: ignore-missing-bcls
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-missing-bcls

  - id: ignore-missing-filter
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-missing-filter

  - id: ignore-missing-positions
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-missing-positions

  - id: ignore-missing-controls
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-missing-controls

  - id: write-fastq-reverse-complement
    type: ["null", boolean]
    inputBinding:
      prefix: --write-fastq-reverse-complement

  - id: with-failed-reads
    type: ["null", boolean]
    inputBinding:
      prefix: --with-failed-reads

  - id: create-fastq-for-index-reads
    type: ["null", boolean]
    inputBinding:
      prefix: --create-fastq-for-index-reads

  - id: find-adapters-with-sliding-window
    type: ["null", boolean]
    inputBinding:
      prefix: --find-adapters-with-sliding-window

  - id: no-bgzf-compression
    type: ["null", boolean]
    inputBinding:
      prefix: --no-bgzf-compression

  - id: fastq-compression-level
    type: ["null", int]
    inputBinding:
      prefix: --fastq-compression-level

  - id: barcode-mismatches
    type:
      - ["null", int]
    inputBinding:
      prefix: --barcode-mismatches

  - id: no-lane-splitting
    type: ["null", boolean]
    inputBinding:
      prefix: --no-lane-splitting
    
  - id: projectid
    type: string

outputs:
  - id: fastqs
    type:
      type: array
      items: File
    outputBinding:
      glob: "$(inputs.projectid)/*.fastq.gz"

  - id: report_dir
    type: Directory
    outputBinding:
      glob: Reports

  - id: stats_dir
    type: Directory
    outputBinding:
      glob: Stats

baseCommand: [bcl2fastq]
