#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/rnaseq-scripts:latest
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 8000
    ramMax: 8000
    tmpdirMin: 100
    tmpdirMax: 100
    outdirMin: 100
    outdirMax: 100
  - class: SchemaDefRequirement
    types:
      - $import: gtf_type.cwl

$namespaces:
  arv: "http://arvados.org/cwl#"

hints:
  arv:OutOfMemoryRetry:
    memoryRetryMultipler: 10

class: CommandLineTool

inputs:
  - id: sample_dir
    type:
      type: array
      items: Directory
      inputBinding:
        prefix: --sample-dir

  - id: project_id
    type: string
    inputBinding:
      prefix: --project-id

  - id: attribute_type
    type: gtf_type.cwl#GTF_attrType
    inputBinding:
      prefix: --attribute-type

  - id: feature_type
    type: gtf_type.cwl#GTF_featureType
    inputBinding:
      prefix: --feature-type

  - id: aggregation_type
    type:
      type: enum
      symbols:
        - counts
        - junccounts
    inputBinding:
      prefix: --aggregation-type

outputs:
  - id: counts
    type: ["null", File]
    outputBinding:
      glob: $(inputs.project_id).$(inputs.feature_type).$(inputs.attribute_type).counts.featurecounts.tsv

  - id: junccounts
    type: ["null", File]
    outputBinding:
      glob: $(inputs.project_id).$(inputs.feature_type).$(inputs.attribute_type).junccounts.featurecounts.tsv

baseCommand: [join_featurecount_samples.py]
