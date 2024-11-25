#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: required_bam
    type: File
    secondaryFiles:
      - ^.bai

  - id: conditional_bam
    type: [File, "null"]
    secondaryFiles:
      - ^.bai

outputs:
  - id: bam
    type: File
    secondaryFiles:
      - ^.bai

expression: |
   ${
      if (inputs.conditional_bam !== null) {
        var bam = inputs.conditional_bam;
      }
      else {
        var bam = inputs.required_bam;
      }
      
      return {'bam': bam};
    }
