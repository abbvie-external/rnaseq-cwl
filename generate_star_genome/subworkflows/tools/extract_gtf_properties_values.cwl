#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
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

  - id: keyvalues
    type:
      type: array
      items: string
      inputBinding:
        prefix: --keyvalues

  - id: modname
    type: string
    inputBinding:
      prefix: --modname

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).$(inputs.modname)$(inputs.input.nameext)

baseCommand: [/usr/local/bin/extract_gtf_properties_values.py]
