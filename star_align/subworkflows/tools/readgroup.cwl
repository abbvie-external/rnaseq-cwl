  - name: readgroup_meta
    type: record
    fields:
      - name: CN
        type: ["null", string]
      - name: DS
        type: ["null", string]
      - name: DT
        type: ["null", string]
      - name: FO
        type: ["null", string]
      - name: ID
        type: ["null", string]
      - name: KS
        type: ["null", string]
      - name: LB
        type: ["null", string]
      - name: PI
        type: ["null", string]
      - name: PL
        type: ["null", string]
      - name: PM
        type: ["null", string]
      - name: PU
        type: ["null", string]
      - name: SM
        type: ["null", string]

  - name: readgroup_fastq_file
    type: record
    fields:
      - name: forward_fastq
        type: File
      - name: reverse_fastq
        type: ["null", File]
      - name: readgroup_meta
        type: readgroup_meta

  - name: readgroup_fastq_bam
    type: record
    fields:
      - name: bam
        type: ["null",File]
      - name: forward_fastq
        type: File
      - name: reverse_fastq
        type: ["null", File]
      - name: readgroup_meta
        type: readgroup_meta

  - name: readgroup_fastq_uuid
    type: record
    fields:
      - name: forward_fastq_uuid
        type: string
      - name: forward_fastq_file_size
        type: long
      - name: reverse_fastq_uuid
        type: ["null", string]
      - name: reverse_fastq_file_size
        type: ["null", long]
      - name: readgroup_meta
        type: readgroup_meta


  - name: readgroup_umi
    type: record
    fields:
      - name: forward_fastq
        type: File
      - name: reverse_fastq
        type: File
      - name: umi_fastq
        type: File
      - name: readgroup_meta
        type: readgroup_meta
