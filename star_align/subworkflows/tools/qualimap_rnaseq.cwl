#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/qualimap:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 14000
    ramMax: 14000
    tmpdirMin: $(Math.ceil (2.0 * inputs.bam.size / 1048576))
    tmpdirMax: $(Math.ceil (2.0 * inputs.bam.size / 1048576))
    outdirMin: $(Math.ceil (2.0 * inputs.bam.size / 1048576))
    outdirMax: $(Math.ceil (2.0 * inputs.bam.size / 1048576))

class: CommandLineTool

inputs:
  - id: java_mem_size
    type: ["null", string]
    default: 12G
    inputBinding:
      prefix: --java-mem-size=
      separate: false

  - id: algorithm
    type:
      - "null"
      - type: enum
        symbols:
          - uniquely-mapped-reads
          - proportional
    inputBinding:
      prefix: --algorithm
          
  - id: bam
    type: File
    inputBinding:
      prefix: -bam

  - id: gtf
    type: ["null", File]
    inputBinding:
      prefix: -gtf

  - id: computed_counts
    type: ["null", File]
    inputBinding:
      prefix: -oc

  - id: outdir
    type: ["null", string]
    default: "./"
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

  - id: paired
    type: ["null", boolean]
    inputBinding:
      prefix: --paired

  - id: sorted
    type: ["null", boolean]
    inputBinding:
      prefix: --sorted

outputs:
  - id: output
    type: File
    outputBinding:
      glob: rnaseq_qc_results.txt

baseCommand: [/usr/local/qualimap/qualimap, rnaseq]
