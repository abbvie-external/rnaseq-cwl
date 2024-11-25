#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/samtools-metrics-sqlite:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 250
    ramMax: 250
    tmpdirMin: $(Math.ceil (2 * inputs.metric_path.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.metric_path.size / 1048576))
    outdirMin: $(Math.ceil (inputs.metric_path.size / 1048576))
    outdirMax: $(Math.ceil (inputs.metric_path.size / 1048576))

class: CommandLineTool

inputs:
  - id: bam
    type: string
    inputBinding:
      prefix: --bam

  - id: input_state
    type: string
    inputBinding:
      prefix: --input_state

  - id: metric_path
    type: File
    inputBinding:
      prefix: --metric_path

  - id: run_uuid
    type: string
    inputBinding:
      prefix: --job_uuid

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.run_uuid)_samtools_stats.log

  - id: sqlite
    type: File
    outputBinding:
      glob: $(inputs.run_uuid).db

baseCommand: [/usr/local/bin/samtools_metrics_sqlite, --metric_name, stats]
