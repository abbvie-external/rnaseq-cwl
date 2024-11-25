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

  - id: required_sqlite
    type: File

  - id: required_tar
    type: File

  - id: conditional_bam
    type: [File, "null"]
    secondaryFiles:
      - ^.bai

  - id: conditional_sqlite
    type: [File, "null"]

  - id: conditional_tar
    type: [File, "null"]

outputs:
  - id: bam
    type: File
    secondaryFiles:
      - ^.bai

  - id: sqlite
    type: File

  - id: tar
    type: File

expression: |
   ${
      if (inputs.conditional_bam !== null) {
        var bam = inputs.conditional_bam;
      }
      else {
        var bam = inputs.required_bam;
      }

      if (inputs.conditional_sqlite !== null) {
        var sqlite = inputs.conditional_sqlite;
      }
      else {
        var sqlite = inputs.required_sqlite;
      }

      if (inputs.conditional_tar !== null) {
        var tar = inputs.conditional_tar;
      }
      else {
        var tar = inputs.required_tar;
      }
      return {'bam': bam, 'sqlite': sqlite, 'tar': tar};
    }
