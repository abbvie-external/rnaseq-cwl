#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/bclconvert:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs["bcl-num-conversion-threads"])
    coresMax: $(inputs["bcl-num-conversion-threads"])
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: bcl-input-directory
    type: Directory
    inputBinding:
      prefix: --bcl-input-directory

  - id: force
    type: ["null", boolean]
    inputBinding:
      prefix: --force

  - id: output-directory
    type: string
    default: .
    inputBinding:
      prefix: --output-directory

  - id: sample-sheet
    type: ["null", File]
    inputBinding:
      prefix: --sample-sheet

  - id: strict-mode
    type:
      - "null"
      - type: enum
        symbols:
          - "true"
          - "false"
    inputBinding:
      prefix: --strict-mode
    
  - id: bcl-only-lane
    type: ["null", int]
    inputBinding:
      prefix: --bcl-only-lane

  - id: bcl-num-parallel-tiles
    type: ["null", long]
    inputBinding:
      prefix: --bcl-num-parallel-tiles

  - id: bcl-num-conversion-threads
    type: ["null", long]
    inputBinding:
      prefix: --bcl-num-conversion-threads

  - id: bcl-num-compression-threads
    type: ["null", long]
    inputBinding:
      prefix: --bcl-num-compression-threads

  - id: bcl-num-decompression-threads
    type: ["null", long]
    inputBinding:
      prefix: --bcl-num-decompression-threads

  - id: tiles
    type: ["null", string]
    inputBinding:
      prefix: --tiles
      
outputs:
  - id: fastqs
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.fastq.gz"
      outputEval: |
        ${
          var fastqs = self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) });
          return fastqs;
        }

  - id: reports
    type: Directory
    outputBinding:
      glob: Reports

  - id: logs
    type: Directory
    outputBinding:
      glob: Logs

#  - id: logs_Errors.log
#    type: File
#    outputBinding:
#      glob: Logs/Errors.log

#  - id: logs_FastqComplete.txt
#    type: File
#    outputBinding:
#      glob: Logs/FastqComplete.txt

#  - id: logs_Info.log
#    type: File
#    outputBinding:
#      glob: Logs/Info.log

#  - id: logs_Warnings.log
#    type: File
#    outputBinding:
#      glob: Logs/Warnings.log
    
#  - id: report_Adapter_Metrics.csv
#    type: File
#    outputBinding:
#      glob: Reports/Adapter_Metrics.csv

#  - id: report_Demultiplex_Stats.csv
#    type: File
#    outputBinding:
#      glob: Reports/Demultiplex_Stats.csv

#  - id: report_IndexMetricsOut.bin
#    type: File
#    outputBinding:
#      glob: Reports/IndexMetricsOut.bin

#  - id: report_Index_Hopping_Counts.csv
#    type: File
#    outputBinding:
#      glob: Reports/Index_Hopping_Counts.csv

#  - id: report_Quality_Metrics.csv
#    type: File
#    outputBinding:
#      glob: Reports/Quality_Metrics.csv

#  - id: report_RunInfo.xml
#    type: File
#    outputBinding:
#      glob: Reports/RunInfo.xml

#  - id: report_SampleSheet.csv
#    type: File
#    outputBinding:
#      glob: Reports/SampleSheet.csv

#  - id: report_Top_Unknown_Barcodes.csv
#    type: File
#    outputBinding:
#      glob: Reports/Top_Unknown_Barcodes.csv

#  - id: report_fastq_list.csv
#    type: File
#    outputBinding:
#      glob: Reports/fastq_list.csv


baseCommand: [bcl-convert]
