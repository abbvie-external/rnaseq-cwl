#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: json
    type: File
    loadContents: true

outputs:
  - id: values
    type:
      type: array
      items: string

expression: |
  ${
    var data = JSON.parse(inputs.json.contents);
    return {"values": data};
  }
