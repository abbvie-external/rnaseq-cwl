#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/ngscheckmate:latest
  - class: EnvVarRequirement
    envDef:
      - envName: NCM_HOME
        envValue: /usr/local/NGSCheckMate
  - class: InitialWorkDirRequirement
    listing:
      - ${
        var inp_list = [];
        for (var i = 0; i < inputs.fastq1.length; i++) {
          inp_list.push(inputs.fastq1[i]);
        }
        return inp_list;
        }
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000

class: CommandLineTool

inputs:
  - id: fastq1
    type:
      type: array
      items: File

  - id: input_file_list
    type: File
    inputBinding:
      prefix: --list

  - id: outdir
    type: string
    default: .
    inputBinding:
      prefix: --outdir

  - id: outfilename
    type: string
    default: output
    inputBinding:
      prefix: --outfilename

  - id: pattern
    type: File
    inputBinding:
      prefix: --pt

  - id: threads
    type: long
    default: 24
    inputBinding:
      prefix: --maxthread

outputs:
  - id: all
    type: File
    outputBinding:
      glob: $(inputs.outfilename)_all.txt

  - id: corr_matrix
    type: File
    outputBinding:
      glob: $(inputs.outfilename)_corr_matrix.txt

  - id: matched
    type: File
    outputBinding:
      glob: $(inputs.outfilename)_matched.txt

  - id: pdf
    type: File
    outputBinding:
      glob: $(inputs.outfilename).pdf
baseCommand: [python2, /usr/local/NGSCheckMate/ncm_fastq.py]
