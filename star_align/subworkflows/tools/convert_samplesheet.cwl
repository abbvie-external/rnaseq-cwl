#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:2a9cb1b1722df416cb0044aef5f02489224898f441754485d51c74b5a94c95b5
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: samplesheet
    type: File
    inputBinding:
      prefix: --samplesheet

outputs:
  - id: barcode_files
    type:
      type: array
      items: File
    outputBinding:
      glob: "Barcode_file_L00*.txt"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }

  - id: library_files
    type:
      type: array
      items: File
    outputBinding:
      glob: "Library_file_L00*.txt"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }

baseCommand: [python3, /usr/local/bin/convert_samplesheet.py]
