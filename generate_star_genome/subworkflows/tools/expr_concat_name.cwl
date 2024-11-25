#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: ref_array
    type:
      type: array
      items: File

  - id: dots_kept
    type: int

outputs:
  - id: concat_name
    type: string

expression: |
  ${
    var file_name_arr = [];

    for (var i in inputs.ref_array) {
      var ref_file = inputs.ref_array[i];
      var ref_split = inputs.ref_array[i].basename.split(".");
      var ref_kept = ref_split.slice(0, inputs.dots_kept);
      file_name_arr = file_name_arr.concat(ref_kept);
    }

    var last_idx = ref_split.length - 1;
    var file_suffix = ref_split[last_idx];
    file_name_arr.push(file_suffix);
    var concat_name = file_name_arr.join(".");

    return {"concat_name": concat_name};
  }
