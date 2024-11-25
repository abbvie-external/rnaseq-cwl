#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/star:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.genome_chrLength_txt.basename)
        entry: $(inputs.genome_chrLength_txt)
      - entryname: $(inputs.genome_chrName_txt.basename)
        entry: $(inputs.genome_chrName_txt)
      - entryname: $(inputs.genome_chrNameLength_txt.basename)
        entry: $(inputs.genome_chrNameLength_txt)
      - entryname: $(inputs.genome_chrStart_txt.basename)
        entry: $(inputs.genome_chrStart_txt)
      - entryname: $(inputs.genome_exonGeTrInfo_tab.basename)
        entry: $(inputs.genome_exonGeTrInfo_tab)
      - entryname: $(inputs.genome_Genome.basename)
        entry: $(inputs.genome_Genome)
      - entryname: $(inputs.genome_genomeParameters_txt.basename)
        entry: $(inputs.genome_genomeParameters_txt)
      - entryname: $(inputs.genome_SA.basename)
        entry: $(inputs.genome_SA)
      - entryname: $(inputs.genome_SAindex.basename)
        entry: $(inputs.genome_SAindex)
      - entryname: $(inputs.genome_sjdbInfo_txt.basename)
        entry: $(inputs.genome_sjdbInfo_txt)
      - entryname: $(inputs.genome_sjdbList_fromGTF_out_tab.basename)
        entry: $(inputs.genome_sjdbList_fromGTF_out_tab)
      - entryname: $(inputs.genome_sjdbList_out_tab.basename)
        entry: $(inputs.genome_sjdbList_out_tab)
  - class: ResourceRequirement
    coresMin: 8
    coresMax: 8
    ramMin: 100000
    ramMax: 100000
    tmpdirMin: $(Math.ceil ((2 * inputs.fastq_readgroup.forward_fastq.size + inputs.genome_Genome.size + inputs.genome_SA.size + inputs.genome_SAindex.size) / 1048576))
    tmpdirMax: $(Math.ceil ((2 * inputs.fastq_readgroup.forward_fastq.size + inputs.genome_Genome.size + inputs.genome_SA.size + inputs.genome_SAindex.size) / 1048576))
    outdirMin: $(Math.ceil ((2 * inputs.fastq_readgroup.forward_fastq.size + inputs.genome_Genome.size + inputs.genome_SA.size + inputs.genome_SAindex.size) / 1048576))
    outdirMax: $(Math.ceil ((2 * inputs.fastq_readgroup.forward_fastq.size + inputs.genome_Genome.size + inputs.genome_SA.size + inputs.genome_SAindex.size) / 1048576))
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  - id: fastq_readgroup
    type: readgroup.cwl#readgroup_fastq_file

  # - id: alignEndsProtrude
  #   type:
  #     - long
  #     - type: enum
  #       symbols:
  #         - ConcordantPair
  #         - DiscordantPair
  #   inputBinding:
  #     prefix: --alignEndsProtrude

  - id: alignEndsType
    type:
      - "null"
      - type: enum
        symbols:
          - Local
          - EndToEnd
          - Extend5pOfRead1
          - Extend5pOfReads12
    inputBinding:
      prefix: --alignEndsType

  - id: alignInsertionFlush
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - Right
    inputBinding:
      prefix: --alignInsertionFlush

  - id: alignIntronMax
    type: [long, "null"]
    inputBinding:
      prefix: --alignIntronMax

  - id: alignIntronMin
    type: [long, "null"]
    inputBinding:
      prefix: --alignIntronMin

  - id: alignMatesGapMax
    type: [long, "null"]
    inputBinding:
      prefix: --alignMatesGapMax

  - id: alignSJoverhangMin
    type: [long, "null"]
    inputBinding:
      prefix: --alignSJoverhangMin

  - id: alignSJDBoverhangMin
    type: [long, "null"]
    inputBinding:
      prefix: --alignSJDBoverhangMin

  - id: alignSJstitchMismatchNmax
    type: [long, "null"]
    inputBinding:
      prefix: --alignSJstitchMismatchNmax

  - id: alignSoftClipAtReferenceEnds
    type:
      - "null"
      - type: enum
        symbols:
          - Yes
          - No
    inputBinding:
      prefix: --alignSoftClipAtReferenceEnds

  - id: alignSplicedMateMapLmin
    type: [long, "null"]
    inputBinding:
      prefix: --alignSplicedMateMapLmin

  - id: alignSplicedMateMapLminOverLmate
    type: [float, "null"]
    inputBinding:
      prefix: --alignSplicedMateMapLminOverLmate

  - id: alignTranscriptsPerReadNmax
    type: [long, "null"]
    inputBinding:
      prefix: --alignTranscriptsPerReadNmax

  - id: alignTranscriptsPerWindowNmax
    type: [long, "null"]
    inputBinding:
      prefix: --alignTranscriptsPerWindowNmax

  - id: alignWindowsPerReadNmax
    type: [long, "null"]
    inputBinding:
      prefix: --alignWindowsPerReadNmax

  - id: chimFilter
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - banGenomicN
    inputBinding:
      prefix: --chimFilter

  - id: chimJunctionOverhangMin
    type: [long, "null"]
    inputBinding:
      prefix: --chimJunctionOverhangMin

  - id: chimMainSegmentMultNmax
    type: [long, "null"]
    inputBinding:
      prefix: --chimMainSegmentMultNmax

  - id: chimMultimapNmax
    type: [long, "null"]
    inputBinding:
      prefix: --chimMultimapNmax

  - id: chimMultimapScoreRange
    type: [long, "null"]
    inputBinding:
      prefix: --chimMultimapScoreRange

  - id: chimNonchimScoreDropMin
    type: [long, "null"]
    inputBinding:
      prefix: --chimNonchimScoreDropMin

  - id: chimOutJunctionFormat
    type:
      - "null"
      - type: enum
        symbols:
          - "0"
          - "1"
    inputBinding:
      prefix: --chimOutJunctionFormat

  - id: chimOutType
    type:
      - "null"
      - type: enum
        symbols:
          - Junctions
          - SeparateSAMold
          - WithinBAM
          - WithinBAM HardClip
          - WithinBAM SoftClip
    inputBinding:
      prefix: chimOutType

  - id: chimScoreDropMax
    type: [long, "null"]
    inputBinding:
      prefix: --chimScoreDropMax

  - id: chimScoreJunctionNonGTAG
    type: [long, "null"]
    inputBinding:
      prefix: --chimScoreJunctionNonGTAG

  - id: chimScoreMin
    type: [long, "null"]
    inputBinding:
      prefix: --chimScoreMin

  - id: chimScoreSeparation
    type: [long, "null"]
    inputBinding:
      prefix: --chimScoreSeparation

  - id: chimSegmentMin
    type: [long, "null"]
    inputBinding:
      prefix: --chimSegmentMin

  - id: chimSegmentReadGapMax
    type: [long, "null"]
    inputBinding:
      prefix: --chimSegmentReadGapMax

  - id: genome_chrLength_txt
    type: File

  - id: genome_chrName_txt
    type: File

  - id: genome_chrNameLength_txt
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

  - id: genomeDir
    type: string
    default: "."
    inputBinding:
      prefix: --genomeDir

  - id: genomeLoad
    type:
      - "null"
      - type: enum
        symbols:
          - LoadAndKeep
          - LoadAndRemove
          - LoadAndExit
          - Remove
          - NoSharedMemory
    inputBinding:
      prefix: --genomeLoad

  - id: limitBAMsortRAM
    type: [long, "null"]
    inputBinding:
      prefix: --limitBAMsortRAM

  - id: outBAMsortingBinsN
    type: [long, "null"]
    inputBinding:
      prefix: --outBAMsortingBinsN

  - id: outFilterMatchNmin
    type: [float, "null"]
    inputBinding:
      prefix: --outFilterMatchNmin

  - id: outFilterMatchNminOverLread
    type: [float, "null"]
    inputBinding:
      prefix: --outFilterMatchNminOverLread

  - id: outFilterMismatchNmax
    type: [long, "null"]
    inputBinding:
      prefix: --outFilterMismatchNmax

  - id: outFilterMultimapNmax
    type: [long, "null"]
    inputBinding:
      prefix: --outFilterMultimapNmax

  - id: outFilterMismatchNoverLmax
    type: [float, "null"]
    inputBinding:
      prefix: --outFilterMismatchNoverLmax    

  - id: outFilterMismatchNoverReadLmax
    type: [float, "null"]
    inputBinding:
      prefix: --outFilterMismatchNoverReadLmax
      
  - id: outFilterMultimapScoreRange
    type: [long, "null"]
    inputBinding:
      prefix: --outFilterMultimapScoreRange

  - id: outFilterScoreMinOverLread
    type: [float, "null"]
    inputBinding:
      prefix: --outFilterScoreMinOverLread

  - id: outReadsUnmapped
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - Fastx
    inputBinding:
      prefix: --outReadsUnmapped

  - id: outSAMstrandField
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - intronMotif
    inputBinding:
      prefix: --outSAMstrandField

  - id: outSAMmode
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - Full
          - NoQS
    inputBinding:
      prefix: --outSAMmode

  - id: outSAMtype
    type:
      - "null"
      - type: enum
        symbols:
          - SAM Unsorted
          - SAM SortedByCoordinate
          - BAM Unsorted
          - BAM SortedByCoordinate
    default: BAM SortedByCoordinate
    inputBinding:
      prefix: --outSAMtype
      shellQuote: false

  - id: outSAMunmapped
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - None KeepPairs
          - Within
          - Within KeepPairs
    inputBinding:
      prefix: --outSAMunmapped
      shellQuote: false

  - id: --outSAMorder
    type:
      - "null"
      - type: enum
        symbols:
          - Paired
          - PairedKeepInputOrder
    inputBinding:
      prefix: --outSAMorder
      shellQuote: false

  - id: outStd
    type:
      - "null"
      - type: enum
        symbols:
          - Log
          - SAM
          - BAM_Unsorted
          - BAM_SortedByCoordinate
          - BAM_Quant
    default: Log
    inputBinding:
      prefix: --outStd

  - id: peOverlapMMp
    type: [float, "null"]
    inputBinding:
      prefix: --peOverlapMMp

  - id: peOverlapNbasesMin
    type: [long, "null"]
    inputBinding:
      prefix: --peOverlapNbasesMin

  - id: quantMode
    type:
      - "null"
      - type: enum
        symbols:
          - "-"
          - TranscriptomeSAM
          - GeneCounts

  - id: quantTranscriptomeBAMcompression
    type:
      - "null"
      - type: enum
        symbols:
          - "-2"
          - "-1"
          - "0"
          - "10"

  - id: quantTranscriptomeBan
    type:
      - "null"
      - type: enum
        symbols:
          - IndelSoftclipSingleend
          - Singleend

  - id: readFilesCommand
    type: string
    default: "zcat"
    inputBinding:
      prefix: --readFilesCommand

  - id: runDirPerm
    type:
      - "null"
      - type: enum
        symbols:
          - User_RWX
          - All_RWX
    default: User_RWX
    inputBinding:
      prefix: --runDirPerm

  - id: runRNGseed
    type: long
    default: 777
    inputBinding:
      prefix: --runRNGseed

  - id: runThreadN
    type: [long, "null"]
    inputBinding:
      prefix: --runThreadN

  - id: sjdbOverhang
    type: [long, "null"]
    inputBinding:
      prefix: --sjdbOverhang

  - id: sjdbScore
    type: [long, "null"]
    inputBinding:
      prefix: --sjdbScore

  - id: soloAdapterMismatchesNmax
    type: [long, "null"]
    inputBinding:
      prefix: --soloAdapterMismatchesNmax

  - id: soloAdapterSequence
    type: [string, "null"]
    inputBinding:
      prefix: --soloAdapterSequence

  - id: soloBarcodeReadLength
    type:
      - "null"
      - type: enum
        symbols:
          - "0"
          - "1"
    inputBinding:
      prefix: --soloBarcodeReadLength

  - id: soloCBlen
    type: [long, "null"]
    inputBinding:
      prefix: --soloCBlen

  - id: soloCBposition
    type: [string, "null"]
    inputBinding:
      prefix: --soloCBposition

  - id: soloCBmatchWLtype
    type:
      - "null"
      - type: enum
        symbols:
          - Exact
          - 1MM
          - 1MM_multi
    inputBinding:
      prefix: --soloCBmatchWLtype

  - id: soloCBstart
    type: [long, "null"]
    inputBinding:
      prefix: --soloCBstart

  - id: soloCBwhitelist
    type: [File, "null"]
    inputBinding:
      prefix: --soloCBwhitelist

  - id: soloCellFilter
    type:
      - "null"
      - type: enum
        symbols:
          - CellRanger2.2
          - None
          - TopCells
    inputBinding:
      prefix: --soloCellFilter

  - id: soloFeatures
    type:
      - "null"
      - type: enum
        symbols:
          - Gene
          - GeneFull
          - SJ
          - Transcript3p
    inputBinding:
      prefix: --soloFeatures

  - id: soloOutFileNames
    type: [string, "null"]
    inputBinding:
      prefix: --soloOutFileNames

  - id: soloStrand
    type:
      - "null"
      - type: enum
        symbols:
          - Unstranded
          - Forward
          - Reverse
    inputBinding:
      prefix: --soloStrand

  - id: soloType
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - CB_UMI_Simple
          - CB_UMI_Complex
    inputBinding:
      prefix: --soloType

  - id: soloUMIdedup
    type:
      - "null"
      - type: enum
        symbols:
          - 1MM_All
          - 1MM_Directional
          - Exact
    inputBinding:
      prefix: --soloUMIdedup

  - id: soloUMIfiltering
    type:
      - "null"
      - type: enum
        symbols:
          - "-"
          - MultiGeneUMI
    inputBinding:
      prefix: --soloUMIfiltering

  - id: soloUMIlen
    type: [long, "null"]
    inputBinding:
      prefix: --soloUMIlen

  - id: soloUMIposition
    type: [string, "null"]
    inputBinding:
      prefix: --soloUMIposition

  - id: soloUMIstart
    type: [long, "null"]
    inputBinding:
      prefix: --soloUMIstart

  - id: twopassMode
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - Basic
    inputBinding:
      prefix: --twopassMode

  - id: twopass1readsN
    type: [long, "null"]
    inputBinding:
      prefix: --twopass1readsN

  - id: waspOutputMode
    type:
      - "null"
      - type: enum
        symbols:
          - None
          - SAMtag
    inputBinding:
      prefix: --waspOutputMode

  - id: winAnchorDistNbins
    type: [long, "null"]
    inputBinding:
      prefix: --winAnchorDistNbins

  - id: winAnchorMultimapNmax
    type: [long, "null"]
    inputBinding:
      prefix: --winAnchorMultimapNmax

  - id: winBinNbits
    type: [long, "null"]
    inputBinding:
      prefix: --winBinNbits

  - id: winFlankNbins
    type: [long, "null"]
    inputBinding:
      prefix: --winFlankNbins

  - id: winReadCoverageBasesMin
    type: [long, "null"]
    inputBinding:
      prefix: --winReadCoverageBasesMin

  - id: winReadCoverageRelativeMin
    type: [float, "null"]
    inputBinding:
      prefix: --winReadCoverageRelativeMin

