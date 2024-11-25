#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: input
    type:
      type: array
      items:
        type: array
        items: File

outputs:
  - id: output
    type:
      type: array
      items: File

expression: |
  ${
      var output = [];
      for (var i in inputs.input[0]) {
        output.push(inputs.input[0][i]);
      }      
    return {"output": output};
  }
