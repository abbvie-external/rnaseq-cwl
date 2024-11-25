#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/entrezdirect:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1
  - class: NetworkAccess
    networkAccess: true

class: CommandLineTool

inputs:
  - id: nuccore_query
    type: string

arguments:
  - valueFrom: $("esearch -db nuccore -query " + inputs.nuccore_query + " | elink -target assembly | esummary | xtract -pattern DocumentSummary -element RefSeq")
    position: 1

outputs:
  - id: output
    type: string
    outputBinding:
      glob: $(inputs.nuccore_query).txt
      loadContents: true
      outputEval: $(self[0].contents.trim())

stdout: $(inputs.nuccore_query).txt

baseCommand: [bash, -c]
