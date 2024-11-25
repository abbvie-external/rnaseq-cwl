#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/gatk:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: InlineJavascriptRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: $(Math.ceil (2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      prefix: --input

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename).tbi

arguments:
  - valueFrom: $(inputs.input.basename).tbi
    prefix: --output
  
baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, IndexFeatureFile]
