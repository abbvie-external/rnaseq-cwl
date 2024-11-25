#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:2a9cb1b1722df416cb0044aef5f02489224898f441754485d51c74b5a94c95b5
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
  - id: bam
    type: File
    inputBinding:
      prefix: --bam_path

outputs:
  - id: json
    type: File
    outputBinding:
      glob: "*.json"

baseCommand: [python3, /usr/local/bin/bam_readgroup_to_json.py]
