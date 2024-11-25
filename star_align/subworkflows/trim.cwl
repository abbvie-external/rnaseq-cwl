#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement

inputs:
  - id: fastq_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_file
  - id: run_uuid
    type: string
  - id: thread_count
    type: long

outputs:
  - id: output_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_file
    outputSource: trimgalore/output
  - id: tar
    type: File
    outputSource: tar_report/output

steps:
  - id: trimgalore
    run: tools/trimgalore.cwl
    in:
      - id: fastq_readgroup
        source: fastq_readgroup
      - id: cores
        source: thread_count
      - id: paired
        source: fastq_readgroup
        valueFrom: |
          ${
            if (!self['reverse_fastq']) {
              return false;
            } else {
              return true;
            }
          }
    out:
      - id: output
      - id: report1
      - id: report2

  # - id: trim_sqlite_report1
  #   run: tools/trimgalore_to_sqlite.cwl
  #   in:
  #     - id: metrics_path
  #       source: trimgalore/report1
  #     - id: run_uuid
  #       source: run_uuid
  #   out:
  #     - id: sqlite

  # - id: trim_sqlite_report2
  #   run: tools/trimgalore_to_sqlite.cwl
  #   in:
  #     - id: metrics_path
  #       source: trimgalore/report2
  #     - id: run_uuid
  #       source: run_uuid
  #   out:
  #     - id: sqlite

  # - id: merge_sqlite
  #   run: tools/merge_sqlite.cwl
  #   in:
  #     - id: source_sqlite
  #       source: [
  #         trim_sqlite_report1/sqlite,
  #         trim_sqlite_report2/sqlite
  #       ]
  #     - id: job_uuid
  #       source: run_uuid
  #   out:
  #     - id: destination_sqlite
  #     - id: log

  - id: tar_report
    run: tools/tar_files.cwl
    in:
      - id: input
        source: [
        trimgalore/report1,
        trimgalore/report2
        ]
        valueFrom: |
          ${
          var output = [];
           for (var i = 0; i < self.length; i++) {
             if (self[i] !== null) {
               output.push(self[i]);
             }
           }
           return output;
          }
      - id: dirname
        source: fastq_readgroup
        valueFrom: $(self.readgroup_meta["ID"])_trimgalore
    out:
      - id: output
