#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: $(Math.ceil (inputs.samplesheet.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.samplesheet.size / 1048576))
    outdirMin: $(Math.ceil (inputs.samplesheet.size / 1048576))
    outdirMax: $(Math.ceil (inputs.samplesheet.size / 1048576))

class: CommandLineTool

inputs:
  - id: samplesheet
    type: File
    inputBinding:
      prefix: --samplesheet

outputs:
  - id: sampleids
    type:
      type: array
      items: string
    outputBinding:
      glob: samplesheet_sampleids.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents))

baseCommand: [python3, /usr/local/bin/samplesheet2sampleids.py]
