#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: $(Math.ceil ((inputs.bed.size + inputs.fastadict.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.bed.size + inputs.fastadict.size) / 1048576))
    outdirMin: $(Math.ceil (inputs.bed.size / 1048576))
    outdirMax: $(Math.ceil (inputs.bed.size / 1048576))

class: CommandLineTool

inputs:
  - id: bed
    type: File
    inputBinding:
      prefix: --bed

  - id: fastadict
    type: File
    inputBinding:
      prefix: --fastadict

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.bed.nameroot).prune$(inputs.bed.nameext)

baseCommand: [python3, /usr/local/bin/prune_bed_contigs_with_fadict.py]
