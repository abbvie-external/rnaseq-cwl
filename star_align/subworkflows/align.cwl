#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: StepInputExpressionRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: SubworkflowFeatureRequirement

inputs:
  - id: fastq_readgroup
    type: tools/readgroup.cwl#readgroup_fastq_file
  - id: fasta
    type: File
    secondaryFiles:
      - ^.dict
  - id: run_uuid
    type: string
  - id: thread_count
    type: long
  - id: genome_chrLength_txt
    type: File
  - id: genome_chrNameLength_txt
    type: File
  - id: genome_chrName_txt
    type: File
  - id: genome_chrStart_txt
    type: File
  - id: genome_exonGeTrInfo_tab
    type: File
  - id: genome_Genome
    type: File
  - id: genome_genomeParameters_txt
    type: File
  - id: genome_SA
    type: File
  - id: genome_SAindex
    type: File
  - id: genome_sjdbInfo_txt
    type: File
  - id: genome_sjdbList_fromGTF_out_tab
    type: File
  - id: genome_sjdbList_out_tab
    type: File
  - id: star_alignIntronMax
    type: [long, "null"]
  - id: star_alignIntronMin
    type: [long, "null"]
  - id: star_alignMatesGapMax
    type: [long, "null"]
  - id: star_alignSJDBoverhangMin
    type: [long, "null"]
  - id: star_alignSJoverhangMin
    type: [long, "null"]
  - id: star_limitBAMsortRAM
    type: [long, "null"]
  - id: star_outBAMsortingBinsN
    type: [long, "null"]
  - id: star_outFilterMatchNmin
    type: [float, "null"]
  - id: star_outFilterMatchNminOverLread
    type: [float, "null"]
  - id: star_outFilterMismatchNmax
    type: [long, "null"]
  - id: star_outFilterMismatchNoverLmax
    type: [float, "null"]
  - id: star_outFilterMismatchNoverReadLmax
    type: [float, "null"]
  - id: star_outFilterMultimapNmax
    type: [long, "null"]
  - id: umi_enabled
    type: boolean
  - id: umi-separator
    type: string

outputs:
  - id: out_bam
    type: File
    outputSource: star_align/out_bam
  - id: tar
    type: File
    outputSource: tar_logs/output

steps:
  - id: star_align
    run: tools/star_align.cwl
    in:
      - id: fastq_readgroup
        source: fastq_readgroup
      - id: genome_chrLength_txt
        source: genome_chrLength_txt
      - id: genome_chrNameLength_txt
        source: genome_chrNameLength_txt
      - id: genome_chrName_txt
        source: genome_chrName_txt
      - id: genome_chrStart_txt
        source: genome_chrStart_txt
      - id: genome_exonGeTrInfo_tab
        source: genome_exonGeTrInfo_tab
      - id: genome_Genome
        source: genome_Genome
      - id: genome_genomeParameters_txt
        source: genome_genomeParameters_txt
      - id: genome_SA
        source: genome_SA
      - id: genome_SAindex
        source: genome_SAindex
      - id: genome_sjdbInfo_txt
        source: genome_sjdbInfo_txt
      - id: genome_sjdbList_fromGTF_out_tab
        source: genome_sjdbList_fromGTF_out_tab
      - id: genome_sjdbList_out_tab
        source: genome_sjdbList_out_tab
      - id: runThreadN
        source: thread_count
      - id: alignIntronMax
        source: star_alignIntronMax
      - id: alignIntronMin
        source: star_alignIntronMin
      - id: alignMatesGapMax
        source: star_alignMatesGapMax
      - id: alignSJDBoverhangMin
        source: star_alignSJDBoverhangMin
      - id: alignSJoverhangMin
        source: star_alignSJoverhangMin
      - id: limitBAMsortRAM
        source: star_limitBAMsortRAM
      - id: outBAMsortingBinsN
        source: star_outBAMsortingBinsN
      - id: outFilterMatchNmin
        source: star_outFilterMatchNmin
      - id: outFilterMatchNminOverLread
        source: star_outFilterMatchNminOverLread
      - id: outFilterMismatchNmax
        source: star_outFilterMismatchNmax
      - id: outFilterMismatchNoverLmax
        source: star_outFilterMismatchNoverLmax
      - id: outFilterMismatchNoverReadLmax
        source: star_outFilterMismatchNoverReadLmax
      - id: outFilterMultimapNmax
        source: star_outFilterMultimapNmax
    out:
      - id: out_bam
      - id: Log_final_out
      - id: Log_out
      - id: Log_progress_out
      - id: SJ_out_tab

  - id: tar_logs
    run: tools/tar_files.cwl
    in:
      - id: input
        source: [
        star_align/Log_final_out,
        star_align/Log_out,
        star_align/Log_progress_out,
        star_align/SJ_out_tab
        ]
      - id: dirname
        source: fastq_readgroup
        valueFrom: $(self.readgroup_meta["ID"])_star_align
    out:
      - id: output

  # - id: star_align_sqlite
  #   run: tools/star_align_sqlite.cwl
  #   in:
  #     - id: readgroup_id
  #       source: fastq_readgroup
  #       valueFrom: $(self.readgroup_meta['ID'])
  #     - id: log_final_out_path
  #       source: star_align/Log_final_out
  #     - id: log_out_path
  #       source: star_align/Log_out
  #     - id: sj_out_tab_path
  #       source: star_align/SJ_out_tab
  #     - id: run_uuid
  #       source: run_uuid
  #     - id: sample
  #       source: fastq_readgroup
  #       valueFrom: $(self.readgroup_meta['SM'])
  #   out:
  #     - id: log
  #     - id: sqlite
