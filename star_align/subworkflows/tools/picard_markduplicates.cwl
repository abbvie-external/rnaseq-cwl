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
    ramMin: 14000
    ramMax: 16000

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 10
    
class: CommandLineTool

inputs:
  - id: create_index
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  - id: input
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  - id: tmp_dir
    default: .
    type: string
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: validation_stringency
    default: STRICT
    type: string
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - ^.bai

  - id: metrics
    type: File
    outputBinding:
      glob: $(inputs.input.basename).markdup.txt

arguments:
  - valueFrom: $(inputs.input.basename)
    prefix: OUTPUT=
    separate: false

  - valueFrom: $(inputs.input.basename).markdup.txt
    prefix: METRICS_FILE=
    separate: false

baseCommand: [java, -jar, /usr/local/bin/picard.jar, MarkDuplicates]
