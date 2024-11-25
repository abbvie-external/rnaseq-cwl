#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/subread:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 6000
    ramMax: 8000
    tmpdirMin: $( Math.ceil ((inputs.input.size + inputs.annotation.size + inputs.genome.size) / 1048576 ))
    tmpdirMax: $( Math.ceil ((inputs.input.size + inputs.annotation.size + inputs.genome.size) / 1048576 ))
    outdirMin: 100
    outdirMax: 100
  - class: SchemaDefRequirement
    types:
      - $import: gtf_type.cwl

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 3

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      position: 99

  - id: annotation
    type: File
    inputBinding:
      prefix: -a

  - id: chrAliases
    type: [File, "null"]
    inputBinding:
      prefix: -A

  - id: requireBothEndsMapped
    type: [boolean, "null"]
    inputBinding:
      prefix: -B

  - id: NOTcountChimericFragments
    type: [boolean, "null"]
    inputBinding:
      prefix: -C

  - id: minFragLength
    type: [long, "null"]
    inputBinding:
      prefix: -d

  - id: maxFragLength
    type: [long, "null"]
    inputBinding:
      prefix: -D

  - id: useMetaFeatures
    type: [boolean, "null"]
    inputBinding:
      prefix: -f

  - id: isGTFAnnotationFile
    type:
      - "null"
      - type: enum
        symbols:
          - GTF
          - SAF
    inputBinding:
      prefix: -F

  - id: GTF_attrType
    type: gtf_type.cwl#GTF_attrType
    inputBinding:
      prefix: -g

  - id: genome
    type: File
    inputBinding:
      prefix: -G

  - id: juncCounts
    type: [boolean, "null"]
    inputBinding:
      prefix: -J

  - id: isLongRead
    type: [boolean, "null"]
    inputBinding:
      prefix: -L

  - id: countMultiMappingReads
    type: [boolean, "null"]
    inputBinding:
      prefix: -M

  - id: allowMultiOverlap
    type: [boolean, "null"]
    inputBinding:
      prefix: -O
      
  - id: isPairedEnd
    type: [boolean, "null"]
    inputBinding:
      prefix: -p

  - id: checkFragLength
    type: [boolean, "null"]
    inputBinding:
      prefix: -P

  - id: minMQS
    type: [long, "null"]
    inputBinding:
      prefix: -Q

  - id: reportReads
    type:
      - "null"
      - type: enum
        symbols:
          - CORE
          - SAM
          - BAM
    inputBinding:
      prefix: -R

  - id: isStrandSpecific
    type:
      - "null"
      - type: enum
        symbols:
          - "0"
          - "1"
          - "2"
    inputBinding:
      prefix: -s

  - id: GTF_featureType
    type: gtf_type.cwl#GTF_featureType
    inputBinding:
      prefix: -t

  - id: nthreads
    type: [long, "null"]
    inputBinding:
      prefix: -T

  - id: byReadGroup
    type: [boolean, "null"]
    inputBinding:
      prefix: --byReadGroup

  - id: countReadPairs
    type: [boolean, "null"]
    inputBinding:
      prefix: --countReadPairs

  - id: donotsort
    type: [boolean, "null"]
    inputBinding:
      prefix: --donotsort

  - id: extraAttributes
    type: [string, "null"]
    inputBinding:
      prefix: --extraAttributes
      
  - id: fraction
    type: [float, "null"]
    inputBinding:
      prefix: --fraction

  - id: fracOverlap
    type: [float, "null"]
    inputBinding:
      prefix: --fracOverlap

  - id: fracOverlapFeature
    type: [float, "null"]
    inputBinding:
      prefix: --fracOverlapFeature

  - id: ignoreDup
    type: [boolean, "null"]
    inputBinding:
      prefix: --ignoreDup

  - id: largestOverlap
    type: [long, "null"]
    inputBinding:
      prefix: --largestOverlap

  - id: maxMOp
    type: [long, "null"]
    inputBinding:
      prefix: --maxMOp

  - id: minOverlap
    type: [long, "null"]
    inputBinding:
      prefix: --minOverlap

  - id: nonOverlap
    type: [long, "null"]
    inputBinding:
      prefix: --nonOverlap

  - id: nonOverlapFeature
    type: [long, "null"]
    inputBinding:
      prefix: --nonOverlapFeature

  - id: nonSplitOnly
    type: [boolean, "null"]
    inputBinding:
      prefix: --nonSplitOnly

  - id: primary
    type: [boolean, "null"]
    inputBinding:
      prefix: --primary

  - id: read2pos
    type: [long, "null"]
    inputBinding:
      prefix: --read2pos

  - id: readExtension3
    type: [long, "null"]
    inputBinding:
      prefix: --readExtension3

  - id: readExtension5
    type: [long, "null"]
    inputBinding:
      prefix: --readExtension5

  - id: readShiftSize
    type: [long, "null"]
    inputBinding:
      prefix: --readShiftSize

  - id: readShiftType
    type:
      - "null"
      - type: enum
        symbols:
          - downstream
          - left
          - right
          - upstream

  - id: reportReads
    type:
      - "null"
      - type: enum
        symbols:
          - BAM
          - CORE
          - SAM
    inputBinding:
      prefix: --reportReadsPath

  - id: splitOnly
    type: [boolean, "null"]
    inputBinding:
      prefix: --splitOnly

  - id: useMetaFeatures
    type: [boolean, "null"]
    inputBinding:
      prefix: --useMetaFeatures

  - id: tmpDir
    type: [string, "null"]
    inputBinding:
      prefix: --tmpDir

  - id: verbose
    type: [boolean, "null"]
    inputBinding:
      prefix: --verbose

outputs:
  - id: counts
    type: File
    outputBinding:
      glob: $(inputs.input.basename).$(inputs.GTF_featureType).$(inputs.GTF_attrType).counts

  - id: summary
    type: File
    outputBinding:
      glob: $(inputs.input.basename).$(inputs.GTF_featureType).$(inputs.GTF_attrType).counts.summary

  - id: junccounts
    type: ["null", File]
    outputBinding:
      glob: $(inputs.input.basename).$(inputs.GTF_featureType).$(inputs.GTF_attrType).counts.jcounts

arguments:
  - valueFrom: $(inputs.input.basename).$(inputs.GTF_featureType).$(inputs.GTF_attrType).counts
    prefix: -o

baseCommand: [featureCounts]
