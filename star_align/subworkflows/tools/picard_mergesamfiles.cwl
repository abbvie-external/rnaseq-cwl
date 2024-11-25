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
    ramMin: 250
    ramMax: 250
    tmpdirMin: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.input.length; i++) {
          req_space += inputs.input[i].size;
        }
      return Math.ceil(2 * req_space / 1048576);
      }      
    tmpdirMax: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.input.length; i++) {
          req_space += inputs.input[i].size;
        }
      return Math.ceil(2 * req_space / 1048576);
      }      
    outdirMin: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.input.length; i++) {
          req_space += inputs.input[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }      
    outdirMax: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.input.length; i++) {
          req_space += inputs.input[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }

class: CommandLineTool

inputs:
  - id: assume_sorted
    type: boolean
    default: false
    inputBinding:
      prefix: ASSUME_SORTED=
      separate: false

  - id: create_index
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  - id: input
    type:
      type: array
      items: File
      inputBinding:
        prefix: INPUT=
        separate: false

  - id: intervals
    type: ["null", File]
    inputBinding:
      prefix: INTERVALS=
      separate: false

  - id: merge_sequence_dictionaries
    type: string
    default: "false"
    inputBinding:
      prefix: MERGE_SEQUENCE_DICTIONARIES=
      separate: false

  - id: output
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

  - id: sort_order
    type: string
    default: coordinate
    inputBinding:
      prefix: SORT_ORDER=
      separate: false

  - id: tmp_dir
    type: string
    default: .
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: use_threading
    type: string
    default: "true"
    inputBinding:
      prefix: USE_THREADING=
      separate: false

  - id: validation_stringency
    type: string
    default: STRICT
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

outputs:
  - id: merged_output
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - ^.bai

baseCommand: [java, -jar, /usr/local/bin/picard.jar, MergeSamFiles]
