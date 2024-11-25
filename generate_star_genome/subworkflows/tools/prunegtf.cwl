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
    tmpdirMin: $(Math.ceil ((inputs.gtf.size + inputs.fastadict.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.gtf.size + inputs.fastadict.size) / 1048576))
    outdirMin: $(Math.ceil (inputs.gtf.size / 1048576))
    outdirMax: $(Math.ceil (inputs.gtf.size / 1048576))

class: CommandLineTool

inputs:
  - id: gtf
    type: File
    inputBinding:
      prefix: --gtf

  - id: fastadict
    type: File
    inputBinding:
      prefix: --fastadict

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.gtf.basename)

baseCommand: [python3, /usr/local/bin/prune_gtf_contigs_with_fadict.py]
