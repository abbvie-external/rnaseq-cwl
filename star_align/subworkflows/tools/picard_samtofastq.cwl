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
  - id: input
    type: File
    inputBinding:
      prefix: INPUT=
      separate: false

  - id: fastq
    type: ["null", string]
    inputBinding:
      prefix: FASTQ=
      separate: false

  - id: clipping_action
    type: ["null", string]
    inputBinding:
      prefix: CLIPPING_ACTION=
      separate: false

  - id: clipping_attribute
    type: ["null", string]
    inputBinding:
      prefix: CLIPPING_ATTRIBUTE=
      separate: false

  - id: clipping_min_length
    type: ["null", long]
    inputBinding:
      prefix: CLIPPING_MIN_LENGTH=
      separate: false

  - id: compress_outputs_per_rg
    type:
      - "null"
      - type: enum
        symbols:
          - "true"
          - "false"
    inputBinding:
      prefix: COMPRESS_OUTPUTS_PER_RG=
      separate: false

  - id: include_non_pf_reads
    type: ["null", boolean]
    inputBinding:
      prefix: INCLUDE_NON_PF_READS

  - id: include_non_primary_alignments
    type: ["null", boolean]
    inputBinding:
      prefix: INCLUDE_NON_PRIMARY_ALIGNMENTS

  - id: interleave
    type: ["null", boolean]
    inputBinding:
      prefix: INTERLEAVE

  - id: output_dir
    type: ["null", string]
    inputBinding:
      prefix: OUTPUT_DIR=
      separate: false

  - id: output_per_rg
    type:
      - "null"
      - type: enum
        symbols:
          - "true"
          - "false"
    inputBinding:
      prefix: OUTPUT_PER_RG=
      separate: false

  - id: quality
    type: ["null", long]
    inputBinding:
      prefix: QUALITY=
      separate: false

  - id: re_reverse
    type: ["null", boolean]
    inputBinding:
      prefix: RE_REVERSE

  - id: read1_max_bases_to_write
    type: ["null", long]
    inputBinding:
      prefix: READ1_MAX_BASES_TO_WRITE=
      separate: false

  - id: read1_trim
    type: ["null", long]
    inputBinding:
      prefix: READ1_TRIM=
      separate: false

  - id: read2_max_bases_to_write
    type: ["null", long]
    inputBinding:
      prefix: READ2_MAX_BASES_TO_WRITE=
      separate: false

  - id: read2_trim
    type: ["null", long]
    inputBinding:
      prefix: READ2_TRIM=
      separate: false

  - id: rg_tag
    type: ["null", string]
    inputBinding:
      prefix: RG_TAG=
      separate: false

  - id: second_end_fastq
    type: ["null", string]
    inputBinding:
      prefix: SECOND_END_FASTQ=
      separate: false

  - id: unpaired_fastq
    type: ["null", string]
    inputBinding:
      prefix: UNPAIRED_FASTQ=
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
      prefix: CREATE_INDEX

  - id: create_md5_file
    type: ["null", boolean]
    inputBinding:
      prefix: CREATE_MD5_FILE

  - id: ga4gh_client_secrets
    type: ["null", File]
    inputBinding:
      prefix: --GA4GH_CLIENT_SECRETS

  - id: max_records_in_ram
    type: ["null", long]
    inputBinding:
      prefix: --MAX_RECORDS_IN_RAM

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
      prefix: --USE_JDK_DEFLATER

  - id: use_jdk_inflater
    type: ["null", boolean]
    inputBinding:
      prefix: --USE_JDK_INFLATER

outputs:
  - id: output
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.fastq*"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }

baseCommand:  ["java", "-jar", "/usr/local/bin/picard.jar", "SamToFastq"]
