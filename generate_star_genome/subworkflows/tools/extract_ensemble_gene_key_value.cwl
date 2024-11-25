#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil (inputs.species_json.size / 1048576))
    tmpdirMax: $(Math.ceil (inputs.species_json.size / 1048576))
    outdirMin: $(Math.ceil (inputs.species_json.size / 1048576))
    outdirMax: $(Math.ceil (inputs.species_json.size / 1048576))

class: CommandLineTool

inputs:
  - id: species_json
    type: File
    inputBinding:
      prefix: --species-json

  - id: gene_key
    type: string
    inputBinding:
      prefix: --gene-key

  - id: gene_value
    type: string
    inputBinding:
      prefix: --gene-value

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.species_json.nameroot)_$(inputs.gene_key)_$(inputs.gene_value).json

baseCommand: [extract_ensemble_gene_key_value.py]
