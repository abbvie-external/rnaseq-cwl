#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: dbsnp_multi
    type: ["null", File]

  - id: fasta_multi
    type: ["null", File]

  - id: fasta_cdna_multi
    type: ["null", File]

  - id: gtf_multi
    type: ["null", File]

  - id: gtf_nodecoy_multi
    type: ["null", File]

  - id: dbsnp_single
    type: [File, "null"]

  - id: fasta_single
    type: [File, "null"]

  - id: fasta_cdna_single
    type: [File, "null"]

  - id: gtf_single
    type: [File, "null"]

  - id: gtf_nodecoy_single
    type: [File, "null"]

outputs:
  - id: dbsnp
    type: ["null", File]

  - id: fasta
    type: File

  - id: fasta_cdna
    type: File

  - id: gtf
    type: File

  - id: gtf_nodecoy
    type: File

expression: |
   ${
      if (inputs.dbsnp_multi) {
        var dbsnp = inputs.dbsnp_multi;
      }
      else {
        var dbsnp = inputs.dbsnp_single;
      }

      if (inputs.fasta_multi) {
        var fasta = inputs.fasta_multi;
      }
      else {
        var fasta = inputs.fasta_single;
      }

      if (inputs.fasta_cdna_multi) {
        var fasta_cdna = inputs.fasta_cdna_multi;
      }
      else {
        var fasta_cdna = inputs.fasta_cdna_single;
      }

      if (inputs.gtf_multi) {
        var gtf = inputs.gtf_multi;
      }
      else {
        var gtf = inputs.gtf_single;
      }

      if (inputs.gtf_nodecoy_multi) {
        var gtf_nodecoy = inputs.gtf_nodecoy_multi;
      }
      else {
        var gtf_nodecoy = inputs.gtf_nodecoy_single;
      }

      return {"dbsnp": dbsnp, "fasta": fasta, "fasta_cdna": fasta_cdna,
      "gtf": gtf, "gtf_nodecoy": gtf_nodecoy};
    }
