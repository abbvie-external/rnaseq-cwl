#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseqc:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 2
    coresMax: 2
    ramMin: 1500
    ramMax: 1500
    tmpdirMin: $(Math.ceil ((inputs.bam.size + inputs.gtf.size + inputs.bed.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.bam.size + inputs.gtf.size + inputs.bed.size) / 1048576))
    outdirMin: 10
    outdirMax: 10

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 5

class: CommandLineTool

inputs:
  - id: bam
    type: File
    inputBinding:
      position: 98

  - id: gtf
    type: File
    inputBinding:
      position: 97

  - id: bed
    type: File
    inputBinding:
      prefix: --bed
      position: 2
      
  - id: coverage
    type: boolean
    default: true
    inputBinding:
      prefix: --coverage
      position: 0

  - id: rpkm
    type: boolean
    default: false
    inputBinding:
      prefix: --rpkm
      position: 1

  - id: stranded
    type:
      - "null"
      - type: enum
        symbols:
          - FR
          - RF
    inputBinding:
      prefix: --stranded
      position: 3

  - id: unpaired
    type: ["null", boolean]
    inputBinding:
      prefix: --unpaired
      position: 4

arguments:
  - valueFrom: '.'
    position: 99
      
outputs:
  - id: coverage_tsv
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).coverage.tsv

  - id: gene_reads_gct
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).gene_reads.gct

  - id: gene_tpm_gct
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).gene_tpm.gct

  - id: gene_fragments_gct
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).gene_fragments.gct

  - id: exon_reads_gct
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).exon_reads.gct

  - id: metrics_tsv
    type: File
    outputBinding:
      glob: $(inputs.bam.basename).metrics.tsv
          
baseCommand: [rnaseqc]
