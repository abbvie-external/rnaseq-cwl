#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: ref_array
    type:
      type: array
      items: File

  - id: decoy_array
    type:
      type: array
      items: File

  - id: dots_kept
    type: int

  - id: decoy_type_array
    type:
      type: array
      items: string

outputs:
  - id: concat_ref
    type: File
    outputSource: decide_output/output

steps:
  - id: get_concat_name
    run: tools/expr_concat_name.cwl
    in:
      - id: ref_array
        source: ref_array
      - id: dots_kept
        source: dots_kept
    out:
      - id: concat_name

  - id: concat_species
    run: tools/grep_append.cwl
    in:
      - id: expression
        valueFrom: "^#"
      - id: file_name
        source: get_concat_name/concat_name
      - id: first
        source: ref_array
        valueFrom: $(self[0])
      - id: rest
        source: ref_array
        valueFrom: $(self.slice(1))
    out:
      - id: output

  - id: concat_decoy
    run: tools/grep_append.cwl
    in:
      - id: expression
        valueFrom: "^#"
      - id: file_name
        source:
          - get_concat_name/concat_name
          - decoy_type_array
        valueFrom: |
          ${
           var filename = self[0];
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
        source: concat_species/output
      - id: rest
        source: decoy_array
    out:
      - id: output
    when: $(inputs.rest.length > 0)

  - id: decide_output
    run: tools/decider_required_optional.cwl
    in:
      - id: required
        source: concat_species/output
      - id: optional
        source: concat_decoy/output
    out:
      - id: output
