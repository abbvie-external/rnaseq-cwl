#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: required
    type: File

  - id: optional
    type: [File, "null"]

outputs:
  - id: output
    type: File

expression: |
   ${
      if (inputs.optional) {
        var output = inputs.optional;
      }
      else {
        var output = inputs.required;
      }
      return {"output": output};
    }
