#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: ScatterFeatureRequirement

inputs:
  - id: readgroup_fastq
    type: tools/readgroup.cwl#readgroup_fastq_file
  - id: run_uuid
    type: string
  - id: thread_count
    type: long

outputs:
  - id: sqlite
    type: File
    outputSource: merge_fastq_metrics/destination_sqlite
  - id: tar
    type: File
    outputSource: tar_fastqc/output #tar_concat/output

steps:
  - id: fastqc
    run: tools/fastqc_pe.cwl
    in:
      - id: INPUT
        source: readgroup_fastq
        valueFrom: |
          ${
             var output = [];
             output.push(self.forward_fastq);
             if (self.reverse_fastq !== null) {
               output.push(self.reverse_fastq);
             }
             return output;
          }
      - id: threads
        valueFrom: $(2) # max at 2 cpu
    out:
      - id: fastqc_data_txt
      - id: summary_txt

  - id: fastqc_sqlite
    run: tools/fastqc_sqlite.cwl
    scatter: [fastqc_data_txt, summary_txt]
    scatterMethod: "dotproduct"
    in:
      - id: fastqc_data_txt
        source: fastqc/fastqc_data_txt
      - id: summary_txt
        source: fastqc/summary_txt
      - id: job_uuid
        source: run_uuid
    out:
      - id: log
      - id: output

  - id: merge_fastq_metrics
    run: tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
          fastqc_sqlite/output,
        ]
      - id: job_uuid
        source: run_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: tar_fastqc
    run: tools/tar_files.cwl
    in:
      - id: input
        linkMerge: merge_flattened
        source: [
        fastqc/fastqc_data_txt,
        fastqc/summary_txt
        ]
      - id: dirname
        source: readgroup_fastq
        valueFrom: $(self.readgroup_meta["ID"])_fastqc
    out:
      - id: output
