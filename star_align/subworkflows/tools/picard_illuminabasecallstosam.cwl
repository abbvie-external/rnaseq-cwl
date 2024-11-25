#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/picard:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ShellCommandRequirement
  - class: ResourceRequirement:
    ramMin: 81920
    coresMin: 16

class: CommandLineTool

inputs:
  - id: barcodes_dir
    type: ["null", Directory]
    inputBinding:
      prefix: BARCODES_DIR=
      separate: false

  - id: basecalls_dir
    type: ["null", Directory]
    inputBinding:
      prefix: BASECALLS_DIR=
      separate: false
      valueFrom: $(self.path)/Data/Intensities/BaseCalls

  - id: lane
    type: ["null", long]
    inputBinding:
      prefix: LANE=
      separate: false

  - id: library_params
    type: ["null", File]
    inputBinding:
      prefix: LIBRARY_PARAMS=
      separate: false

  - id: read_structure
    type: string
    inputBinding:
      prefix: READ_STRUCTURE=
      separate: false

  - id: sequencing_center
    type: string
    inputBinding:
      prefix: SEQUENCING_CENTER=
      separate: false

  - id: run_barcode
    type: string
    inputBinding:
      prefix: RUN_BARCODE=
      separate: false

  - id: adapters_to_check
    type:
      - "null"
      - type: enum
        symbols:
          - INDEXED
          - DUAL_INDEXED
          - NEXTERA_V2
          - FLUIDIGM
    inputBinding:
      prefix: --ADAPTERS_TO_CHECK

  - id: apply_eamss_filter
    type: ["null", boolean]
    inputBinding:
      prefix: --APPLY_EAMSS_FILTER

  - id: arguments_file
    type: ["null", File]
    inputBinding:
      prefix: --arguments_file

  - id: compress_outputs
    type: ["null", boolean]
    inputBinding:
      prefix: --COMPRESS_OUTPUTS

  - id: max_mismatches
    type: ["null", long]
    inputBinding:
      prefix: --MAX_MISMATCHES

  - id: max_no_calls
    type: ["null", long]
    inputBinding:
      prefix: --MAX_NO_CALLS

  - id: min_mismatch_delta
    type: ["null", long]
    inputBinding:
      prefix: --MIN_MISMATCH_DELTA

  - id: minimum_base_quality
    type: ["null", long]
    inputBinding:
      prefix: --MINIMUM_BASE_QUALITY

  - id: MINIMUM_QUALITY
    type: ["null", long]
    inputBinding:
      prefix: --MINIMUM_QUALITY

  - id: NUM_PROCESSORS
    type: ["null", long]
    inputBinding:
      prefix: NUM_PROCESSORS=
      separate: false

  - id: version
    type: ["null", boolean]
    inputBinding:
      prefix: --version

  - id: compression_level
    type: ["null", long]
    inputBinding:
      prefix: --COMPRESSION_LEVEL

  - id: create_index
    type: ["null", boolean]
    inputBinding:
      prefix: --CREATE_INDEX

  - id: create_md5_file
    type: ["null", boolean]
    inputBinding:
      prefix: --CREATE_MD5_FILE

  - id: ga4gh_client_secrets
    type: ["null", File]
    inputBinding:
      prefix: --GA4GH_CLIENT_SECRETS

  - id: max_records_in_ram
    type: ["null", long]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      separate: false

  - id: quiet
    type: ["null", boolean]
    inputBinding:
      prefix: --QUIET

  - id: reference_sequence
    type: ["null", File]
    inputBinding:
      prefix: --REFERENCE_SEQUENCE

  - id: tmp_dir
    type: string
    default: "."
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: use_jdk_deflater
    type: ["null", boolean]
    inputBinding:
      prefix: --USE_JDK_DEFLATER

  - id: use_jdk_inflater
    type: ["null", boolean]
    inputBinding:
      prefix: --USE_JDK_INFLATER

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
  - id: bams
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.bam"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }

baseCommand:  [java, -Xms100G, -Xmx140G, -jar, /usr/local/bin/picard.jar, IlluminaBasecallsToSam]
