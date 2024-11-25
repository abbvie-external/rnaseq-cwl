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
    ramMin: 4000
    ramMax: 4000
    tmpdirMin: $(Math.ceil (1.1 * inputs.reference.size / 1048576))
    tmpdirMax: $(Math.ceil (1.1 * inputs.reference.size / 1048576))
    outdirMin: $(Math.ceil (1.1 * inputs.reference.size / 1048576))
    outdirMax: $(Math.ceil (1.1 * inputs.reference.size / 1048576))

class: CommandLineTool

inputs:
  - id: create_index
    type:
      - "null"
      - type: enum
        symbols:
          - "false"
          - "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  - id: create_md5_file
    type:
      - "null"
      - type: enum
        symbols:
          - "false"
          - "true"
    inputBinding:
      prefix: CREATE_MD5_FILE=
      separate: false

  - id: reference
    type: File
    inputBinding:
      prefix: REFERENCE=
      separate: false

  - id: uri
    type: ["null", string]
    inputBinding:
      prefix: URI=
      separate: false

  - id: species
    type: string
    inputBinding:
      prefix: SPECIES=
      separate: false

  - id: tmp_dir
    type: string
    default: .
    inputBinding:
      prefix: TMP_DIR=
      separate: false

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.reference.nameroot).dict

arguments:
  - valueFrom: $(inputs.reference.nameroot)
    prefix: GENOME_ASSEMBLY=
    separate: false
  
  - valueFrom: $(inputs.reference.nameroot).dict
    prefix: OUTPUT=
    separate: false

baseCommand: [java, -jar, /usr/local/bin/picard.jar, CreateSequenceDictionary]
