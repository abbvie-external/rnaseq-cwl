#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/star-sqlite:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 5
    tmpdirMax: 5
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: metric_name
    type:
      - "null"
      - type: enum
        symbols:
          - star_align
          - star_first_pass
          - star_second_pass
          - star_genomegenerate
    default: star_first_pass
    inputBinding:
      prefix: --metric_name

  - id: log_final_out_path
    type: File
    inputBinding:
      prefix: --log_final_out_path

  - id: log_out_path
    type: File
    inputBinding:
      prefix: --log_out_path

  - id: sj_out_tab_path
    type: File
    inputBinding:
      prefix: --sj_out_tab_path

  - id: readgroup_id
    type: string
    inputBinding:
      prefix: --readgroup_id
      
  - id: run_uuid
    type: string
    inputBinding:
      prefix: --run_uuid

  - id: sample
    type: string
    inputBinding:
      prefix: --sample

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.run_uuid)_$(inputs.metric_name).log

  - id: sqlite
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).db

baseCommand: [star_sqlite]
