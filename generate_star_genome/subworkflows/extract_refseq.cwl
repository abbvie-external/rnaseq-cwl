#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  - id: refseq_id
    type: string

outputs:
  - id: fasta
    type: File
    outputSource: get_dataset_files/genome
  - id: fasta_cdna
    type: File
    outputSource: get_dataset_files/cds
  - id: gtf
    type: File
    outputSource: sanitize_gtf/outfile

steps:
  - id: entrez_refseq_to_gsa
    run: tools/entrezdirectshscript.cwl
    in:
      - id: nuccore_query
        source: refseq_id
    out:
      - id: output

  - id: datasets_download
    run: tools/datasets_download.cwl
    in:
      - id: accession
        source: entrez_refseq_to_gsa/output
      - id: include_items
        valueFrom: $(["cds", "genome", "gtf"])
    out:
      - id: zip

  - id: unzip_dataset
    run: tools/unzip_dataset.cwl
    in:
      - id: zip
        source: datasets_download/zip
    out:
      - id: assembly_data_report
      - id: dataset_catalog
      - id: dir

  - id: get_dataset_files
    run: tools/expr_dataset_dir_to_files.cwl
    in:
      - id: dataset_dir
        source: unzip_dataset/dir
      - id: dataset_catalog
        source: unzip_dataset/dataset_catalog
      - id: filetypes
        valueFrom: $(["GENOMIC_NUCLEOTIDE_FASTA", "CDS_NUCLEOTIDE_FASTA", "GTF"])
    out:
      - id: cds
      - id: genome
      - id: gtf

  - id: sanitize_gtf
    run: tools/grep.cwl
    in:
      - id: infile
        source: get_dataset_files/gtf
      - id: extended_regexp
        valueFrom: $(true)
      - id: invert_match
        valueFrom: $(true)
      - id: word_regexp
        valueFrom: "(start_codon|stop_codon|unassigned_transcript_[1-9]|unassigned_transcript_[1-9][0-9]|unassigned_transcript_1[0-9]{2})"
    out:
      - id: outfile
