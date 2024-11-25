#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: conditional1
    type: ["null", File]

  - id: conditional2
    type: ["null", File]

outputs:
  - id: out
    type: File

expression: |
   ${
      if (inputs.conditional1 !== null) {
        var out = inputs.conditional1;
      }
      else if (inputs.conditional2 !== null) {
        var out = inputs.conditional2;
      }
      else {
        throw 1;
      }
      
      return {'out': out};
    }
