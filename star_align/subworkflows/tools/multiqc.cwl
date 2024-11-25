#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/qianjx5/multiqc:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: |
      ${
        var inp_list = [];
        for (var i = 0; i < inputs.input.length; i++) {
          inp_list.push(inputs.input[i]);
        }
        console.log("inp_list:");
        console.log(inp_list);
        return inp_list;
      }
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 5
    outdirMax: 5


class: CommandLineTool

inputs:
  - id: input
    type:
      type: array
      items: File
  
  - id: force
    type: ["null", boolean]
    inputBinding:
      prefix: --force

  - id: dirs
    type: ["null", string]
    inputBinding:
      prefix: --dirs

  - id: dirs-depth
    type: ["null", long]
    inputBinding:
      prefix: --dirs-depth

  - id: fullnames
    type: ["null", boolean]
    inputBinding:
      prefix: --fullnames

  - id: title
    type: ["null", string]
    inputBinding:
      prefix: --title

  - id: comment
    type: ["null", string]
    inputBinding:
      prefix: --comment

  - id: filename
    type: ["null", string]
    inputBinding:
      prefix: --filename

  - id: outdir
    type: ["null", string]
    default: outdir
    inputBinding:
      prefix: --outdir

  - id: template
    type:
      - "null"
      - type: enum
        symbols:
          - default
          - default_dev
          - geo
          - sections
          - simple
    inputBinding:
      prefix: --template

  - id: tag
    type: ["null", string]
    inputBinding:
      prefix: --tag

  - id: view-tags
    type: ["null", boolean]
    inputBinding:
      prefix: --view-tags

  - id: ignore
    type: ["null", string]
    inputBinding:
      prefix: --ignore

  - id: ignore-samples
    type: ["null", string]
    inputBinding:
      prefix: --ignore-samples

  - id: ignore-symlinks
    type: ["null", boolean]
    inputBinding:
      prefix: --ignore-symlinks

  - id: sample-names
    type: ["null", File]
    inputBinding:
      prefix: --sample-names

  - id: file-list
    type: ["null", File]
    inputBinding:
      prefix: --file-list

  - id: exclude
    type: ["null", string]
    inputBinding:
      prefix: --exclude

  - id: module
    type: ["null", string]
    inputBinding:
      prefix: --module

  - id: data-dir
    type: ["null", boolean]
    inputBinding:
      prefix: --data-dir

  - id: no-data-dir
    type: ["null", boolean]
    inputBinding:
      prefix: --no-data-dir

  - id: data-format
    type:
      - "null"
      - type: enum
        symbols:
          - tsv
          - json
          - yaml
    inputBinding:
      prefix: --data-format

  - id: zip-data-dir
    type: ["null", boolean]
    inputBinding:
      prefix: --zip-data-dir

  - id: export
    type: ["null", boolean]
    inputBinding:
      prefix: --export

  - id: flat
    type: ["null", boolean]
    inputBinding:
      prefix: --flat

  - id: interactive
    type: ["null", boolean]
    inputBinding:
      prefix: --interactive

  - id: lint
    type: ["null", boolean]
    inputBinding:
      prefix: --lint

  - id: pdf
    type: ["null", boolean]
    inputBinding:
      prefix: --pdf

  - id: no-megaqc-upload
    type: ["null", boolean]
    inputBinding:
      prefix: --no-megaqc-upload

  - id: config
    type: ["null", File]
    inputBinding:
      prefix: --config

  - id: cl-config
    type: ["null", string]
    inputBinding:
      prefix: --cl-config

  - id: verbose
    type: ["null", boolean]
    inputBinding:
      prefix: --verbose

  - id: quiet
    type: ["null", boolean]
    inputBinding:
      prefix: --quiet

  - id: no-ansi
    type: ["null", boolean]
    inputBinding:
      prefix: --no-ansi
      
  - id: version
    type: ["null", boolean]
    inputBinding:
      prefix: --version

outputs:
  - id: html
    type: File
    outputBinding:
      glob: $(inputs.outdir)/multiqc_report.html

  - id: data
    type: Directory
    outputBinding:
      glob: $(inputs.outdir)/multiqc_data

arguments:
  - valueFrom: "."
    position: 99
  
baseCommand: [multiqc]
