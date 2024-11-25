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
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: runinfoxml
    type: File
    inputBinding:
      prefix: --runinfoxml

  - id: runidkey
    type: string
    inputBinding:
      prefix: --runidkey
      
outputs:
  - id: output
    type: string
    outputBinding:
      glob: output
      loadContents: true
      outputEval: $(self[0].contents.replace(/\n/g, ''))

stdout: output
      
baseCommand: [python3, /usr/local/bin/parse_runinfo_xml.py]
