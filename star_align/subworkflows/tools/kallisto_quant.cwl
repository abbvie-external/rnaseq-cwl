#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/kallisto:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)
    coresMax: $(inputs.threads)
    ramMin: 5000
    ramMax: 6000
    tmpdirMin: |
      ${
        var size = 0;
        size += inputs.index.size;
        size += inputs.gtf.size;
        for (var i in inputs.fastq) {
          size += inputs.fastq[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    tmpdirMax: |
      ${
        var size = 0;
        size += inputs.index.size;
        size += inputs.gtf.size;
        for (var i in inputs.fastq) {
          size += inputs.fastq[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMin: |
      ${
        var size = 0;
        size += inputs.index.size;
        size += inputs.gtf.size;
        for (var i in inputs.fastq) {
          size += inputs.fastq[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMax: |
      ${
        var size = 0;
        size += inputs.index.size;
        size += inputs.gtf.size;
        for (var i in inputs.fastq) {
          size += inputs.fastq[i].size;
        }
        return Math.ceil (size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: bootstrap_samples
    type: ["null", long]
    inputBinding:
      prefix: --bootstrap-samples

  - id: index
    type: File
    inputBinding:
      prefix: --index=
      separate: false

  - id: gtf
    type: ["null", File]
    inputBinding:
      prefix: --gtf

  - id: output_dir
    type: string
    default: .
    inputBinding:
      prefix: -o

  - id: threads
    type: long
    inputBinding:
      prefix: --threads=
      separate: false

  - id: single
    type: ["null", boolean]
    inputBinding:
      prefix: --single
      
  - id: genomebam
    type: ["null", boolean]
    inputBinding:
      prefix: --genomebam

  - id: pseudobam
    type: ["null", boolean]
    inputBinding:
      prefix: pseudobam

  - id: chromosomes
    type: ["null", File]
    inputBinding:
      prefix: --chromosomes

  - id: forward_stranded
    type: ["null", boolean]
    inputBinding:
      prefix: --fr-stranded

  - id: reverse_stranded
    type: ["null", boolean]
    inputBinding:
      prefix: --rf-stranded

  - id: fragment_length
    type: ["null", double]
    inputBinding:
      prefix: --fragment-length=
      separate: false

  - id: std_dev
    type: ["null", double]
    inputBinding:
      prefix: --sd=
      separate: false

  - id: fastq
    type:
      type: array
      items: File
    inputBinding:
      position: 99

outputs:
  - id: abundance_h5
    type: File
    outputBinding:
      glob: abundance.h5

  - id: abundance_tsv
    type: File
    outputBinding:
      glob: abundance.tsv

  - id: pseudoalignments_bam
    type: ["null", File]
    outputBinding:
      glob: pseudoalignments.bam
    secondaryFiles:
      - .bai

  - id: run_info_json
    type: File
    outputBinding:
      glob: run_info.json

baseCommand: [kallisto, quant]
