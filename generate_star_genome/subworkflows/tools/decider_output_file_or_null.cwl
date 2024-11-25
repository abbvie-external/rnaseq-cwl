#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: optional_file
    type: ["null", File]

outputs:
  - id: output
    type: File

expression: |
   ${
      if (inputs.optional_file) {
        var output = inputs.optional;
      }
      else {
        var output = null;
      }
      return {"output": output};
    }
