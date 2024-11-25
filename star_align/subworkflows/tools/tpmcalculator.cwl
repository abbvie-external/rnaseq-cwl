#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/tpmcalculator:latest
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
      prefix: -b

  - id: gtf
    type: File
    inputBinding:
      prefix: -g

  - id: gene_key
    type: [string, "null"]
    inputBinding:
      prefix: -k

  - id: transcript_key
    type: [string, "null"]
    inputBinding:
      prefix: -t

  - id: smallest_intron_size
    type: [long, "null"]
    inputBinding:
      prefix: -c

  - id: properly_paired_only
    type: boolean
    default: true
    inputBinding:
      prefix: -p

  - id: minimum_mapq_filter
    type: [long, "null"]
    inputBinding:
      prefix: -q

  - id: minimum_overlap_read_feature
    type: [long, "null"]
    inputBinding:
      prefix: -o

  - id: extended_output
    type: boolean
    default: true
    inputBinding:
      prefix: -e

  - id: print_zero_counts
    type: boolean
    default: true
    inputBinding:
      prefix: -a

outputs:
  - id: genes_ent
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)_genes.ent

  - id: genes_out
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)_genes.out

  - id: genes_uni
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)_genes.uni

  - id: transcripts_ent
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)_transcripts.ent

  - id: transcripts_out
    type: File
    outputBinding:
      glob: $(inputs.bam.nameroot)_transcripts.out

baseCommand: [TPMCalculator]
