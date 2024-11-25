#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: optional_files
    type:
      type: array
      items: ["null", File]

outputs:
  - id: out_files
    type:
      type: array
      items: File

expression: |
   ${
      var out_files = [];
      for (var i in inputs.optional_files) {
        if (inputs.optional_files[i]) {
          out_files.push(inputs.optional_files[i]);
        }
      }
      return {'out_files': out_files};
    }

