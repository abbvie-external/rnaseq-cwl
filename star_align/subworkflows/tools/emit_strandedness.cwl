#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl

class: ExpressionTool

inputs:
  - id: input
    type: File
    inputBinding:
      loadContents: true

outputs:
  - id: output
    type:
      - "null"
      - type: enum
        symbols:
          - forward
          - reverse
          - unstranded
        

expression: |
  ${
    function startsWith(str, word) {
      return str.lastIndexOf(word, 0) === 0;
    }

    function includes(arr,obj) {
      return (arr.indexOf(obj) != -1)
    }

    var output = null;
    var lines = inputs.input.contents;
    var lines_split = lines.split('\n');
    for (var i = 0; i < lines_split.length; i++) {
      // console.log(i);
      // console.log(lines_split[i]);
      if (lines_split[i].startsWith('Data is likely')) {
        // console.log("found");
        if (includes(lines_split[i],"RF/fr-firststrand") | includes(lines_split[i],"RF/rf-stranded")) {
         output = "reverse";
        }
        else if (includes(lines_split[i],"FR/fr-secondstrand") | includes(lines_split[i], "FR/fr-stranded")) {
          output = "forward";
        }
        else if (includes(lines_split[i],"unstranded")) {
          output = "unstranded";
        }
      }
    }

    return {'output': output};
  }
