#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: input
    type: File
    inputBinding:
      loadContents: true

outputs:
  - id: output
    type: ["null", double]

expression: |
  ${
    function startsWith(str, word) {
      return str.lastIndexOf(word, 0) === 0;
    }
    var output = null;
    var lines = inputs.input.contents;
    var lines_split = lines.split('\n');
    for (var i = 0; i < lines_split.length; i++) {
      if (lines_split[i].startsWith('read_len_sd_ss')) {
        var rlss = lines_split[i].split(/\s+/)[1];
        output = parseFloat(rlss);
      }
    }
    return {'output': output};
  }
