#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerPull: replace-docker-url/trimgalore:latest
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.cwl
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.cores)
    coresMax: $(inputs.cores)
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: $(Math.ceil (2 * inputs.fastq_readgroup.forward_fastq.size / 1048576))
    tmpdirMax: $(Math.ceil (2 * inputs.fastq_readgroup.forward_fastq.size / 1048576))
    outdirMin: $(Math.ceil (2 * inputs.fastq_readgroup.forward_fastq.size / 1048576))
    outdirMax: $(Math.ceil (2 * inputs.fastq_readgroup.forward_fastq.size / 1048576))

class: CommandLineTool

inputs:
  - id: fastq_readgroup
    type: readgroup.cwl#readgroup_fastq_file

  - id: quality
    type: ["null", long]
    inputBinding:
      prefix: --quality

  - id: phred33
    type: ["null", boolean]
    inputBinding:
      prefix: --phred33

  - id: phred64
    type: ["null", boolean]
    inputBinding:
      prefix: --phred64

  - id: fastqc
    type: ["null", boolean]
    inputBinding:
      prefix: --fastqc

  - id: fastqc_args
    type: ["null", string]
    inputBinding:
      prefix: --fastqc_args

  - id: adapter
    type: ["null", string]
    inputBinding:
      prefix: --adapter

  - id: adapter2
    type: ["null", string]
    inputBinding:
      prefix: --adapter2

  - id: illumina
    type: ["null", boolean]
    inputBinding:
      prefix: --illumina

  - id: nextera
    type: ["null", boolean]
    inputBinding:
      prefix: --nextera

  - id: small_rna
    type: ["null", boolean]
    inputBinding:
      prefix: --small_rna

  - id: consider_already_trimmed
    type: ["null", long]
    inputBinding:
      prefix: --consider_already_trimmed

  - id: max_length
    type: ["null", long]
    inputBinding:
      prefix: --max_length

  - id: stringency
    type: ["null", long]
    inputBinding:
      prefix: --stringency

  - id: error_rate
    type: ["null", double]
    inputBinding:
      prefix: -e

  - id: gzip
    type: ["null", boolean]
    inputBinding:
      prefix: --gzip

  - id: dont_gzip
    type: ["null", boolean]
    inputBinding:
      prefix: --dont_gzip

  - id: length
    type: ["null", long]
    inputBinding:
      prefix: --length

  - id: max_n
    type: ["null", long]
    inputBinding:
      prefix: --max_n

  - id: trim-n
    type: ["null", boolean]
    inputBinding:
      prefix: --trim-n

  - id: output_dir
    type: ["null", string]
    inputBinding:
      prefix: --output_dir

  - id: no_report_file
    type: ["null", boolean]
    inputBinding:
      prefix: --no_report_file

  - id: suppress_warn
    type: ["null", boolean]
    inputBinding:
      prefix: --suppress_warn

  - id: clip_R1
    type: ["null", long]
    inputBinding:
      prefix: --clip_R1

  - id: clip_R2
    type: ["null", long]
    inputBinding:
      prefix: --clip_R2

  - id: three_prime_clip_R1
    type: ["null", long]
    inputBinding:
      prefix: --three_prime_clip_R1

  - id: three_prime_clip_R2
    type: ["null", long]
    inputBinding:
      prefix: --three_prime_clip_R2

  - id: basename
    type: ["null", string]
    inputBinding:
      prefix: --basename

  - id: cores
    type: long
    default: 1
    inputBinding:
      prefix: --cores

  - id: hardtrim5
    type: ["null", long]
    inputBinding:
      prefix: --hardtrim5

  - id: hardtrim3
    type: ["null", long]
    inputBinding:
      prefix: --hardtrim3

  - id: clock
    type: ["null", boolean]
    inputBinding:
      prefix: --clock

  - id: polyA
    type: ["null", boolean]
    inputBinding:
      prefix: --polyA

  - id: rrbs
    type: ["null", boolean]
    inputBinding:
      prefix: --rrbs

  - id: non_directional
    type: ["null", boolean]
    inputBinding:
      prefix: --non_directional

  - id: keep
    type: ["null", boolean]
    inputBinding:
      prefix: --keep

  - id: paired
    type: ["null", boolean]
    inputBinding:
      prefix: --paired

  - id: trim1
    type: ["null", boolean]
    inputBinding:
      prefix: --trim1

  - id: retain_unpaired
    type: ["null", boolean]
    inputBinding:
      prefix: --retain_unpaired

  - id: -r1/--length_1
    type: ["null", long]
    inputBinding:
      prefix: -r1/--length_1

  - id: -r2/--length_2
    type: ["null", long]
    inputBinding:
      prefix: -r2/--length_2

outputs:
  - id: output
    type: readgroup.cwl#readgroup_fastq_file
    outputBinding:
      glob: '*fq.gz'
      outputEval: |
        ${
          var sorted_self = self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) })

          var output_record = {};
          output_record["forward_fastq"] = sorted_self[0];
          output_record["readgroup_meta"] = inputs.fastq_readgroup.readgroup_meta;

          if (sorted_self.length == 2) {
            output_record["reverse_fastq"] = sorted_self[1];
          }

          return output_record;
        }

  - id: report1
    type: File
    outputBinding:
      glob: $(inputs.fastq_readgroup.forward_fastq.basename)_trimming_report.txt

  - id: report2
    type: ["null", File]
    outputBinding:
      glob: |
        ${
          if (!inputs.fastq_readgroup.reverse_fastq) {
            return null;
          }
          else {
            return inputs.fastq_readgroup.reverse_fastq.basename+"_trimming_report.txt";
          }
        }

arguments:
  - valueFrom: |
      ${
        if (inputs.fastq_readgroup.reverse_fastq == null) {
          return inputs.fastq_readgroup.forward_fastq.path;
        }
        else {
          return inputs.fastq_readgroup.forward_fastq.path +
            ' '+ inputs.fastq_readgroup.reverse_fastq.path;
        }
      }
    position: 99
    shellQuote: false
      
baseCommand: [trim_galore]
