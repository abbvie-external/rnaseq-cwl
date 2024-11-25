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
  - id: output
    type: boolean

expression: |
   ${
     var any_se = false;
     for (var i = 0; i < inputs.fastq_readgroups.length; i++) {
       if (inputs.fastq_readgroups[i].reverse_fastq === null) {
         any_se = true;
       }
     }
      return {'output': any_se}
    }
