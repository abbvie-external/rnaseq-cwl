#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/bcftools:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.input.basename)
        entry: $(inputs.input)
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: $(Math.ceil (1.2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (1.2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (1.2 * inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (1.2 * inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

  - id: preset
    type:
      type: enum
      symbols:
        - gff
        - bed
        - sam
        - vcf
    inputBinding:
      prefix: -p
      position: 0
      
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - .tbi

baseCommand: [/usr/local/bin/bcftools, tabix]
