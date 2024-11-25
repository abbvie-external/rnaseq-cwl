#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/zpca:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 8000
    ramMax: 8000
    tmpdirMin: $(Math.ceil (inputs.tpm.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.tpm.size / 1048576))
    outdirMin: 10
    outdirMax: 10

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 10

class: CommandLineTool

inputs:
  - id: tpm
    type: File
    inputBinding:
      prefix: --tpm

  - id: tpm_filter
    type: ["null", long]
    inputBinding:
      prefix: --tpm-filter

  - id: tpm_pseudocount
    type: ["null", long]
    inputBinding:
      prefix: --tpm-pseudocount

  - id: out
    type: string
    inputBinding:
      prefix: --out
outputs:
  - id: output
    type: Directory
    outputBinding:
      glob: $(inputs.out)

baseCommand: [zpca-tpm]
