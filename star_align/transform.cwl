#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: subworkflows/tools/readgroup.cwl
      - $import: subworkflows/tools/gtf_type.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: dbsnp
    type: ["null", File]
    secondaryFiles:
      - .tbi
  - id: fasta
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
  - id: fasta_cdna
    type: File
  - id: featurecounts_allowmultioverlap
    type: ["null", boolean]
  - id: featurecounts_byreadgroup
    type: ["null", boolean]
  - id: featurecounts_countreadpairs
    type: ["null", boolean]
  - id: featurecounts_checkfraglength
    type: ["null", boolean]
  - id: featurecounts_countmultimappingreads
    type: ["null", boolean]
  - id: featurecounts_fraction
    type: ["null", float]
  - id: featurecounts_fracoverlap
    type: ["null", float]
  - id: featurecounts_fracoverlapfeature
    type: ["null", float]
  - id: featurecounts_ignoredup
    type: ["null", boolean]
  - id: featurecounts_islongread
    type: ["null", boolean]
  - id: featurecounts_junccounts
    type: boolean
  - id: featurecounts_largestoverlap
    type: ["null", long]
  - id: featurecounts_minfraglength
    type: ["null", long]
  - id: featurecounts_maxfraglength
    type: ["null", long]
  - id: featurecounts_maxmop
    type: ["null", long]
  - id: featurecounts_minmqs
    type: ["null", long]
  - id: featurecounts_minoverlap
    type: ["null", long]
  - id: featurecounts_nonoverlap
    type: ["null", long]
  - id: featurecounts_nonoverlapfeature
    type: ["null", long]
  - id: featurecounts_nonsplitonly
    type: ["null", boolean]
  - id: featurecounts_notcountchimericfragments
    type: ["null", boolean]
  - id: featurecounts_primary
    type: ["null", boolean]
  - id: featurecounts_read2pos
    type: ["null", long]
  - id: featurecounts_readextension3
    type: ["null", long]
  - id: featurecounts_readextension5
    type: ["null", long]
  - id: featurecounts_readshiftsize
    type: ["null", long]
  - id: featurecounts_readshifttype
    type:
      - "null"
      - type: enum
        symbols:
          - downstream
          - left
          - right
          - upstream
  - id: featurecounts_reportreads
    type:
      - "null"
      - type: enum
        symbols:
          - BAM
          - CORE
          - SAM
  - id: featurecounts_requirebothendsmapped
    type: ["null", boolean]
  - id: featurecounts_splitonly
    type: ["null", boolean]
  - id: featurecounts_usemetafeatures
    type: ["null", boolean]
  - id: featurecounts_GTF_attrType
    type:
      type: array
      items: subworkflows/tools/gtf_type.cwl#GTF_attrType
  - id: featurecounts_GTF_featureType
    type:
      type: array
      items: subworkflows/tools/gtf_type.cwl#GTF_featureType
  - id: gtf
    type: File
  - id: collapsed_bed
    type: File
  - id: collapsed_gtf
    type: File
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
  - id: kallisto_enabled
    type: boolean
  - id: kallisto_index
    type: File
  - id: kallisto_hawsh_index
    type: File
  - id: kallisto_quant_bootstrap_samples
    type: long
  - id: ref_flat
    type: File
  - id: rrna_intervallist
    type: File
  - id: fastq_readgroup_list
    type:
      type: array
      items: subworkflows/tools/readgroup.cwl#readgroup_fastq_file
  - id: run_markduplicates
    type: boolean
  - id: run_tpmcalculator
    type: boolean
  - id: run_variantcall_joint
    type: boolean
  - id: run_variantcall_single
    type: boolean
  - id: run_uuid
    type: string
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
  - id: star_limitBAMsortRAM # 31430254745 (SRR4785812,SRR4785813)
    type: [long, "null"]
  - id: star_outBAMsortingBinsN # 200 (SRR4785812,SRR4785813)
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
  - id: stranded
    type: boolean
  - id: thread_count
    type: long
  - id: umi_enabled
    type: boolean
  - id: umi-separator
    type: string
  - id: variantcall_contigs
    type:
      type: array
      items: string

outputs:
  - id: bam
    type: File
    outputSource: decider_bqsr_bam/bam
  - id: sqlite
    type: File
    outputSource: merge_all_sqlite/destination_sqlite
  - id: tar
    type: File
    outputSource: tar_all_concat/output
  - id: variants
    type: [File, "null"]
    outputSource: germline_variants/variants