outputs:
  - id: out_bam
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).Aligned.sortedByCoord.out.bam

  - id: Log_final_out
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).Log.final.out

  - id: Log_out
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).Log.out

  - id: Log_progress_out
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).Log.progress.out

  - id: SJ_out_tab
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).SJ.out.tab

arguments:
  - valueFrom: |
      ${
        if (inputs.fastq_readgroup.reverse_fastq == null) {
          return inputs.fastq_readgroup.forward_fastq.path;
        }
        else {
          return inputs.fastq_readgroup.forward_fastq.path +
            ' '+ inputs.fastq_readgroup.reverse_fastq.path;
        }
      }
    prefix: --readFilesIn
    shellQuote: false

  - valueFrom: |
      ${
        function to_rg() {
          var rg_str = 'ID:'+inputs.fastq_readgroup.readgroup_meta['ID'];
          var keys = Object.keys(inputs.fastq_readgroup.readgroup_meta).sort();
          for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (key === 'ID') { continue; }
            var value = inputs.fastq_readgroup.readgroup_meta[key];
            if (key.length == 2 && value != null) {
              rg_str = rg_str + " " + key + ":" + value;
            }
          }
          return rg_str
        }

      var rg_str = to_rg();
      return rg_str;
      }
    prefix: --outSAMattrRGline
    shellQuote: false

  - valueFrom: $(inputs.fastq_readgroup.readgroup_meta["SM"]).$(inputs.fastq_readgroup.readgroup_meta["ID"]).
    prefix: --outFileNamePrefix
    shellQuote: false

baseCommand: [STAR, --runMode, alignReads]
