#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/gatk:latest
  - class: InlineJavascriptRequirement
  - class: NetworkAccess
    networkAccess: true
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 50000
    ramMax: 50000
    tmpdirMin: |
      ${
        var size = 0;
        size += inputs.reference.size;
        for (var i in inputs.variant) {
          size += inputs.variant[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    tmpdirMax: |
      ${
        var size = 0;
        size += inputs.reference.size;
        for (var i in inputs.variant) {
          size += inputs.variant[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMin: |
      ${
        var size = 0;
        size += inputs.reference.size;
        for (var i in inputs.variant) {
          size += inputs.variant[i].size;
        }
        return Math.ceil (size / 1048576);
      }
    outdirMax: |
      ${
        var size = 0;
        size += inputs.reference.size;
        for (var i in inputs.variant) {
          size += inputs.variant[i].size;
        }
        return Math.ceil (size / 1048576);
      }

class: CommandLineTool

inputs:
  - id: create_output_variant_index
    type: boolean
    default: false
    inputBinding:
      prefix: --create-output-variant-index

  - id: output
    type: string
    inputBinding:
      prefix: --output

  - id: reference
    type: File
    inputBinding:
      prefix: --reference
    secondaryFiles:
      - .fai
      - ^.dict

  - id: variant
    type:
      type: array
      items: File
      inputBinding:
        prefix: --variant

outputs:
  - id: outgvcf
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - .tbi

baseCommand: [java, -jar, /usr/local/gatk-4/gatk-package-local.jar, CombineGVCFs]
