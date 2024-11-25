#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/samtools:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.input.basename)
        entry: $(inputs.input)
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 4000
    ramMax: 4000
    tmpdirMin: $(Math.ceil (1.1 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (1.1 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (1.1 * inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (1.1 * inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename).fai

arguments:
  - valueFrom: $(inputs.input.basename)
    position: 0

baseCommand: [samtools, faidx]
