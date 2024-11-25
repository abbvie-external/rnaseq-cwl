#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl

class: ExpressionTool

inputs:
  - id: fastq1
    type: File

  - id: fastq2
    type: ["null", File]

  - id: readgroup_json
    type: File
    inputBinding:
      loadContents: true
      valueFrom: $(null)

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

    var forward_fastq = inputs.fastq1;
    if (inputs.reverse_fastq !== null) {
      var reverse_fastq = inputs.fastq2;
    } else {
      var reverse_fastq = null;
    }

    

    var output = {'forward_fastq': forward_fastq,
                  'reverse_fastq': reverse_fastq,
                  'readgroup_meta': readgroup_meta
                  }

    return {'output': output};
  }