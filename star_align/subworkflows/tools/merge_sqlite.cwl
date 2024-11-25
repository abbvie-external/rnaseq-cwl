#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/merge-sqlite:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: |
      ${
      var size = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          size += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (size / 1048576));
      }      
    tmpdirMax: |
      ${
      var size = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          size += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (size / 1048576));
      }      
    outdirMin: |
      ${
      var size = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          size += inputs.source_sqlite[i].size;
        }
      return Math.ceil(size / 1048576);
      }      
    outdirMax: |
      ${
      var size = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          size += inputs.source_sqlite[i].size;
        }
      return Math.ceil(size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: source_sqlite
    type:
      type: array
      items: File
      inputBinding:
        prefix: "--source_sqlite"

  - id: job_uuid
    type: string
    inputBinding:
      prefix: "--job_uuid"

outputs:
  - id: destination_sqlite
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".db")

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".log")

baseCommand: [/usr/local/bin/merge_sqlite]
