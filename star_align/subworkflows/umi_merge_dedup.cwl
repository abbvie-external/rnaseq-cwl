cwlVersion: v1.2

class: Workflow

requirements:
  - class: StepInputExpressionRequirement

inputs:
  - id: aligned_bam
    type: File
  - id: fasta
    type: File
    secondaryFiles:
      - ^.dict
  - id: unmapped_bam
    type: File

outputs:
  - id: dedup_bam
    type: File
    outputSource: bamindex/indexedbam

steps:
  - id: mergebamalignment
    run: tools/picard_mergebamalignment.cwl
    in:
      - id: aligned_bam
        source: aligned_bam
      - id: output
        source: aligned_bam
        valueFrom: $(self.basename)
      - id: reference_sequence
        source: fasta
      - id: unmapped_bam
        source: unmapped_bam
    out:
      - id: merged_output

  - id: dedup
    run: tools/umi_tools_dedup.cwl
    in:
      - id: stdin_file
        source: mergebamalignment/merged_output
      - id: stdout_file
        source: mergebamalignment/merged_output
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam
      - id: extract-umi-method
        valueFrom: tag
      - id: umi-tag
        valueFrom: RX
      - id: log
        source: mergebamalignment/merged_output
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam.log
      - id: output_stats
        source: mergebamalignment/merged_output
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam.stats
    out:
      - id: dedup_bam
      - id: outlog

  - id: bamindex
    run: tools/picard_buildbamindex.cwl
    in:
      - id: input
        source: dedup/dedup_bam
    out:
      - id: indexedbam
