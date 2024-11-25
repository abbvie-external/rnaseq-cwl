#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl

class: ExpressionTool

inputs:
  - id: fastqs
    type:
      type: array
      items: File

  - id: sampleids
    type:
      type: array
      items: string

outputs:
  - id: samples
    type:
      type: array
      items: readgroup.cwl#readgroup_fastq_file

expression: |
  ${
    function startsWith(str, word) {
      return str.lastIndexOf(word, 0) === 0;
    }

    function get_file(file_list, filename) {
      var ret_value = null;
      for (var i in file_list) {
        var file = file_list[i];
        if (file.basename == filename) {
          ret_value = file;
        }
      }
      return ret_value;
    }

    var sample_array = [];
    for (var si in inputs.sampleids) {
      var sampleid = inputs.sampleids[si];
      // console.log("sampleid: " + sampleid);

      for (var fi in inputs.fastqs) {
        var fastq = inputs.fastqs[fi];
        // console.log("fastq" + fastq);
        if (fastq.basename.startsWith(sampleid)) {
          if (fastq.basename.indexOf("_R1_") !== -1) {
            // console.log("indexOf: " + fastq.basename.indexOf("_R1_"))
            var rg = {};
            rg['forward_fastq'] = fastq;
            var rev_fqbase = fastq.basename.replace("_R1_","_R2_");
            // console.log("rev_fqbase: " + rev_fqbase);
            var fastq_rev_file = get_file(inputs.fastqs, rev_fqbase);
            rg['reverse_fastq'] = fastq_rev_file;
            var rg_meta = {'SM': sampleid};
            rg['readgroup_meta'] = rg_meta;
            sample_array.push(rg);
            // console.log("rg: " + JSON.stringify(rg, null, 4));
          }
        }
      }
      // console.log("samples: " + sample_array);
    }

    return {'samples': sample_array};
  }
