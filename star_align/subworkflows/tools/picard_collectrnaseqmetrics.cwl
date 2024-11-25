#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/picard:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 22000
    ramMax: 22000
    tmpdirMin: $(Math.ceil ((inputs.input.size + inputs.ref_flat.size) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.input.size + inputs.ref_flat.size) / 1048576))
    outdirMin: 5
    outdirMax: 5

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 5

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  - id: ref_flat
    type: File
    inputBinding:
      prefix: REF_FLAT=
      separate: false

  - id: ribosomal_intervals
    type: ["null", File]
    inputBinding:
      prefix: RIBOSOMAL_INTERVALS=
      separate: false

  - id: strand_specificity
    type:
      - "null"
      - type: enum
        symbols:
          - NONE
          - FIRST_READ_TRANSCRIPTION_STRAND
          - SECOND_READ_TRANSCRIPTION_STRAND
    inputBinding:
      prefix: STRAND_SPECIFICITY=
      separate: false

  - id: minimum_length
    type: ["null", long]
    inputBinding:
      prefix: MINIMUM_LENGTH=
      separate: false

  - id: rrna_fragment_percentage
    type: ["null", double]
    inputBinding:
      prefix: RRNA_FRAGMENT_PERCENTAGE=
      separate: false

  - id: metric_accumulation_level
    type: ["null", string]
    inputBinding:
      prefix: METRIC_ACCUMULATION_LEVEL=
      separate: false

  - id: assume_sorted
    type: ["null", string]
    default: "true"
    inputBinding:
      prefix: ASSUME_SORTED=
      separate: false

  - id: stop_after
    type: ["null", long]
    inputBinding:
      prefix: STOP_AFTER=
      separate: false

  - id: tmp_dir
    type: string
    default: "."
    inputBinding:
      prefix: TMP_DIR=
      separate: false

outputs:
  - id: metrics
    type: File
    outputBinding:
      glob: $(inputs.input.nameroot).CollectRnaSeqMetrics.txt

  - id: pdf
    type: ["null", File]
    outputBinding:
      glob: $(inputs.input.nameroot).CollectRnaSeqMetrics.pdf

arguments:
  - valueFrom: $(inputs.input.nameroot).CollectRnaSeqMetrics.txt
    prefix: OUTPUT=
    separate: false

  - valueFrom: $(inputs.input.nameroot).CollectRnaSeqMetrics.pdf
    prefix: CHART_OUTPUT=
    separate: false

baseCommand: [java, -jar, /usr/local/bin/picard.jar, CollectRnaSeqMetrics]
