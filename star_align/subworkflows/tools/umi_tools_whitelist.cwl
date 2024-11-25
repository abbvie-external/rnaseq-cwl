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

class: CommandLineTool

inputs:
  - id: method
    type:
      - "null"
      - type: enum
        symbols:
          - reads
          - umis
    inputBinding:
      prefix: --method

  - id: knee-method
    type:
      - "null"
      - type: enum
        symbols:
          - distance
          - density
    inputBinding:
      prefix: --knee-method

  - id: set-cell-number
    type: ["null", long]
    inputBinding:
      prefix: --set-cell-number

  - id: expect-cells
    type: ["null", long]
    inputBinding:
      prefix: --expect-cells

  - id: allow-threshold-error
    type: ["null", boolean]
    inputBinding:
      prefix: --allow-threshold-error

  - id: error-correct-threshold
    type: ["null", long]
    inputBinding:
      prefix: --error-correct-threshold

  - id: plot-prefix
    type: ["null", string]
    inputBinding:
      prefix: --plot-prefix

  - id: ed-above-threshold
    type:
      - "null"
      - type: enum
        symbols:
          - discard
          - correct
    inputBinding:
      prefix: --ed-above-threshold

  - id: subset-reads
    type: ["null", long]
    inputBinding:
      prefix: --subset-reads

  - id: bc-pattern
    type: string
    inputBinding:
      prefix: --bc-pattern

  - id: bc-pattern2
    type: ["null", string]
    inputBinding:
      prefix: --bc-pattern2

  - id: extract-method
    type: ["null", string]
    inputBinding:
      prefix: --extract-method

  - id: 3prime
    type: ["null", boolean]
    inputBinding:
      prefix: --3prime

  - id: read2_in
    type: ["null", File]
    inputBinding:
      prefix: --read2-in

  - id: filtered-out
    type: ["null", string]
    inputBinding:
      prefix: --filtered-out

  - id: filtered-out2
    type: ["null", string]
    inputBinding:
      prefix: --filtered-out2

  - id: ignore-read-pair-suffixes
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-read-pair-suffixes

  - id: stdin
    type: File
    inputBinding:
      prefix: --stdin

  # - id: stdout
  #   type: string
  #   inputBinding:
  #     prefix: --stdout

  # - id: log
  #   type: string
  #   inputBinding:
  #     prefix: --log

  - id: log2stderr
    type: ["null", boolean]
    inputBinding:
      prefix: --log2stderr

  - id: verbose
    type: ["null", long]
    inputBinding:
      prefix: --verbose

  - id: error
    type: ["null", string]
    inputBinding:
      prefix: --error

  - id: temp-dir
    type: ["null", string]
    inputBinding:
      prefix: --temp-dir

  - id: compresslevel
    type: ["null", long]
    inputBinding:
      prefix: --compresslevel

outputs:
  - id: whitelist
    type: File
    outputBinding:
      glob: $(inputs.stdin.nameroot)_whitelist.txt

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.stdin.nameroot)_whitelist.log
    
stdout: $(inputs.stdin.nameroot)_whitelist.txt

stderr: $(inputs.stdin.nameroot)_whitelist.log
      
baseCommand: [umi_tools, whitelist]
