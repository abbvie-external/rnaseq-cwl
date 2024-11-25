#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement

inputs:
  - id: sample
    type: tools/readgroup.cwl#readgroup_fastq_file
  - id: sequencing_center
    type: string

outputs:
  - id: readgroup
    type: tools/readgroup.cwl#readgroup_fastq_file
    outputSource: emit_readgroup/output

steps:
  - id: fastq_readgroup_to_json
    run: tools/fastq_readgroup_to_json.cwl
    in:
      - id: fastq
        source: sample
        valueFrom: $(self.forward_fastq)
      - id: sample
        source: sample
        valueFrom: $(self.readgroup_meta["SM"])
    out:
       - id: json

  - id: emit_readgroup
    run: tools/emit_readgroup_fastq.cwl
    in:
      - id: fastq1
        source: sample
        valueFrom: $(self.forward_fastq)
      - id: fastq2
        source: sample
        valueFrom: $(self.reverse_fastq)
      - id: readgroup_json
        source: fastq_readgroup_to_json/json
      - id: sequencing_center
        source: sequencing_center
    out:
      - id: output
