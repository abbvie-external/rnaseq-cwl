#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
 - class: StepInputExpressionRequirement
 - class: MultipleInputFeatureRequirement

inputs:
  - id: bai
    type: File
  - id: bam
    type: File
  - id: input_state
    type: string
  - id: run_uuid
    type: string

outputs:
  - id: sqlite
    type: File
    outputSource: merge_sqlite/destination_sqlite

steps:
  - id: bai_ls_l
    run: tools/ls_l.cwl
    in:
      - id: input
        source: bai
    out:
      - id: output

  - id: bai_md5sum
    run: tools/md5sum.cwl
    in:
      - id: input
        source: bai
    out:
      - id: output

  - id: bai_sha256
    run: tools/sha256sum.cwl
    in:
      - id: input
        source: bai
    out:
      - id: output

  - id: bam_ls_l
    run: tools/ls_l.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: bam_md5sum
    run: tools/md5sum.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: bam_sha256
    run: tools/sha256sum.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: bai_integrity_to_db
    run: tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: bai_ls_l/output
      - id: md5sum_path
        source: bai_md5sum/output
      - id: sha256sum_path
        source: bai_sha256/output
      - id: run_uuid
        source: run_uuid
    out:
      - id: output

  - id: bam_integrity_to_db
    run: tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: bam_ls_l/output
      - id: md5sum_path
        source: bam_md5sum/output
      - id: sha256sum_path
        source: bam_sha256/output
      - id: run_uuid
        source: run_uuid
    out:
      - id: output

  - id: merge_sqlite
    run: tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
        bai_integrity_to_db/output,
        bam_integrity_to_db/output
        ]
      - id: job_uuid
        source: run_uuid
    out:
      - id: destination_sqlite
      - id: log
