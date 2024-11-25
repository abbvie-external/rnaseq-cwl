#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1

class: ExpressionTool

inputs:
  - id: fastq1
    type: File

  - id: fastq2
    type: File

  - id: readgroup_json
    type: File
    inputBinding:
      loadContents: true

  - id: sequencing_center
    type: string

outputs:
  - id: output
    type: readgroup.cwl#readgroup_fastq_file

expression: |
  ${
    var readgroup = JSON.parse(inputs.readgroup_json.contents);
    var readgroup_meta = new Object();
    for (var i in readgroup) {
      readgroup_meta[i] = readgroup[i];
    }
    readgroup_meta["CN"] = inputs.sequencing_center;

    var f1_s = inputs.fastq1.basename.split('_');
    var f2_s = inputs.fastq2.basename.split('_');
    var fc = readgroup_meta["ID"].split('.')[0];
    var fastq1_fc = f1_s[0] + '_' + fc + '_' + f1_s[1] + '_' + f1_s[2] + '_' + f1_s[3] + '_' + f1_s[4];
    var fastq2_fc = f2_s[0] + '_' + fc + '_' + f2_s[1] + '_' + f2_s[2] + '_' + f2_s[3] + '_' + f2_s[4];
    var output = {'forward_fastq': {'class': 'File',
                                    'location': inputs.fastq1.location,
                                    'basename': fastq1_fc},
                  'reverse_fastq': {'class': 'File',
                                    'location': inputs.fastq2.location,
                                    'basename': fastq2_fc},
                  'readgroup_meta': readgroup_meta
                  };

    return {'output': output};
  }
