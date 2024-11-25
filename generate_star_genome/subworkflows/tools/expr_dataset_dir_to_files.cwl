#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: dataset_dir
    type: Directory

  - id: dataset_catalog
    type: File
    loadContents: true

  - id: filetypes
    type:
      type: array
      items: string

outputs:
  - id: cds
    type: File

  - id: genome
    type: File

  - id: gtf
    type: File

expression: |
  ${
    var dc_data = JSON.parse(inputs.dataset_catalog.contents);

    var output = {};
    for (var i in inputs.filetypes) {
      var filetype = inputs.filetypes[i];
      for (var j in dc_data["assemblies"][1]["files"]) {
        var file_obj = dc_data["assemblies"][1]["files"][j]
        if (filetype == file_obj["fileType"]) {
          output[filetype] = inputs.dataset_dir.location + "/data/" + file_obj["filePath"];
        }
      }
    }

    return {
      "cds": {"class": "File", "location": output["CDS_NUCLEOTIDE_FASTA"]},
      "genome": {"class": "File", "location": output["GENOMIC_NUCLEOTIDE_FASTA"]},
      "gtf": {"class": "File", "location": output["GTF"]}
      };
  }
