#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: dbsnp_array
    type:
      type: array
      items: File

  - id: fasta_array
    type:
      type: array
      items: File

  - id: fasta_cdna_array
    type:
      type: array
      items: File

  - id: gtf_array
    type:
      type: array
      items: File

outputs:
  - id: dbsnp
    type: ["null", File]
  - id: fasta
    type: File
  - id: fasta_cdna
    type: File
  - id: gtf
    type: File

expression: |
  ${
    if (inputs.dbsnp_array.length > 0) {
      var dbsnp = inputs.dbsnp_array[0];
    }
    else {
      var dbsnp = null;
    }
    var fasta = inputs.fasta_array[0];
    var fasta_cdna = inputs.fasta_cdna_array[0];
    var gtf = inputs.gtf_array[0];

    return {"dbsnp": dbsnp, "fasta_cdna": fasta_cdna, "fasta": fasta, "gtf": gtf};
  }
