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
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

class: CommandLineTool

inputs:
  - id: input_file
    type: File
    inputBinding:
      prefix: --input_file

  - id: column
    type: string
    inputBinding:
      prefix: --column

outputs:
  - id: json
    type: File
    outputBinding:
      glob: $(inputs.input_file.nameroot).json
      
baseCommand: [python3, /usr/local/bin/tsv_column_to_json_list.py]
