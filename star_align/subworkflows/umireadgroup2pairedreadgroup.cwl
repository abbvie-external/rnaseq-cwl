#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl

inputs:
  - id: readgroup_umi
    type: tools/readgroup.cwl#readgroup_umi
  - id: sequencing_center
    type: string
  - id: thread_count
    type: long

outputs:
  - id: fastq_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_file
    outputSource: emit_readgroup/output


steps:
  - id: fastq_readgroup_to_json
    run: tools/fastq_readgroup_to_json.cwl
    in:
      - id: fastq
        source: readgroup_umi
        valueFrom: $(self.forward_fastq)
      - id: sample
        source: readgroup_umi
        valueFrom: $(self.readgroup_meta["SM"])
    out:
       - id: json

#  - id: fastq_reheader
#    run: tools/fastq_reheader_umi.cwl
#    in:
#      - id: readgroup_umi
#        source: readgroup_umi
#      - id: thread_count
#        source: thread_count
#    out:
#      - id: forward_fastq
#      - id: reverse_fastq

  - id: emit_readgroup
    run: tools/emit_readgroup_fastq.cwl
    in:
      - id: fastq1
        source: fastq_reheader/forward_fastq
      - id: fastq2
        source: fastq_reheader/reverse_fastq
      - id: readgroup_json
        source: fastq_readgroup_to_json/json
      - id: sequencing_center
        source: sequencing_center
    out:
      - id: output
