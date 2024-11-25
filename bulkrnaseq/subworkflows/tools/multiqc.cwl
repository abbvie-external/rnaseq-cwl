#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/multiqc:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 15000
    ramMax: 15000
    tmpdirMin: 10000
    tmpdirMax: 10000
    outdirMin: 10000
    outdirMax: 10000

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 12

class: CommandLineTool

inputs:
  - id: input
    type:
      type: array
      items: Directory
    inputBinding:
      position: 99

  # - id: force
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --force

  # - id: dirs
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --dirs

  # - id: dirs-depth
  #   type: ["null", long]
  #   inputBinding:
  #     prefix: --dirs-depth

  # - id: fullnames
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --fullnames

  # - id: title
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --title

  # - id: comment
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --comment

  - id: filename
    type: ["null", string]
    inputBinding:
      prefix: --filename

  # - id: outdir
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --outdir

  # - id: template
  #   type:
  #     - "null"
  #     - type: enum
  #       symbols:
  #         - default
  #         - default_dev
  #         - geo
  #         - sections
  #         - simple
  #   inputBinding:
  #     prefix: --template

  # - id: tag
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --tag

  # - id: view-tags
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --view-tags

  # - id: ignore
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --ignore

  # - id: ignore-samples
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --ignore-samples

  # - id: ignore-symlinks
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --ignore-symlinks

  # - id: sample-names
  #   type: ["null", File]
  #   inputBinding:
  #     prefix: --sample-names

  # - id: file-list
  #   type: ["null", File]
  #   inputBinding:
  #     prefix: --file-list

  # - id: exclude
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --exclude

  # - id: module
  #   type: ["null", string]
  #   inputBinding:
  #     prefix: --module

  # - id: data-dir
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --data-dir

  # - id: no-data-dir
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --no-data-dir

  # - id: data-format
  #   type:
  #     - "null"
  #     - type: enum
  #       symbols:
  #         - tsv
  #         - json
  #         - yaml
  #   inputBinding:
  #     prefix: --data-format

  # - id: zip-data-dir
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --zip-data-dir

  # - id: export
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --export

  # - id: flat
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --flat

  # - id: interactive
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --interactive

  # - id: lint
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --lint

  # - id: pdf
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --pdf

  # - id: no-megaqc-upload
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --no-megaqc-upload

  # - id: config
  #   type: ["null", File]
  #   inputBinding:
  #     prefix: --config

  # - id: cl-config
  #   type: ["null", File]
  #   inputBinding:
  #     prefix: --cl-config

  # - id: verbose
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --verbose

  # - id: quiet
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --quiet

  # - id: no-ansi
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --no-ansi
      
  # - id: version
  #   type: ["null", boolean]
  #   inputBinding:
  #     prefix: --version

outputs:
  - id: html
    type: File
    outputBinding:
      glob: |
        ${
           if (inputs.filename) {
             var outfile = inputs.filename + '.html';
           }
           else {
             var outfile = 'multiqc_report.html';
           }
           return outfile;
        }

  - id: data
    type: Directory
    outputBinding:
      glob: |
        ${
           if (inputs.filename) {
             var outdir = inputs.filename + '_data';
           }
           else {
             var outdir = 'multiqc_data';
           }
           return outdir;
        }

arguments:
  - valueFrom: "."
    position: 99
  
baseCommand: [multiqc]
