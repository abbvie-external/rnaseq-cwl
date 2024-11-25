#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/picard:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ResourceRequirement
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
      prefix: INPUT=
      separate: false

  - id: sequence_dictionary
    type: File
    inputBinding:
      prefix: SEQUENCE_DICTIONARY=
      separate: false

  - id: sort
    type: string
    default: "true"
    inputBinding:
      prefix: SORT=
      separate: false

  - id: unique
    type: string
    default: "false"
    inputBinding:
      prefix: UNIQUE=
      separate: false

outputs:
  - id: outfile
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).list

arguments:
  - valueFrom: $(inputs.input.nameroot).list
    prefix: OUTPUT=
    separate: false

baseCommand: [java, -jar, /usr/local/bin/picard.jar, BedToIntervalList]
