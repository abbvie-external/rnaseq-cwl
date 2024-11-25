#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/qualimap:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: bam
    type: File
    inputBinding:
      prefix: -bam

  - id: paint_chromosome_limits
    type: ["null", boolean]
    inputBinding:
      prefix: --paint-chromosome-limits

  - id: genome_gc_distr
    type:
      - "null"
      - type: enum
        symbols:
          - HUMAN
          - MOUSE
    inputBinding:
      --prefix: --genome-gc-distr

  - id: feature_file
    type: ["null", File]
    inputBinding:
      prefix: --feature-file

  - id: homopolymer_minimum_size
    type: ["null", long]
    inputBinding:
      prefix: -hm

  - id: collect_overlap_pairs
    type: ["null", boolean]
    inputBinding:
      prefix: --collect-overlap-pairs

  - id: read_in_chunk
    type: ["null", long]
    inputBinding:
      prefix: -nr

  - id: number_threads
    type: ["null", long]
    inputBinding:
      prefix: -nt

  - id: number_windows
    type: ["null", long]
    inputBinding:
      prefix: -nw

  - id: output_genome_coverage
    type: ["null", string]
    inputBinding:
      prefix: --output-genome-coverage

  - id: outside_stats
    type: ["null", boolean]
    inputBinding:
      prefix: --outside-stats

  - id: outdir
    type: ["null", string]
    default: .
    inputBinding:
      prefix: -outdir

  - id: outfile
    type: ["null", string]
    inputBinding:
      prefix:: -outfile

  - id: outformat
    type:
      - "null"
      - type: enum
        symbols:
          - HTML
          - PDF
    inputBinding:
      prefix: -outformat

  - id: sequencing_protocol
    type:
      - "null"
      - type: enum
        symbols:
          - strand-specific-forward
          - strand-specific-reverse
          - non-strand-specific
    inputBinding:
      prefix: --sequencing-protocol

  - id: skip_duplicated
    type: ["null", boolean]
    inputBinding:
      prefix: --skip-duplicated

  - id: skip_dup_mode
    type:
      - "null"
      - type: enum
        symbols:
          - 0
          - 1
          - 2
    inputBinding:
      prefix: --skip-dup-mode
          

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).stats

baseCommand: [qualimap, bamqc]
