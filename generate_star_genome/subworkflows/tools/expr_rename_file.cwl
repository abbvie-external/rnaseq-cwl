#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: input
    type: File

  - id: filename
    type: string

outputs:
  - id: output
    type: File

expression: |
  
  ${
    var outfile = inputs.input;
    outfile.basename = inputs.filename;
    return {'output': outfile};
  }
