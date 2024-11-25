#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl

class: ExpressionTool

inputs:
  - id: array_fastq_readgroups
    type:
      type: array
      items:
        type: array
        items: readgroup.cwl#readgroup_fastq_bam

outputs:
  - id: samples
    type:
      type: array
      items:
        type: array
        items: readgroup.cwl#readgroup_fastq_bam

expression: |
  ${
    function include(arr,obj) {
      return (arr.indexOf(obj) != -1)
    }
    
    console.log("inputs: " + inputs.array_fastq_readgroups + "\n");
    var sample_list = [];

    // generate sample_list
    for (var i in inputs.array_fastq_readgroups) {
      console.log("i: " + i);
      for (var j in inputs.array_fastq_readgroups[i]) {
        console.log("j: " + j);
        var sample = inputs.array_fastq_readgroups[i][j].readgroup_meta.SM;
        if (!include(sample_list,sample)) {
          sample_list.push(sample);
        }
      }
    }

    // put each sample in separate array
    console.log("sample_list: " + sample_list);
    var out_array_rgs = [];
    sample_list.forEach(function (curr_sample, curr_sample_index) {
      console.log(curr_sample, curr_sample_index);
      var sample_rg_array = [];
      for (var i in inputs.array_fastq_readgroups) {
        for (var j in inputs.array_fastq_readgroups[i]) {
          var sample = inputs.array_fastq_readgroups[i][j].readgroup_meta.SM;
          if (sample == curr_sample) {
            sample_rg_array.push(inputs.array_fastq_readgroups[i][j]);
          }
        }
      }
      out_array_rgs.push(sample_rg_array);
    });
    
    return {"samples": out_array_rgs};
  }
