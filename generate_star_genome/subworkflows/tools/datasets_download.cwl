#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/ncbi_datasets:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 5
    tmpdirMax: 5
    outdirMin: 5
    outdirMax: 5
  - class: NetworkAccess
    networkAccess: true
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  - id: accession
    type: string
    inputBinding:
      position: 1

  - id: include_items
    type:
      type: array
      items: string

  - id: no_progressbar
    type: boolean
    inputBinding:
      prefix: --no-progressbar
      position: 2
    default: true

arguments:
  - valueFrom: |
      ${
        var param = "--include ";
        for (var i = 0; i < inputs.include_items.length; i++) {
          if (i < inputs.include_items.length - 1) {
            param += inputs.include_items[i] + ",";
          }
          else {
            param += inputs.include_items[i];
          }
        }
        return param;
      }
    position: 9
    shellQuote: false

outputs:
  - id: zip
    type: File
    outputBinding:
      glob: ncbi_dataset.zip


baseCommand: [datasets, download, genome, accession]
