cwlVersion: v1.2

class: Workflow

requirements:
  - class: StepInputExpressionRequirement

inputs:
  - id: any_se_readgroups
    type: boolean
  - id: aligned_bam
    type: File
  - id: umi-separator
    type: string

outputs:
  - id: dedup_bam
    type: File
    outputSource: bamindex/indexedbam
  - id: tar
    type: File
    outputSource: tar_report/output

steps:
  - id: dedup
    run: tools/umi_tools_dedup.cwl
    in:
      - id: stdin-file
        source: aligned_bam
      - id: stdout_file
        source: aligned_bam
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam
      - id: log
        source: aligned_bam
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam.log
      - id: output-stats
        source: aligned_bam
        valueFrom: $(self.basename.split('.').slice(0,-3).join('.')).dedup.bam.stats
      - id: umi-separator
        source: umi-separator
      - id: paired
        source: any_se_readgroups
        valueFrom: $(!self)
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

  - id: tar_report
    run: tools/tar_files.cwl
    in:
      - id: input
        source: dedup/outlog
        valueFrom: $([self])
      - id: dirname
        valueFrom: umi_dedup
    out:
      - id: output
