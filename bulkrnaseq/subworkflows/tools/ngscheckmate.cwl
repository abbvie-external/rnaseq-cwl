#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/ngscheckmate:latest
  - class: EnvVarRequirement
    envDef:
      - envName: NCM_HOME
        envValue: /usr/local/NGSCheckMate
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - ${
        var inp_list = [];
        for (var i = 0; i < inputs.input.length; i++) {
          inp_list.push(inputs.input[i]);
        }
        return inp_list;
        }
      - entryname: GRCh38.primary_assembly.genome.fa
        entry: $(inputs.fasta)
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000

class: CommandLineTool

inputs:
  - id: fasta
    type: File

  - id: input
    type:
      type: array
      items: File

  - id: bam
    type: ["null", boolean]
    inputBinding:
      prefix: --BAM

  - id: vcf
    type: ["null", boolean]
    inputBinding:
      prefix: --VCF

  - id: dir
    type: string
    default: .
    inputBinding:
      prefix: --dir
      
  - id: family_cutoff
    type: ["null", boolean]
    inputBinding:
      prefix: --family_cutoff

  - id: bed
    type: ["null", File]
    inputBinding:
      prefix: --bed

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

  - id: nonzero
    type: ["null", boolean]
    inputBinding:
      prefix: --nonzero

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

baseCommand: [python2, /usr/local/NGSCheckMate/ncm.py]
