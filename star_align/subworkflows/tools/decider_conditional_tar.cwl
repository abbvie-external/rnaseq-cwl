#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: required_tar
    type: File

  - id: conditional_tar
    type: [File, "null"]

outputs:
  - id: tar
    type: File

expression: |
   ${
      if (inputs.conditional_tar != null) {
        var tar = inputs.conditional_tar;
      }
      else {
        var tar = inputs.required_tar;
      }
      return {'tar': tar};
    }
