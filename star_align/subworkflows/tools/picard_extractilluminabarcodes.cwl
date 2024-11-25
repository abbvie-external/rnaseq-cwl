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
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: barcode
    type: ["null", string]
    inputBinding:
      prefix: BARCODE=
      separate: False

  - id: barcode_file
    type: ["null", File]
    inputBinding:
      prefix: BARCODE_FILE=
      separate: False

  - id: basecalls_dir
    type: ["null", Directory]
    inputBinding:
      prefix: BASECALLS_DIR=
      separate: False
      valueFrom: $(self.path)/Data/Intensities/BaseCalls

  - id: lane
    type: ["null", long]
    inputBinding:
      prefix: LANE=
      separate: False

  - id: metrics_file
    type: string
    inputBinding:
      prefix: METRICS_FILE=
      separate: False

  - id: read_structure
    type: string
    inputBinding:
      prefix: READ_STRUCTURE=
      separate: False

  - id: arguments_file
    type: ["null", File]
    inputBinding:
      prefix: ARGUMENTS_FILE=
      separate: False

  - id: compress_outputs
    type: ["null", boolean]
    inputBinding:
      prefix: COMPRESS_OUTPUTS

  - id: max_mismatches
    type: ["null", long]
    inputBinding:
      prefix: MAX_MISMATCHES

  - id: max_no_calls
    type: ["null", long]
    inputBinding:
      prefix: MAX_NO_CALLS

  - id: min_mismatch_delta
    type: ["null", long]
    inputBinding:
      prefix: MIN_MISMATCH_DELTA

  - id: minimum_base_quality
    type: ["null", long]
    inputBinding:
      prefix: MINIMUM_BASE_QUALITY

  - id: MINIMUM_QUALITY
    type: ["null", long]
    inputBinding:
      prefix: MINIMUM_QUALITY

  - id: NUM_PROCESSORS
    type: ["null", long]
    inputBinding:
      prefix: NUM_PROCESSORS=
      separate: false

  - id: OUTPUT_DIR
    type: string
    default: "."
    inputBinding:
      prefix: OUTPUT_DIR=
      separate: false

  - id: version
    type: ["null", boolean]
    inputBinding:
      prefix: version

  - id: compression_level
    type: ["null", long]
    inputBinding:
      prefix: COMPRESSION_LEVEL

  - id: create_index
    type: ["null", boolean]
    inputBinding:
      prefix: CREATE_INDEX

  - id: create_md5_file
    type: ["null", boolean]
    inputBinding:
      prefix: CREATE_MD5_FILE

  - id: ga4gh_client_secrets
    type: ["null", File]
    inputBinding:
      prefix: GA4GH_CLIENT_SECRETS

  - id: max_records_in_ram
    type: ["null", long]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM

  - id: quiet
    type: ["null", boolean]
    inputBinding:
      prefix: QUIET

  - id: reference_sequence
    type: ["null", File]
    inputBinding:
      prefix: REFERENCE_SEQUENCE

  - id: tmp_dir
    type: string
    default: "."
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: use_jdk_deflater
    type: ["null", boolean]
    inputBinding:
      prefix: USE_JDK_DEFLATER

  - id: use_jdk_inflater
    type: ["null", boolean]
    inputBinding:
      prefix: USE_JDK_INFLATER

  - id: validation_stringency
    type:
      - "null"
      - type: enum
        symbols:
          - STRICT
          - LENIENT
          - SILENT
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

  - id: verbosity
    type:
      - "null"
      - type: enum
        symbols:
          - ERROR
          - WARNING
          - INFO
          - DEBUG
    inputBinding:
      prefix: VERBOSITY=
      separate: false

outputs:
  - id: metrics
    type: File
    outputBinding:
      glob: $(inputs.metrics_file)

  - id: barcodes
    type:
      type: array
      items: File
    outputBinding:
      glob: "*_barcode.txt"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }

baseCommand: [java, -Xms30G, -Xmx60G, -jar, /usr/local/bin/picard.jar, ExtractIlluminaBarcodes]
