#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/gtf_type.cwl
  - class: StepInputExpressionRequirement

inputs:
  - id: any_se_readgroup
    type: boolean
  - id: bam
    type: File
  - id: gtf
    type: File
  - id: allowmultioverlap
    type: ["null", boolean]
  - id: byreadgroup
    type: ["null", boolean]
  - id: countreadpairs
    type: ["null", boolean]
  - id: checkfraglength
    type: ["null", boolean]
  - id: countmultimappingreads
    type: ["null", boolean]
  - id: fraction
    type: ["null", float]
  - id: fracoverlap
    type: ["null", float]
  - id: fracoverlapfeature
    type: ["null", float]
  - id: ignoredup
    type: ["null", boolean]
  - id: islongread
    type: ["null", boolean]
  - id: junccounts
    type: boolean
  - id: largestoverlap
    type: ["null", long]
  - id: minfraglength
    type: ["null", long]
  - id: maxfraglength
    type: ["null", long]
  - id: maxmop
    type: ["null", long]
  - id: minmqs
    type: ["null", long]
  - id: minoverlap
    type: ["null", long]
  - id: nonoverlap
    type: ["null", long]
  - id: nonoverlapfeature
    type: ["null", long]
  - id: nonsplitonly
    type: ["null", boolean]
  - id: notcountchimericfragments
    type: ["null", boolean]
  - id: primary
    type: ["null", boolean]
  - id: read2pos
    type: ["null", long]
  - id: readextension3
    type: ["null", long]
  - id: readextension5
    type: ["null", long]
  - id: readshiftsize
    type: ["null", long]
  - id: readshifttype
    type:
      - "null"
      - type: enum
        symbols:
          - downstream
          - left
          - right
          - upstream
  - id: reportreads
    type:
      - "null"
      - type: enum
        symbols:
          - BAM
          - CORE
          - SAM
  - id: requirebothendsmapped
    type: ["null", boolean]
  - id: splitonly
    type: ["null", boolean]
  - id: usemetafeatures
    type: ["null", boolean]
  - id: GTF_attrType
    type: tools/gtf_type.cwl#GTF_attrType
  - id: GTF_featureType
    type: tools/gtf_type.cwl#GTF_featureType
  - id: fasta
    type: File
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
  - id: tar
    type: File
    outputSource: tar_counts/output

steps:
  - id: subread_featurecounts
    run: tools/subread_featurecounts.cwl
    in:
      - id: annotation
        source: gtf
      - id: input
        source: bam
      - id: genome
        source: fasta
      - id: nthreads
        source: thread_count
      - id: GTF_featureType
        source: GTF_featureType # exon, gene
      - id: GTF_attrType
        source: GTF_attrType #exon_id, gene_id, transcript_id
      - id: isPairedEnd
        source: any_se_readgroup
        valueFrom: $(!self)
      - id: countReadPairs
        source: any_se_readgroup
        valueFrom: $(!self)
      - id: isGTFAnnotationFile
        valueFrom: GTF
      - id: allowMultiOverlap
        source: allowmultioverlap
      - id: byReadGroup
        source: byreadgroup
      - id: countReadPairs
        source: countreadpairs
      - id: checkFragLength
        source: checkfraglength
      - id: countMultiMappingReads
        source: countmultimappingreads
      - id: fraction
        source: fraction
      - id: fracOverlap
        source: fracoverlap
      - id: fracOverlapFeature
        source: fracoverlapfeature
      - id: ignoreDup
        source: ignoredup
      - id: isLongRead
        source: islongread
      - id: juncCounts
        source: junccounts
      - id: largestOverlap
        source: largestoverlap
      - id: minFragLength
        source: minfraglength
      - id: maxFragLength
        source: maxfraglength
      - id: maxMOp
        source: maxmop
      - id: minMQS
        source: minmqs
      - id: minOverlap
        source: minoverlap
      - id: nonOverlap
        source: nonoverlap
      - id: nonOverlapFeature
        source: nonoverlapfeature
      - id: nonSplitOnly
        source: nonsplitonly
      - id: NOTcountChimericFragments
        source: notcountchimericfragments
      - id: primary
        source: primary
      - id: read2pos
        source: read2pos
      - id: readExtension3
        source: readextension3
      - id: readExtension5
        source: readextension5
      - id: readShiftSize
        source: readshiftsize
      - id: readShiftType
        source: readshifttype
      - id: reportReads
        source: reportreads
      - id: requireBothEndsMapped
        source: requirebothendsmapped
      - id: splitOnly
        source: splitonly
      - id: useMetaFeatures
        source: usemetafeatures
      - id: isStrandSpecific
        source: stranded
        valueFrom: |
          ${
           if (self == null) {
             return null;
           }
           else if (self == "forward") {
             return "1";
           }
           else if (self == "reverse") {
             return "2";
           }
           else if (self == "unstranded") {
             return "0";
           }
          }
    out:
      - id: counts
      - id: summary
      - id: junccounts

  - id: output_files
    run: tools/decider_optional_files.cwl
    in:
      - id: optional_files
        source:
          - subread_featurecounts/counts
          - subread_featurecounts/junccounts
          - subread_featurecounts/summary
    out:
      - id: out_files

  - id: tar_counts
    run: tools/tar_files.cwl
    in:
      - id: input
        source: output_files/out_files
      - id: dirname
        valueFrom: featurecounts
    out:
      - id: output
