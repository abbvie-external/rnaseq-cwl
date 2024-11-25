#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/tar-concat:latest
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: |
      ${
       var size = 0;
       for (var i in inputs.archive) {
         size += inputs.archive[i].size;
       }
       return Math.ceil (2 * size / 1048576);
      }
    tmpdirMax: |
      ${
       var size = 0;
       for (var i in inputs.archive) {
         size += inputs.archive[i].size;
       }
       return Math.ceil (2 * size / 1048576);
      }
    outdirMin: |
      ${
       var size = 0;
       for (var i in inputs.archive) {
         size += inputs.archive[i].size;
       }
       return Math.ceil (size / 1048576);
      }
    outdirMax: |
      ${
       var size = 0;
       for (var i in inputs.archive) {
         size += inputs.archive[i].size;
       }
       return Math.ceil (size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: archives
    type:
      type: array
      items: File

  - id: tar_out
    type: string
    inputBinding:
      prefix: --tar-out

  - id: add_dir
    type: ["null", string]
    inputBinding:
      prefix: --add-dir

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.tar_out)

arguments:
  - valueFrom: |
      ${
        var used_archives = [];

        for (var i = 0; i < inputs.archives.length; i++) {
          if (inputs.archives[i].size > 0) {
            used_archives.push(inputs.archives[i]);
          }
        }

        var params = [];
        for (var i = 0; i < used_archives.length; i++) {
          params.push('--tar-file');
          params.push(used_archives[i].path);
        }

        return params.join(' ');
      }
    position: 0
    shellQuote: false

baseCommand: [tar_concat]
