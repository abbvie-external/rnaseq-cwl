#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: required_file
    type: File

  - id: conditional_file
    type: [File, "null"]

outputs:
  - id: output
    type: File

expression: |
   ${
      if (inputs.conditional_file != null) {
        var output = inputs.conditional_file;
      }
      else {
        var output = inputs.required_file;
      }
      return {'output': output};
    }