steps:
  - id: trim
    run: subworkflows/trim.cwl
    scatter: fastq_readgroup
    in:
      - id: fastq_readgroup
        source: fastq_readgroup_list
      - id: run_uuid
        source: run_uuid
      - id: thread_count
        source: thread_count
    out:
      - id: output_readgroup
      - id: tar

  - id: tar_concat_trim
    run: subworkflows/tools/tar_concat.cwl
    in:
      - id: archives
        source: trim/tar
      - id: tar_out
        valueFrom: trimgalore.tar
    out:
      - id: output

  # - id: merge_sqlite_trim
  #   run: subworkflows/tools/merge_sqlite.cwl
  #   in:
  #     - id: source_sqlite
  #       source: trim/sqlite
  #     - id: job_uuid
  #       source: run_uuid
  #   out:
  #     - id: destination_sqlite
  #     - id: log

  - id: what_strand
    run: subworkflows/what_strand.cwl
    in:
      - id: gtf
        source: gtf
      - id: fasta
        source: fasta_cdna
      - id: fastq_readgroup
        source: trim/output_readgroup
        valueFrom: $(self[0])
      - id: kallisto_index
        source: kallisto_hawsh_index
      - id: stranded
        source: stranded
    out:
      - id: strand
      - id: ss_len_med
      - id: ss_len_sd
    when: $(inputs.stranded)

  - id: kallisto
    run: subworkflows/kallisto.cwl
    in:
      - id: fastq_readgroups
        source: trim/output_readgroup
      - id: gtf
        source: gtf
      - id: kallisto_index
        source: kallisto_index
      - id: strand
        source: what_strand/strand
      - id: thread_count
        source: thread_count
      - id: kallisto_enabled
        source: kallisto_enabled
      - id: kallisto_quant_bootstrap_samples
        source: kallisto_quant_bootstrap_samples
      - id: fragment_length
        source: what_strand/ss_len_med
      - id: sample_id
        source: fastq_readgroup_list
        valueFrom: $(self[0].readgroup_meta["SM"])
      - id: std_dev
        source: what_strand/ss_len_sd
    out:
      - id: tar
    when: $(inputs.kallisto_enabled)

  - id: fastq_metrics
    run: subworkflows/fastq_metrics.cwl
    scatter: readgroup_fastq
    in:
      - id: readgroup_fastq
        source: trim/output_readgroup
      - id: run_uuid
        source: run_uuid
      - id: thread_count
        source: thread_count
    out:
      - id: sqlite
      - id: tar

  - id: tar_concat_fastq_metrics
    run: subworkflows/tools/tar_concat.cwl
    in:
      - id: archives
        source: fastq_metrics/tar
      - id: tar_out
        valueFrom: fastqc.tar
    out:
      - id: output

  - id: merge_sqlite_fastq_metrics
    run: subworkflows/tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: fastq_metrics/sqlite
      - id: job_uuid
        source: run_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: align
    run: subworkflows/align.cwl
    scatter: fastq_readgroup
    in:
      - id: fastq_readgroup
        source: trim/output_readgroup
      - id: fasta
        source: fasta
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
      - id: run_uuid
        source: run_uuid
      - id: star_alignIntronMax
        source: star_alignIntronMax
      - id: star_alignIntronMin
        source: star_alignIntronMin
      - id: star_alignMatesGapMax
        source: star_alignMatesGapMax
      - id: star_alignSJDBoverhangMin
        source: star_alignSJDBoverhangMin
      - id: star_alignSJoverhangMin
        source: star_alignSJoverhangMin
      - id: star_limitBAMsortRAM
        source: star_limitBAMsortRAM
      - id: star_outBAMsortingBinsN
        source: star_outBAMsortingBinsN
      - id: star_outFilterMatchNmin
        source: star_outFilterMatchNmin
      - id: star_outFilterMatchNminOverLread
        source: star_outFilterMatchNminOverLread
      - id: star_outFilterMismatchNmax
        source: star_outFilterMismatchNmax
      - id: star_outFilterMismatchNoverLmax
        source: star_outFilterMismatchNoverLmax
      - id: star_outFilterMismatchNoverReadLmax
        source: star_outFilterMismatchNoverReadLmax
      - id: star_outFilterMultimapNmax
        source: star_outFilterMultimapNmax
      - id: thread_count
        source: thread_count
      - id: umi_enabled
        source: umi_enabled
      - id: umi-separator
        source: umi-separator
    out:
      - id: out_bam
      - id: tar

  # - id: merge_sqlite_star_align
  #   run: subworkflows/tools/merge_sqlite.cwl
  #   in:
  #     - id: source_sqlite
  #       source: align/sqlite
  #     - id: job_uuid
  #       source: run_uuid
  #   out:
  #     - id: destination_sqlite
  #     - id: log

  - id: tar_concat_star_align
    run: subworkflows/tools/tar_concat.cwl
    in:
      - id: archives
        source: align/tar
      - id: tar_out
        valueFrom: staralign.tar
    out:
      - id: output

  - id: picard_mergesamfiles
    run: subworkflows/tools/picard_mergesamfiles.cwl
    in:
      - id: input
        source: align/out_bam
      - id: output
        source: fastq_readgroup_list
        valueFrom: $(self[0].readgroup_meta["SM"]).Aligned.sortedByCoord.out.bam
    out:
      - id: merged_output

  - id: expression_any_se
    run: subworkflows/tools/expression_any_se.cwl
    in:
      - id: fastq_readgroups
        source: fastq_readgroup_list
    out:
      - id: output

  - id: conditional_dedup
    run: subworkflows/umi_dedup.cwl
    in:
      - id: any_se_readgroups
        source: expression_any_se/output
      - id: aligned_bam
        source: picard_mergesamfiles/merged_output
      - id: umi_enabled
        source: umi_enabled
      - id: umi-separator
        source: umi-separator
    out:
      - id: dedup_bam
      - id: tar
    when: $(inputs.umi_enabled)

  - id: decider_conditional_dedup
    run: subworkflows/tools/decider_conditional_file.cwl
    in:
      - id: required_file
        source: picard_mergesamfiles/merged_output
      - id: conditional_file
        source: conditional_dedup/dedup_bam
    out:
      - id: output

  - id: decider_conditional_umi_dedup_tar
    run: subworkflows/tools/decider_conditional_file.cwl
    in:
      - id: required_file
        source: create_empty_tar/output
      - id: conditional_file
        source: conditional_dedup/tar
    out:
      - id: output

  - id: conditional_markduplicates
    run: subworkflows/conditional_markduplicates.cwl
    in:
      - id: bam
        source: decider_conditional_dedup/output
      - id: run_uuid
        source: run_uuid
      - id: run_markduplicates
        source: run_markduplicates
    out:
      - id: output
      - id: sqlite
      - id: tar
    when: $(inputs.run_markduplicates)

  - id: create_empty_sqlite
    run: subworkflows/tools/touch.cwl
    in:
      - id: input
        valueFrom: "empty.sqlite"
    out:
      - id: output

  - id: create_empty_tar
    run: subworkflows/tools/touch.cwl
    in:
      - id: input
        valueFrom: "empty.tar"
    out:
      - id: output

  - id: decider_conditional_bam
    run: subworkflows/tools/decider_conditional_bams.cwl
    in:
      - id: required_bam
        source: decider_conditional_dedup/output
      - id: required_sqlite
        source: create_empty_sqlite/output
      - id: required_tar
        source: create_empty_tar/output
      - id: conditional_bam
        source: conditional_markduplicates/output
      - id: conditional_sqlite
        source: conditional_markduplicates/sqlite
      - id: conditional_tar
        source: conditional_markduplicates/tar
    out:
      - id: bam
      - id: sqlite
      - id: tar

  - id: bam_metrics
    run: subworkflows/bam_metrics.cwl
    in:
      - id: any_se_readgroup
        source: expression_any_se/output
      - id: bam
        source: decider_conditional_bam/bam
      - id: fasta
        source: fasta
      - id: featurecounts_allowmultioverlap
        source: featurecounts_allowmultioverlap
      - id: featurecounts_byreadgroup
        source: featurecounts_byreadgroup
      - id: featurecounts_countreadpairs
        source: featurecounts_countreadpairs
      - id: featurecounts_checkfraglength
        source: featurecounts_checkfraglength
      - id: featurecounts_countmultimappingreads
        source: featurecounts_countmultimappingreads
      - id: featurecounts_fraction
        source: featurecounts_fraction
      - id: featurecounts_fracoverlap
        source: featurecounts_fracoverlap
      - id: featurecounts_fracoverlapfeature
        source: featurecounts_fracoverlapfeature
      - id: featurecounts_ignoredup
        source: featurecounts_ignoredup
      - id: featurecounts_islongread
        source: featurecounts_islongread
      - id: featurecounts_junccounts
        source: featurecounts_junccounts
      - id: featurecounts_largestoverlap
        source: featurecounts_largestoverlap
      - id: featurecounts_minfraglength
        source: featurecounts_minfraglength
      - id: featurecounts_maxfraglength
        source: featurecounts_maxfraglength
      - id: featurecounts_maxmop
        source: featurecounts_maxmop
      - id: featurecounts_minmqs
        source: featurecounts_minmqs
      - id: featurecounts_minoverlap
        source: featurecounts_minoverlap
      - id: featurecounts_nonoverlap
        source: featurecounts_nonoverlap
      - id: featurecounts_nonoverlapfeature
        source: featurecounts_nonoverlapfeature
      - id: featurecounts_nonsplitonly
        source: featurecounts_nonsplitonly
      - id: featurecounts_notcountchimericfragments
        source: featurecounts_notcountchimericfragments
      - id: featurecounts_primary
        source: featurecounts_primary
      - id: featurecounts_read2pos
        source: featurecounts_read2pos
      - id: featurecounts_readextension3
        source: featurecounts_readextension3
      - id: featurecounts_readextension5
        source: featurecounts_readextension5
      - id: featurecounts_readshiftsize
        source: featurecounts_readshiftsize
      - id: featurecounts_readshifttype
        source: featurecounts_readshifttype
      - id: featurecounts_reportreads
        source: featurecounts_reportreads
      - id: featurecounts_requirebothendsmapped
        source: featurecounts_requirebothendsmapped
      - id: featurecounts_splitonly
        source: featurecounts_splitonly
      - id: featurecounts_usemetafeatures
        source: featurecounts_usemetafeatures
      - id: featurecounts_GTF_attrType
        source: featurecounts_GTF_attrType
      - id: featurecounts_GTF_featureType
        source: featurecounts_GTF_featureType
      - id: gtf
        source: gtf
      - id: collapsed_bed
        source: collapsed_bed
      - id: collapsed_gtf
        source: collapsed_gtf
      - id: ref_flat
        source: ref_flat
      - id: ribosomal_intervals
        source: rrna_intervallist
      - id: input_state
        valueFrom: "align"
      - id: run_tpmcalculator
        source: run_tpmcalculator
      - id: run_uuid
        source: run_uuid
      - id: stranded
        source: what_strand/strand
      - id: thread_count
        source: thread_count
    out:
      - id: sqlite
      - id: tar

  - id: germline_variants
    run: subworkflows/germline_variants.cwl
    in:
      - id: bam
        source: decider_conditional_bam/bam
      - id: dbsnp
        source: dbsnp
      - id: fasta
        source: fasta
      - id: thread_count
        source: thread_count
      - id: run_uuid
        source: run_uuid
      - id: variantcall_contigs
        source: variantcall_contigs
      - id: run_variantcall_joint
        source: run_variantcall_joint
      - id: run_variantcall_single
        source: run_variantcall_single
    out:
      - id: variants
      - id: bqsrbam
    when: $(inputs.run_variantcall_joint || inputs.run_variantcall_single )

  - id: decider_bqsr_bam
    run: subworkflows/tools/decider_bqsr_bam.cwl
    in:
      - id: required_bam
        source: decider_conditional_bam/bam
      - id: conditional_bam
        source: germline_variants/bqsrbam
    out:
      - id: bam

  - id: integrity
    run: subworkflows/integrity.cwl
    in:
      - id: bai
        source: decider_bqsr_bam/bam
        valueFrom: $(self.secondaryFiles[0])
      - id: bam
        source: decider_bqsr_bam/bam
      - id: input_state
        valueFrom: "star_aligned"
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: merge_all_sqlite
    run: subworkflows/tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
          merge_sqlite_fastq_metrics/destination_sqlite,
          bam_metrics/sqlite,
          decider_conditional_bam/sqlite,
          integrity/sqlite
        ]
      - id: job_uuid
        source: fastq_readgroup_list
        valueFrom: $(self[0].readgroup_meta["SM"])
    out:
      - id: destination_sqlite
      - id: log

  - id: tar_all_concat
    run: subworkflows/tools/tar_concat.cwl
    in:
      - id: archives
        source: [
        tar_concat_fastq_metrics/output,
        tar_concat_trim/output,
        tar_concat_star_align/output,
        bam_metrics/tar,
        decider_conditional_bam/tar,
        decider_conditional_umi_dedup_tar/output,
        kallisto/tar
        ]
        pickValue: all_non_null
      - id: add_dir
        source: fastq_readgroup_list
        valueFrom: $(self[0].readgroup_meta["SM"])
      - id: tar_out
        source: fastq_readgroup_list
        valueFrom: $(self[0].readgroup_meta["SM"])_align.tar
    out:
      - id: output
