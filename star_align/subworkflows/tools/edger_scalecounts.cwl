#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/edger:latest
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.abundance_h5.basename)
        entry: $(inputs.abundance_h5)
        writable: true
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: $(Math.ceil ((inputs.abundance_h5.size * 2) / 1048576))
    tmpdirMax: $(Math.ceil ((inputs.abundance_h5.size * 2) / 1048576))
    outdirMin: $(Math.ceil (inputs.abundance_h5.size / 1048576))
    outdirMax: $(Math.ceil (inputs.abundance_h5.size / 1048576))

class: CommandLineTool

inputs:
  - id: abundance_h5
    type: File

  - id: sampleid
    type: string
    inputBinding:
      prefix: --sampleid

outputs:
  - id: scaled_counts
    type: File
    outputBinding:
      glob: scaledcounts.tsv

baseCommand: [/usr/bin/Rscript, /usr/local/bin/edgeRKallistoScaledCounts.r]
