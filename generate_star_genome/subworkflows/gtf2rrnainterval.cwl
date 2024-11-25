#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

inputs:
  - id: bedcutstring
    type: string
  - id: dict
    type: File
  - id: gtf
    type: File
  - id: gtf_keyvalues
    type:
      type: array
      items: string
  - id: gtf_modname
    type: string
  - id: fasta
    type: File

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

outputs:
  - id: output
    type: File
    outputSource: bedtointervallist/outfile

steps:
  - id: prunegtf
    run: tools/prunegtf.cwl
    in:
      - id: gtf
        source: gtf
      - id: fastadict
        source: dict
    out:
      - id: output
        
  - id: extract_gtf_rrna
    run: tools/extract_gtf_properties_values.cwl
    in:
      - id: input
        source: prunegtf/output
      - id: keyvalues
        source: gtf_keyvalues
      - id: modname
        source: gtf_modname
    out:
      - id: output

  - id: gtftobed
    run: tools/gffutils_gtf2bed.cwl
    in:
      - id: input
        source: extract_gtf_rrna/output
    out:
      - id: output

  - id: fixbed
    run: tools/cut.cwl
    in:
      - id: cutstring
        source: bedcutstring
      - id: input
        source: gtftobed/output
    out:
      - id: output

  - id: bedtointervallist
    run: tools/picard_bedtointervallist.cwl
    in:
      - id: input
        source: fixbed/output
      - id: sequence_dictionary
        source: dict
      - id: output
        source: gtf
        valueFrom: $(self.nameroot).rRNA.list
    out:
      - id: outfile
