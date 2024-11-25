#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: dbsnp
    type: ["null", File]

  - id: fasta
    type: File

  - id: fasta_cdna
    type: File

  - id: decoy_fasta_array
    type:
      type: array
      items: File

  - id: decoy_fasta_cdna_array
    type:
      type: array
      items: File

  - id: gtf
    type: File

  - id: decoy_gtf_array
    type:
      type: array
      items: File

  - id: decoy_type_array
    type:
      type: array
      items: string

outputs:
  - id: dbsnp_out
    type: ["null", File]
    outputSource: dbsnp
  - id: fasta_out
    type: File
    outputSource: decide_fasta/output
  - id: fasta_cdna_out
    type: File
    outputSource: decide_fasta_cdna/output
  - id: gtf_out
    type: File
    outputSource: decide_gtf/output
  - id: gtf_nodecoy_out
    type: File
    outputSource: gtf

steps:
  - id: concat_fasta
    run: tools/grep_append.cwl
    in:
      - id: expression
        valueFrom: "^#"
      - id: file_name
        source:
          - fasta
          - decoy_type_array
        valueFrom: |
          ${
           var filename = self[0].basename;
           var filesplit = filename.split('.');
           var fileExt = filesplit.pop();
           var fileBase = filesplit.join('.');
           var arrayLength = self[1].length;
           for (var i = 0; i < arrayLength; i++) {
             fileBase = fileBase+'.'+self[1][i];
           }
           var outfile = fileBase + '.' + fileExt;
           return outfile
          }
      - id: first
        source: fasta
      - id: rest
        source: decoy_fasta_array
    out:
      - id: output
    when: $(inputs.rest.length > 0)

  - id: decide_fasta
    run: tools/decider_required_optional.cwl
    in:
      - id: required
        source: fasta
      - id: optional
        source: concat_fasta/output
    out:
      - id: output

  - id: concat_fasta_cdna
    run: tools/grep_append.cwl
    in:
      - id: expression
        valueFrom: "^#"
      - id: file_name
        source:
          - fasta_cdna
          - decoy_type_array
        valueFrom: |
          ${
           var filename = self[0].basename;
           var filesplit = filename.split('.')
           var fileExt = filesplit.pop();
           var fileBase = filesplit.join('.');
           var arrayLength = self[1].length;
           for (var i = 0; i < arrayLength; i++) {
             fileBase = fileBase+'.'+self[1][i];
           }
           var outfile = fileBase + '.' + fileExt;
           return outfile
          }
      - id: first
        source: fasta_cdna
      - id: rest
        source: decoy_fasta_cdna_array
    out:
      - id: output
    when: $(inputs.rest.length > 0)

  - id: decide_fasta_cdna
    run: tools/decider_required_optional.cwl
    in:
      - id: required
        source: fasta_cdna
      - id: optional
        source: concat_fasta_cdna/output
    out:
      - id: output

  - id: concat_gtf
    run: tools/grep_append.cwl
    in:
      - id: expression
        valueFrom: "^#"
      - id: file_name
        source:
          - gtf
          - decoy_type_array
        valueFrom: |
          ${
           var filename = self[0].basename;
           var filesplit = filename.split('.')
           var fileExt = filesplit.pop();
           var fileBase = filesplit.join('.');
           var arrayLength = self[1].length;
           for (var i = 0; i < arrayLength; i++) {
             fileBase = fileBase+'.'+self[1][i];
           }
           var outfile = fileBase + '.' + fileExt;
           return outfile
          }
      - id: first
        source: gtf
      - id: rest
        source: decoy_gtf_array
    out:
      - id: output
    when: $(inputs.rest.length > 0)

  - id: decide_gtf
    run: tools/decider_required_optional.cwl
    in:
      - id: required
        source: gtf
      - id: optional
        source: concat_gtf/output
    out:
      - id: output          
