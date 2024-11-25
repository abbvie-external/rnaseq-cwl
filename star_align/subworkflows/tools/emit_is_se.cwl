#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl

class: ExpressionTool

inputs:
  - id: fastq_readgroups
    type:
      type: array
      items: readgroup.cwl#readgroup_fastq_file

outputs:
  - id: is_se
    type: boolean

expression: |
  ${
    if (inputs.fastq_readgroups[0].reverse_fastq == null) {
      var is_se = true;
    }
    else {
      var is_se = false;
    }

    return {'is_se': is_se};
  }
