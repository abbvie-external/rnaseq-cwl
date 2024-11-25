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
  - id: fastqs
    type:
      type: array
      items: File

expression: |
  ${
    var fastqs = [];

    for (var i in inputs.fastq_readgroups) {
      fastqs.push(inputs.fastq_readgroups[i].forward_fastq);
      if (inputs.fastq_readgroups[i].reverse_fastq != null) {
        fastqs.push(inputs.fastq_readgroups[i].reverse_fastq);
      }
    }

    return {'fastqs': fastqs};
  }
