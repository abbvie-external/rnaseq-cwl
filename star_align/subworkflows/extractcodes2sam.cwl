#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: tools/readgroup.cwl
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: basecalls_dir
    type: Directory
  - id: barcode_file
    type: File
  - id: library_file
    type: File
  - id: read_structure
    type: string
  - id: runinfo_flowcell
    type: string
  - id: runinfo_instrument
    type: string
  - id: sequencing_center
    type: string

outputs:
  - id: fastq_bam_readgroups
    type:
      type: array
      items: tools/readgroup.cwl#readgroup_fastq_bam
    outputSource: bamtofastqreadgroup/fastq_bam_readgroup

steps:
  - id: createmetricslaneexpression
    run: tools/createmetricslaneexpression.cwl
    in:
      - id: basecalls_dir
        source: basecalls_dir
        valueFrom: $(self.basename)
      - id: barcode_file
        source: barcode_file
        valueFrom: $(self.basename)
    out:
      - id: metrics
      - id: lane

  - id: extractilluminabarcodes
    run: tools/picard_extractilluminabarcodes.cwl
    in:
      - id: basecalls_dir
        source: basecalls_dir
      - id: metrics_file
        source: createmetricslaneexpression/metrics
      - id: lane
        source: createmetricslaneexpression/lane
      - id: barcode_file
        source: barcode_file
      - id: NUM_PROCESSORS
        valueFrom: $(10)
      - id: read_structure
        source: read_structure
      - id: validation_stringency
        valueFrom: STRICT
    out:
      - id: metrics
      - id: barcodes

  - id: basecallstosam
    run: tools/picard_illuminabasecallstosam.cwl
    in:
      - id: basecalls_dir
        source: basecalls_dir
      - id: barcodes_dir
        source: extractilluminabarcodes/barcodes
        valueFrom: |
          ${
            function local_dirname(path) {
              return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');
            }

            var afile = self[0].location;
            var apath = local_dirname(afile);
            return {"class": "Directory", "location": apath};
          }
      - id: read_structure
        source: read_structure
      - id: sequencing_center
        source: sequencing_center
      - id: lane
        source: createmetricslaneexpression/lane
      - id: library_params
        source: library_file
      - id: NUM_PROCESSORS
        valueFrom: $(12)
      - id: run_barcode
        source:
         - runinfo_flowcell
         - runinfo_instrument
        valueFrom: $(self[0])$(self[1])
      - id: validation_stringency
        valueFrom: STRICT
    out:
      - id: bams

  - id: bamtofastqreadgroup
    run: bamtofastqreadgroup.cwl
    scatter: bam
    in:
      - id: bam
        source: basecallstosam/bams
    out:
      - id: fastq_bam_readgroup
