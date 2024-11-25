#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/star:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.runThreadN / 2)
    coresMax: $(inputs.runThreadN / 2)
    ramMin: $(90 * 1024)
    ramMax: $(90 * 1024)
    tmpdirMin: $(Math.ceil (20 * inputs.genomeFastaFiles.size / 1048576))
    tmpdirMax: $(Math.ceil (20 * inputs.genomeFastaFiles.size / 1048576))
    outdirMin: $(Math.ceil (20 * inputs.genomeFastaFiles.size / 1048576))
    outdirMax: $(Math.ceil (20 * inputs.genomeFastaFiles.size / 1048576))

class: CommandLineTool

inputs:
  - id: runMode
    type: string
    default: "genomeGenerate"
    inputBinding:
      prefix: --runMode

  - id: runThreadN
    type: long
    default: 1
    inputBinding:
      prefix: --runThreadN

  - id: genomeDir
    type: string
    default: "."
    inputBinding:
      prefix: --genomeDir

  - id: genomeFastaFiles
    type: File
    inputBinding:
      prefix: --genomeFastaFiles

  - id: sjdbGTFfile
    type: File
    inputBinding:
      prefix: --sjdbGTFfile

  - id: sjdbOverhang
    type: int
    default: 100
    inputBinding:
      prefix: --sjdbOverhang

outputs:
  - id: chrLength_txt
    type: File
    outputBinding:
      glob: chrLength.txt

  - id: chrNameLength_txt
    type: File
    outputBinding:
      glob: chrNameLength.txt

  - id: chrName_txt
    type: File
    outputBinding:
      glob: chrName.txt

  - id: chrStart_txt
    type: File
    outputBinding:
      glob: chrStart.txt

  - id: exonGeTrInfo_tab
    type: File
    outputBinding:
      glob: exonGeTrInfo.tab

  - id: exonInfo_tab
    type: File
    outputBinding:
      glob: exonInfo.tab

  - id: geneInfo_tab
    type: File
    outputBinding:
      glob: geneInfo.tab

  - id: Genome
    type: File
    outputBinding:
      glob: Genome

  - id: genomeParameters_txt
    type: File
    outputBinding:
      glob: genomeParameters.txt

  - id: Log_out
    type: File
    outputBinding:
      glob: Log.out

  - id: SA
    type: File
    outputBinding:
      glob: SA

  - id: SAindex
    type: File
    outputBinding:
      glob: SAindex

  - id: sjdbInfo_txt
    type: File
    outputBinding:
      glob: sjdbInfo.txt

  - id: sjdbList_fromGTF_out_tab
    type: File
    outputBinding:
      glob: sjdbList.fromGTF.out.tab

  - id: sjdbList_out_tab
    type: File
    outputBinding:
      glob: sjdbList.out.tab

  - id: transcriptInfo_tab
    type: File
    outputBinding:
      glob: transcriptInfo.tab

baseCommand: [STAR]
