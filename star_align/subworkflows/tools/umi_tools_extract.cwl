#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/umi-tools:latest
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
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
  - id: error-correct-cell
    type: ["null", boolean]
    inputBinding:
      prefix: --error-correct-cell

  - id: whitelist
    type: ["null", File]
    inputBinding:
      prefix: --whitelist

  - id: blacklist
    type: ["null", File]
    inputBinding:
      prefix: --blacklist

  - id: subset-reads
    type: ["null", long]
    inputBinding:
      prefix: --subset-reads

  - id: quality-filter-threshold
    type: ["null", boolean]
    inputBinding:
      prefix: --quality-filter-threshold

  - id: quality-filter-mask
    type: ["null", boolean]
    inputBinding:
      prefix: --quality-filter-mask

  - id: quality-encoding
    type:
      - "null"
      - type: enum
        symbols:
          - phred33
          - phred64
          - solexa
    inputBinding:
      prefix: --quality-encoding

  - id: reconcile-pairs
    type: ["null", boolean]
    inputBinding:
      prefix: --reconcile-pairs

  - id: bc-pattern
    type: ["null", string]
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
    type: ["null", int]
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
  - id: fastq
    type: File
    outputBinding:
      glob: $(inputs.stdin.basename)

  - id: fastq2
    type: ["null", File]
    outputBinding:
      glob: |
        ${
        if (inputs.read2_in !== null) {
          return inputs.read2_in.basename;
        }
        else {
          return null;
        }
        }

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.stdin.nameroot)_extract.log

arguments:
  - valueFrom: |
      ${
      var out = "";
      out += "--stdout " + inputs.stdin.basename;
      if (inputs.read2_in !== null) {
        out += " --read2-out " + inputs.read2_in.basename;
      }
      return out;
      }
    shellQuote: false

  - valueFrom: $(inputs.stdin.nameroot)_extract.log
    prefix: --log


    
baseCommand: [umi_tools, extract]
