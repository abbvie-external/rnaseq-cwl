#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:jammy-20221130
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.file_name)
        entry: $(inputs.first)
        writable: true
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: |
      ${
        var size = 0;
        size += inputs.first.size;
        for (var i in inputs.rest) {
          size += inputs.rest[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    tmpdirMax: |
      ${
        var size = 0;
        size += inputs.first.size;
        for (var i in inputs.rest) {
          size += inputs.rest[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMin: |
      ${
        var size = 0;
        size += inputs.first.size;
        for (var i in inputs.rest) {
          size += inputs.rest[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMax: |
      ${
        var size = 0;
        size += inputs.first.size;
        for (var i in inputs.rest) {
          size += inputs.rest[i].size;
        }
        return Math.ceil (size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: file_name
    type: string

  - id: first
    type: File

  - id: rest
    type:
      type: array
      items: File

  - id: expression
    type: string

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.file_name)

arguments:
  - valueFrom: |
      ${
      var cmd = [];
      cmd.push("grep");
      cmd.push("-Ehv");
      cmd.push(inputs.expression);
      for (var i in inputs.rest) {
        cmd.push(inputs.rest[i].path);
      }
      cmd.push(">>");
      cmd.push(inputs.file_name);
      var cmd_str = cmd.join(" ");
      return cmd_str;
      }
    position: 0

baseCommand: [bash, -c]
