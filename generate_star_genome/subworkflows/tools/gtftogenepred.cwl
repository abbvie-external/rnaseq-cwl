#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/kent-utils:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 4000
    ramMax: 4000
    tmpdirMin: $(Math.ceil (2 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil (inputs.input.size / 1048576))
    outdirMax: $(Math.ceil (inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 4

  - id: genePredExt
    type: boolean
    inputBinding:
      prefix: -genePredExt
      position: 1

  - id: geneNameAsName2
    type: boolean
    inputBinding:
      prefix: -geneNameAsName2
      position: 2

  - id: ignoreGroupsWithoutExons
    type: boolean
    inputBinding:
      prefix: -ignoreGroupsWithoutExons
      position: 3

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).genePred

arguments:
  - valueFrom: $(inputs.input.nameroot).genePred
    position: 5

baseCommand: [gtfToGenePred]
