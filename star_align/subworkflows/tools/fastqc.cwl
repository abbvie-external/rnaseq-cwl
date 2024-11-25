#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/fastqc:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)
    coresMax: $(inputs.threads)
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: |
      ${
        var size = 0;
        for (var i in inputs.INPUT) {
          size += inputs.INPUT[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    tmpdirMax: |
      ${
        var size = 0;
        for (var i in inputs.INPUT) {
          size += inputs.INPUT[i].size;
        }
        return Math.ceil (size / 1048576);
      }      
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: adapters
    type: ["null", File]
    inputBinding:
      prefix: --adapters

  - id: casava
    type: ["null", boolean]
    inputBinding:
      prefix: --casava

  - id: contaminants
    type: ["null", File]
    inputBinding:
      prefix: --contaminants

  - id: dir
    type: string
    default: .
    inputBinding:
      prefix: --dir

  - id: extract
    type: boolean
    default: true
    inputBinding:
      prefix: --extract

  - id: format
    type: string
    default: fastq
    inputBinding:
      prefix: --format

  - id: INPUT
    type:
      type: array
      items: File
    inputBinding:
      position: 99

  - id: kmers
    type: ["null", long]
    inputBinding:
      prefix: --kmers

  - id: limits
    type: ["null", File]
    inputBinding:
      prefix: --limits

  - id: nano
    type: ["null", boolean]
    inputBinding:
      prefix: --nano

  - id: noextract
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --noextract

  - id: nofilter
    type: ["null", boolean]
    inputBinding:
      prefix: --nofilter

  - id: nogroup
    type: ["null", boolean]
    inputBinding:
      prefix: --nogroup

  - id: outdir
    type: string
    default: .
    inputBinding:
      prefix: --outdir

  - id: quiet
    type: ["null", boolean]
    inputBinding:
      prefix: --quiet

  - id: threads
    type: long
    default: 1
    inputBinding:
      prefix: --threads

outputs:
  - id: fastqc_data_txt
    type: File
    outputBinding:
      glob: $(inputs.INPUT.basename.split('.').slice(0,-2).join('.'))_fastqc/fastqc_data.txt

  - id: summary_txt
    type: File
    outputBinding:
      glob: $(inputs.INPUT.basename.split('.').slice(0,-2).join('.'))_fastqc/summary.txt
          
baseCommand: [/usr/local/FastQC/fastqc]
