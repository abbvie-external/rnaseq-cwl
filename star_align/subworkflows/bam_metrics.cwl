#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/gtf_type.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: any_se_readgroup
    type: boolean
  - id: bam
    type: File
    secondaryFiles:
      - ^.bai
  - id: fasta
    type: File
  - id: gtf
    type: File
  - id: collapsed_gtf
    type: File
  - id: collapsed_bed
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
      items: tools/gtf_type.cwl#GTF_attrType
  - id: featurecounts_GTF_featureType
    type:
      type: array
      items: tools/gtf_type.cwl#GTF_featureType
  - id: ref_flat
    type: File
  - id: ribosomal_intervals
    type: File
  - id: input_state
    type: string
  - id: run_tpmcalculator
    type: boolean
  - id: run_uuid
    type: string
  - id: stranded
    type:
      - "null"
      - type: enum
        symbols:
          - forward
          - reverse
          - unstranded
  - id: thread_count
    type: long

outputs:
  - id: sqlite
    type: File
    outputSource: merge_fastq_metrics/destination_sqlite
  - id: tar
    type: File
    outputSource: tar_concat/output

steps:
  - id: picard_collectrnaseqmetrics
    run: tools/picard_collectrnaseqmetrics.cwl
    in:
      - id: input
        source: bam
      - id: ref_flat
        source: ref_flat
      - id: ribosomal_intervals
        source: ribosomal_intervals
      - id: strand_specificity
        source: stranded
        valueFrom: |
          ${
           if (self == null) {
             return "NONE";
           }
           else if (self == "forward") {
             return "FIRST_READ_TRANSCRIPTION_STRAND";
           }
           else if (self == "reverse") {
             return "SECOND_READ_TRANSCRIPTION_STRAND";
           }
           else if (self == "unstranded") {
             return "NONE";
           }
          }

    out:
      - id: metrics
      - id: pdf

  - id: tar_picard
    run: tools/tar_files.cwl
    in:
      - id: input
        source:
          - picard_collectrnaseqmetrics/metrics
          - picard_collectrnaseqmetrics/pdf
      - id: dirname
        valueFrom: picard
    out:
      - id: output

  - id: picard_collectrnaseqmetrics_to_sqlite
    run: tools/picard_collectrnaseqmetrics_to_sqlite.cwl
    in:
      - id: bam
        source: bam
        valueFrom: $(self.basename)
      - id: metric_path
        source: picard_collectrnaseqmetrics/metrics
      - id: input_state
        valueFrom: "star_align"
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: samtools_flagstat
    run: tools/samtools_flagstat.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: samtools_flagstat_to_sqlite
    run: tools/samtools_flagstat_to_sqlite.cwl
    in:
      - id: bam
        source: bam
        valueFrom: $(self.basename)
      - id: input_state
        source: input_state
      - id: metric_path
        source: samtools_flagstat/output
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: samtools_idxstats
    run: tools/samtools_idxstats.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: samtools_idxstats_to_sqlite
    run: tools/samtools_idxstats_to_sqlite.cwl
    in:
      - id: bam
        source: bam
        valueFrom: $(self.basename)
      - id: input_state
        source: input_state
      - id: metric_path
        source: samtools_idxstats/output
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: samtools_stats
    run: tools/samtools_stats.cwl
    in:
      - id: input
        source: bam
    out:
      - id: output

  - id: samtools_stats_to_sqlite
    run: tools/samtools_stats_to_sqlite.cwl
    in:
      - id: bam
        source: bam
        valueFrom: $(self.basename)
      - id: input_state
        source: input_state
      - id: metric_path
        source: samtools_stats/output
      - id: run_uuid
        source: run_uuid
    out:
      - id: sqlite

  - id: tar_samtools
    run: tools/tar_files.cwl
    in:
      - id: input
        source:
          - samtools_flagstat/output
          - samtools_idxstats/output
          - samtools_stats/output
      - id: dirname
        valueFrom: samtools
    out:
      - id: output

  - id: qualimap_rnaseq
    run: tools/qualimap_rnaseq.cwl
    in:
      - id: bam
        source: bam
      - id: gtf
        source: gtf
      - id: paired
        source: any_se_readgroup
        valueFrom: $(!self)
      - id: sequencing_protocol
        source: stranded
        valueFrom: |
          ${
           if (self == null) {
             return null;
           }
           else if (self == "forward") {
             return "strand-specific-forward";
           }
           else if (self == "reverse") {
             return "strand-specific-reverse";
           }
           else if (self == "unstranded") {
             return "non-strand-specific";
           }
          }
    out:
      - id: output

  # - id: qualimap_to_sqlite
  #   run: tools/qualimap_to_sqlite.cwl
  #   in:
  #     - id: metrics_path
  #       source: qualimap_rnaseq/output
  #     - id: run_uuid
  #       source: run_uuid
  #   out:
  #     - id: sqlite

  - id: tar_qualimap
    run: tools/tar_files.cwl
    in:
      - id: input
        source:
          - qualimap_rnaseq/output
        valueFrom: $([self])
      - id: dirname
        valueFrom: qualimap
    out:
      - id: output

  - id: featurecounts
    run: featurecounts.cwl
    scatter: [GTF_attrType, GTF_featureType]
    scatterMethod: "flat_crossproduct"
    in:
      - id: any_se_readgroup
        source: any_se_readgroup
      - id: bam
        source: bam
      - id: gtf
        source: gtf
      - id: GTF_attrType
        source: featurecounts_GTF_attrType
      - id: GTF_featureType
        source: featurecounts_GTF_featureType
      - id: fasta
        source: fasta
      - id: allowmultioverlap
        source: featurecounts_allowmultioverlap
      - id: byreadgroup
        source: featurecounts_byreadgroup
      - id: countreadpairs
        source: featurecounts_countreadpairs
      - id: checkfraglength
        source: featurecounts_checkfraglength
      - id: countmultimappingreads
        source: featurecounts_countmultimappingreads
      - id: fraction
        source: featurecounts_fraction
      - id: fracoverlap
        source: featurecounts_fracoverlap
      - id: fracoverlapfeature
        source: featurecounts_fracoverlapfeature
      - id: ignoredup
        source: featurecounts_ignoredup
      - id: islongread
        source: featurecounts_islongread
      - id: junccounts
        source: featurecounts_junccounts
      - id: largestoverlap
        source: featurecounts_largestoverlap
      - id: minfraglength
        source: featurecounts_minfraglength
      - id: maxfraglength
        source: featurecounts_maxfraglength
      - id: maxmop
        source: featurecounts_maxmop
      - id: minmqs
        source: featurecounts_minmqs
      - id: minoverlap
        source: featurecounts_minoverlap
      - id: nonoverlap
        source:: featurecounts_nonoverlap
      - id: nonoverlapfeature
        source: featurecounts_nonoverlapfeature
      - id: nonsplitonly
        source: featurecounts_nonsplitonly
      - id: notcountchimericfragments
        source: featurecounts_notcountchimericfragments
      - id: primary
        source: featurecounts_primary
      - id: read2pos
        source: featurecounts_read2pos
      - id: readextension3
        source: featurecounts_readextension3
      - id: readextension5
        source: featurecounts_readextension5
      - id: readshiftsize
        source: featurecounts_readshiftsize
      - id: readshifttype
        source: featurecounts_readshifttype
      - id: reportreads
        source: featurecounts_reportreads
      - id: requirebothendsmapped
        source: featurecounts_requirebothendsmapped
      - id: splitonly
        source: featurecounts_splitonly
      - id: stranded
        source: stranded
      - id: thread_count
        source: thread_count
      - id: usemetafeatures
        source: featurecounts_usemetafeatures
    out:
      - id: tar

  - id: tar_concat_featurecounts
    run: tools/tar_concat.cwl
    in:
      - id: archives
        source: featurecounts/tar
      - id: tar_out
        valueFrom: featurecounts.tar
      - id: featurecounts_GTF_attrType
        source: featurecounts_GTF_attrType
    out:
      - id: output
    when: $(inputs.featurecounts_GTF_attrType.length > 0)

  - id: decider_featurecounts_tar
    run: tools/decider_conditional_tar.cwl
    in:
      - id: required_tar
        source: create_empty_tar/output
      - id: conditional_tar
        source: tar_concat_featurecounts/output
    out:
      - id: tar

  - id: rnaseqc
    run: tools/rnaseqc.cwl
    in:
      - id: bam
        source: bam
      - id: gtf
        source: collapsed_gtf
      - id: bed
        source: collapsed_bed
      - id: coverage
        valueFrom: $(true)
      - id: unpaired
        source: any_se_readgroup
      - id: stranded
        source: stranded
        valueFrom: |
          ${
           if (self == null) {
             return null;
           }
           else if (self == "forward") {
             return "FR";
           }
           else if (self == "reverse") {
             return "RF";
           }
           else if (self == "unstranded") {
             return null;
           }
          }
    out:
      - id: coverage_tsv
      - id: gene_reads_gct
      - id: gene_tpm_gct
      - id: gene_fragments_gct
      - id: exon_reads_gct
      - id: metrics_tsv

  - id: tar_rnaseqc
    run: tools/tar_files.cwl
    in:
      - id: input
        source: [
        rnaseqc/coverage_tsv,
        rnaseqc/gene_reads_gct,
        rnaseqc/gene_tpm_gct,
        rnaseqc/gene_fragments_gct,
        rnaseqc/exon_reads_gct,
        rnaseqc/metrics_tsv
        ]
      - id: dirname
        valueFrom: rnaseqc
    out:
      - id: output

  - id: create_empty_tar
    run: tools/touch.cwl
    in:
      - id: input
        valueFrom: "empty.tar"
    out:
      - id: output

  - id: conditional_tpmcalculator
    run: conditional_tpmcalculator.cwl
    in:
      - id: bam
        source: bam
      - id: gtf
        source: gtf
      - id: any_se_readgroup
        source: any_se_readgroup
      - id: run_tpmcalculator
        source: run_tpmcalculator
    out:
      - id: tar
    when: $(inputs.run_tpmcalculator)

  - id: decider_tpmcalculator_tar
    run: tools/decider_conditional_tar.cwl
    in:
      - id: required_tar
        source: create_empty_tar/output
      - id: conditional_tar
        source: conditional_tpmcalculator/tar
    out:
      - id: tar

  - id: merge_fastq_metrics
    run: tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
          picard_collectrnaseqmetrics_to_sqlite/sqlite,
          samtools_flagstat_to_sqlite/sqlite,
          samtools_idxstats_to_sqlite/sqlite,
          samtools_stats_to_sqlite/sqlite
        ]
      - id: job_uuid
        source: run_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: tar_concat
    run: tools/tar_concat.cwl
    in:
      - id: archives
        source: [
        tar_picard/output,
        tar_qualimap/output,
        tar_rnaseqc/output,
        tar_samtools/output,
        decider_featurecounts_tar/tar,
        decider_tpmcalculator_tar/tar
        ]
      - id: add_dir
        valueFrom: "bam_metrics"
      - id: tar_out
        valueFrom: "bam_metrics.tar"
    out:
      - id: output
