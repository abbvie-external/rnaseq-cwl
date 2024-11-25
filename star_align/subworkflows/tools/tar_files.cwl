#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
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
       for (var i in inputs.input) {
         size += inputs.input[i].size;
       }
       return Math.ceil (2 * size / 1048576);
      }
    tmpdirMax: |
      ${
       var size = 0;
       for (var i in inputs.input) {
         size += inputs.input[i].size;
       }
       return Math.ceil (2 * size / 1048576);
      }
    outdirMin: |
      ${
       var size = 0;
       for (var i in inputs.input) {
         size += inputs.input[i].size;
       }
       return Math.ceil (size / 1048576);
      }
    outdirMax: |
      ${
       var size = 0;
       for (var i in inputs.input) {
         size += inputs.input[i].size;
       }
       return Math.ceil (size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: create
    type: boolean
    default: true
    inputBinding:
      prefix: --create
      position: 0

  - id: dirname
    type: string

  - id: gzip
    type: boolean
    default: false
    inputBinding:
      prefix: --gzip
      position: 2

  - id: transform
    type: ["null", string]
      
  - id: input
    type:
      type: array
      items: File

arguments:
  - valueFrom: $(inputs.dirname).tar
    prefix: --file
    position: 1

  - valueFrom: |
      ${
        var inp_str = "";
        for (var i = 0; i < inputs.input.length; i++) {
          var cmd = " -C " + inputs.input[i].dirname + " " + inputs.input[i].basename;
          inp_str = inp_str.concat(cmd);
         }
        return inp_str; 
       }
    position: 99
    shellQuote: false

  - valueFrom: |
      ${
          var cmd = "--transform 's,^," + inputs.dirname + "/,'";
          return cmd;
      }
    position: 90
    shellQuote: false
    
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.dirname).tar

baseCommand: [tar]
