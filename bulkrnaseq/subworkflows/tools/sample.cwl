  - name: aligned_sample
    type: record
    fields:
      - name: bam
        type: File
        secondaryFiles:
          - .bai
      - name: sqlite
        type: File
      - name: tar
        type: File
