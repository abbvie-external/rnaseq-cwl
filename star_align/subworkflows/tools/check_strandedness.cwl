#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/hawsh:594aa8d9d7ebb3da733c78ad72612497868d8319ef33d0caf9e5bcd26d9c313c
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 18000
    ramMax: 18000
    tmpdirMin: $(Math.ceil ((inputs.gtf.size + inputs.transcript.size + (2 * inputs.fastq1.size) + inputs.kallisto_index.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.gtf.size + inputs.transcript.size + (2 * inputs.fastq1.size) + inputs.kallisto_index.size) / 1048576))
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: gtf
    type: File
    inputBinding:
      prefix: --gtf

  - id: transcript
    type: File
    inputBinding:
      prefix: --transcript

  - id: fastq1
    type: File
    inputBinding:
      prefix: -r1

  - id: fastq2
    type: ["null", File]
    inputBinding:
      prefix: -r2

  - id: kallisto_index
    type: File
    inputBinding:
      prefix: --kallisto_index

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.fastq1.nameroot).stranded

stdout: $(inputs.fastq1.nameroot).stranded

baseCommand: [check_strandedness]
