#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/picard:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.input.basename)
        entry: $(inputs.input)
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
  - id: input
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  - id: output
    type: ["null", string]
    inputBinding:
      prefix: OUTPUT=
      separate: false

  - id: tmp_dir
    type: string
    default: .
    inputBinding:
      prefix: TMP_DIR=
      separate: false

outputs:
  - id: indexedbam
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - ^.bai

baseCommand: [java, -jar, /usr/local/bin/picard.jar, BuildBamIndex]
