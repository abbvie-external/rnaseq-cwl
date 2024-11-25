#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: ensembl_fasta
    type:
      type: array
      items: File

  - id: ensembl_fasta_cdna
    type:
      type: array
      items: File

  - id: ensembl_gtf
    type:
      type: array
      items: File

  - id: ncbi_fasta
    type:
      type: array
      items: File

  - id: ncbi_fasta_cdna
    type:
      type: array
      items: File

  - id: ncbi_gtf
    type:
      type: array
      items: File

outputs:
  - id: fasta
    type:
      type: array
      items: File

  - id: fasta_cdna
    type:
      type: array
      items: File

  - id: gtf
    type:
      type: array
      items: File

expression: |
  ${
     var fasta = inputs.ensembl_fasta.concat(inputs.ncbi_fasta);
     var fasta_cdna = inputs.ensembl_fasta_cdna.concat(inputs.ncbi_fasta_cdna);
     var gtf = inputs.ensembl_gtf.concat(inputs.ncbi_gtf);

     return {"fasta": fasta, "fasta_cdna": fasta_cdna, "gtf": gtf};
  }
