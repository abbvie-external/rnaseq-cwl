#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: basecalls_dir
    type: string

  - id: barcode_file
    type: string

outputs:
  - id: metrics
    type: string

  - id: lane
    type: long

expression: |
  ${
    var lane = parseInt(inputs.barcode_file.charAt(16));
    var metrics = inputs.basecalls_dir + "_L00" + lane + ".txt"
    return {'lane': lane, 'metrics': metrics}
  }
