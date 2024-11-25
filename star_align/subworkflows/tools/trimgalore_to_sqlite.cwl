#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/trimgalore-sqlite:latest
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

class: CommandLineTool

inputs:
  - id: metrics_path
    type: ["null", File]

  - id: run_uuid
    type: string

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).log

  - id: sqlite
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).db

arguments:
  - valueFrom: |
      ${
       if (inputs.metrics_path === null) {
         var cmd = ["touch", inputs.run_uuid+".log", inputs.run_uuid+".db"]
       }
       else {
         var cmd = ["trimgalore_sqlite", "--metrics_path", inputs.metrics_path.path, "--run_uuid", inputs.run_uuid]
      }
      return cmd;
      }
      
baseCommand: []
