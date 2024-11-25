#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: fastq1
    type:
      type: array
      items: File

  - id: fastq2
    type:
      type: array
      items: File

  - id: fastqs
    type:
      type: array
      items: File

outputs:
  - id: output
    type: string

expression: |
   ${
      function get_decomp_cmd(file_suffix) {
        if (suffix === 'gz') {
          var decomp_cmd = 'zcat';
        }
        else if (suffix === 'bz') {
          var decomp_cmd = 'bzcat';
        }
        else if (suffix === 'fq' || suffix === 'fastq') {
          var decomp_cmd = 'UNCOMPRESSED';
        }
        else {
          throw "not recognized compression format"
        }
        return decomp_cmd;
      }

      if (inputs.fastq1.length > 0 && inputs.fastq1.length == inputs.fastq2.length) {
        var suffix = inputs.fastq1[0].location.split('.').pop();
        var decomp_cmd = get_decomp_cmd(suffix);
      }
      else if (inputs.fastqs.length > 0) {
        var suffix = inputs.fastqs[0].location.split('.').pop();
        var decomp_cmd = get_decomp_cmd(suffix);
      }
      else {
        throw "PE arrays not present/not equal length, or there are no SE data"
      }

      return {'output': decomp_cmd}
    }
