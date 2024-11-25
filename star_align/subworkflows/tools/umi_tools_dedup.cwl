#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/umi-tools:latest
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

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 3

class: CommandLineTool

inputs:
  - id: output-stats
    type: ["null", string]
    inputBinding:
      prefix: --output-stats

  - id: extract-umi-method
    type:
      - "null"
      - type: enum
        symbols:
          - read_id
          - tag
          - umis
    inputBinding:
      prefix: --extract-umi-method

  - id: umi-separator
    type: ["null", string]
    inputBinding:
      prefix: --umi-separator

  - id: umi-tag
    type: ["null", string]
    inputBinding:
      prefix: --umi-tag

  - id: umi-tag-split
    type: ["null", string]
    inputBinding:
      prefix: --umi-tag-split

  - id: umi-tag-delimiter
    type: ["null", string]
    inputBinding:
      prefix: --umi-tag-delimiter

  - id: cell-tag
    type: ["null", string]
    inputBinding:
      prefix: --cell-tag

  - id: cell-tag-split
    type: ["null", string]
    inputBinding:
      prefix: --cell-tag-split

  - id: cell-tag-delimiter
    type: ["null", string]
    inputBinding:
      prefix: --cell-tag-delimiter

  - id: method
    type:
      - "null"
      - type: enum
        symbols:
          - unique
          - percentile
          - cluster
          - adjacency
          - directional
    inputBinding:
      prefix: --method

  - id: edit-distance-threshold
    type: ["null", long]
    inputBinding:
      prefix: --edit-distance-threshold

  - id: spliced-is-unique
    type: ["null", boolean]
    inputBinding:
      prefix: --spliced-is-unique

  - id: soft-clip-threshold
    type: ["null", long]
    inputBinding:
      prefix: --soft-clip-threshold

  - id: multimapping-detection-method
    type:
      - "null"
      - type: enum
        symbols:
          - NH
          - X0
          - XT
    inputBinding:
      prefix: --multimapping-detection-method

  - id: read-length
    type: ["null", boolean]
    inputBinding:
      prefix: --read-length

  - id: mapping-quality
    type: ["null", long]
    inputBinding:
      prefix: --mapping-quality

  - id: unmapped-reads
    type:
      - "null"
      - type: enum
        symbols:
          - discard
          - use
          - output
    inputBinding:
      prefix: --unmapped-reads

  - id: chimeric-pairs
    type:
      - "null"
      - type: enum
        symbols:
          - discard
          - use
          - output
    inputBinding:
      prefix: --chimeric-pairs

  - id: unpaired-reads
    type:
      - "null"
      - type: enum
        symbols:
          - discard
          - use
          - output
    inputBinding:
      prefix: --unpaired-reads

  - id: ignore-umi
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-umi

  - id: subset
    type: ["null", boolean]
    inputBinding:
      prefix: --subset

  - id: chrom
    type: ["null", boolean]
    inputBinding:
      prefix: --chrom

  - id: in-sam
    type: ["null", boolean]
    inputBinding:
      prefix: --in-sam

  - id: out-sam
    type: ["null", boolean]
    inputBinding:
      prefix: --out-sam

  - id: paired
    type: ["null", boolean]
    inputBinding:
      prefix: --paired

  - id: no-sort-output
    type: ["null", boolean]
    inputBinding:
      prefix: --no-sort-output

  - id: buffer-whole-contig
    type: ["null", boolean]
    inputBinding:
      prefix: --buffer-whole-contig

  - id: stdin-file
    type: File
    inputBinding:
      prefix: --stdin=
      separate: false
    secondaryFiles:
      - ^.bai

  - id: stdout_file
    type: string
    inputBinding:
      prefix: --stdout=
      separate: false

  - id: log
    type: string
    inputBinding:
      prefix: --log=
      separate: false

  - id: log2stderr
    type: boolean
    default: False
    inputBinding:
      prefix: --log2stderr

  - id: verbose
    type: int
    default: 1
    inputBinding:
      prefix: --verbose

  - id: error
    type: ["null", string]
    inputBinding:
      prefix: --error

  - id: temp-dir
    type: string
    default: "/tmp"
    inputBinding:
      prefix: --temp-dir

  - id: compresslevel
    type: int
    default: 6
    inputBinding:
      prefix: --compresslevel

outputs:
  - id: dedup_bam
    type: File
    outputBinding:
      glob: $(inputs.stdout_file)

  - id: outlog
    type: File
    outputBinding:
      glob: $(inputs.log)

  # - id: outstats
  #   type: File
  #   outputBinding:
  #     glob: $(inputs.output_stats)
      
baseCommand: [umi_tools, dedup]
