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
    ramMax: 6000

class: CommandLineTool

inputs:
  - id: aligned_bam
    type: File
    inputBinding:
      prefix: ALIGNED_BAM=
      separate: false

  - id: create_index
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  - id: output
    type: string
    inputBinding:
      prefix: OUTPUT=
      separate: false

  - id: reference_sequence
    type: File
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      separate: false
    secondaryFiles:
      - ^.dict

  - id: tmp_dir
    type: string
    default: .
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: unmapped_bam
    type: File
    inputBinding:
      prefix: UNMAPPED_BAM=
      separate: false

outputs:
  - id: merged_output
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - ^.bai

baseCommand: [java, -jar, /usr/local/bin/picard.jar, MergeBamAlignment]
