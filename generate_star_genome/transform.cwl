#!/usr/bin/env cwl-runner

cwlVersion: v1.2

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: dbsnp_array
    type:
      type: array
      items: File
  - id: fasta_array
    type:
      type: array
      items: File
  - id: decoy_fasta_array
    type:
      type: array
      items: File
  - id: fasta_cdna_array
    type:
      type: array
      items: File
  - id: decoy_fasta_cdna_array
    type:
      type: array
      items: File
  - id: decoy_type_array
    type:
      type: array
      items: string
  - id: gtf_array
    type:
      type: array
      items: File
  - id: decoy_gtf_array
    type:
      type: array
      items: File
  - id: bedcutstring
    type: string
  - id: gtf_keyvalues
    type:
      type: array
      items: string
  - id: gtf_modname
    type: string
  - id: run_uuid
    type: string
  - id: species
    type: string
  - id: thread_count
    type: long

outputs:
  - id: dbsnp_index
    type: ["null", File]
    secondaryFiles:
      - .tbi
    outputSource: index_dbsnp/output
  - id: genome_chrLength_txt
    type: File
    outputSource: star_generate_genome/chrLength_txt
  - id: genome_chrNameLength_txt
    type: File
    outputSource: star_generate_genome/chrNameLength_txt
  - id: genome_chrName_txt
    type: File
    outputSource: star_generate_genome/chrName_txt
  - id: genome_chrStart_txt
    type: File
    outputSource: star_generate_genome/chrStart_txt
  - id: genome_exonGeTrInfo_tab
    type: File
    outputSource: star_generate_genome/exonGeTrInfo_tab
  - id: genome_Genome
    type: File
    outputSource: star_generate_genome/Genome
  - id: genome_exonInfo_tab
    type: File
    outputSource: star_generate_genome/exonInfo_tab
  - id: genome_geneInfo_tab
    type: File
    outputSource: star_generate_genome/geneInfo_tab
  - id: genome_genomeParameters_txt
    type: File
    outputSource: star_generate_genome/genomeParameters_txt
  - id: genome_Log_out
    type: File
    outputSource: star_generate_genome/Log_out
  - id: genome_SA
    type: File
    outputSource: star_generate_genome/SA
  - id: genome_SAindex
    type: File
    outputSource: star_generate_genome/SAindex
  - id: genome_sjdbInfo_txt
    type: File
    outputSource: star_generate_genome/sjdbInfo_txt
  - id: genome_sjdbList_fromGTF_out_tab
    type: File
    outputSource: star_generate_genome/sjdbList_fromGTF_out_tab
  - id: genome_sjdbList_out_tab
    type: File
    outputSource: star_generate_genome/sjdbList_out_tab
  - id: genome_transcriptInfo_tab
    type: File
    outputSource: star_generate_genome/transcriptInfo_tab
  - id: rrna_intervallist
    type: File
    outputSource: gtf2rrnainterval/output
  - id: ref_flat
    type: File
    outputSource: genepred2refflat/output
  - id: fasta_cdna
    type: File
    outputSource: decide_multi_single/fasta_cdna
  - id: gtf
    type: File
    outputSource: decide_multi_single/gtf
  - id: fasta_index_dict
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    outputSource: root_fasta_dict_index/output
  - id: collapsed_gtf
    type: File
    outputSource: collapse_annotation/collapsed_gtf
  - id: collapsed_bed
    type: File
    outputSource: collapsed_gtf_to_bed/bed
  - id: outgtf
    type: File
    outputSource: decide_multi_single/gtf
  - id: kallisto_indexed
    type: File
    outputSource: kallisto_index/indexed
  - id: kallisto_hawsh_indexed
    type: File
    outputSource: kallisto_hawsh_index/indexed

steps:
  - id: multi_species
    run: subworkflows/merge_species.cwl
    in:
      - id: dbsnp_array
        source: dbsnp_array
      - id: fasta_array
        source: fasta_array
      - id: decoy_fasta_array
        source: decoy_fasta_array
      - id: fasta_cdna_array
        source: fasta_cdna_array
      - id: decoy_fasta_cdna_array
        source: decoy_fasta_cdna_array
      - id: gtf_array
        source: gtf_array
      - id: decoy_gtf_array
        source: decoy_gtf_array
      - id: decoy_type_array
        source: decoy_type_array
    out:
      - id: dbsnp_concat
      - id: fasta_concat
      - id: fasta_cdna_concat
      - id: gtf_concat
      - id: gtf_nodecoy_concat
    when: $(inputs.fasta_array.length > 1)

  - id: single_species
    run: subworkflows/single_species.cwl
    in:
      - id: dbsnp
        source: dbsnp_array
        valueFrom: |
          ${
           if (self.length > 0) {
             var val = self[0];
           }
           else {
             var val = null;
           }
           return val;
          }
      - id: fasta
        source: fasta_array
        valueFrom: $(self[0])
      - id: fasta_cdna
        source: fasta_cdna_array
        valueFrom: $(self[0])
      - id: gtf
        source: gtf_array
        valueFrom: $(self[0])
      - id: decoy_fasta_array
        source: decoy_fasta_array
      - id: decoy_fasta_cdna_array        
        source: decoy_fasta_cdna_array
      - id: decoy_gtf_array
        source: decoy_gtf_array
      - id: decoy_type_array
        source: decoy_type_array
      - id: fasta_array
        source: fasta_array
    out:
      - id: dbsnp_out
      - id: fasta_out
      - id: fasta_cdna_out
      - id: gtf_out
      - id: gtf_nodecoy_out
    when: $(inputs.fasta_array.length == 1)

  - id: decide_multi_single
    run: subworkflows/tools/decider_multi_single_species.cwl
    in:
      - id: dbsnp_multi
        source: multi_species/dbsnp_concat
      - id: fasta_multi
        source: multi_species/fasta_concat
      - id: fasta_cdna_multi
        source: multi_species/fasta_cdna_concat
      - id: gtf_multi
        source: multi_species/gtf_concat
      - id: gtf_nodecoy_multi
        source: multi_species/gtf_nodecoy_concat
      - id: dbsnp_single
        source: single_species/dbsnp_out
      - id: fasta_single
        source: single_species/fasta_out
      - id: fasta_cdna_single
        source: single_species/fasta_cdna_out
      - id: gtf_single
        source: single_species/gtf_out
      - id: gtf_nodecoy_single
        source: single_species/gtf_nodecoy_out
    out:
      - id: dbsnp
      - id: fasta
      - id: fasta_cdna
      - id: gtf
      - id: gtf_nodecoy
    
  - id: star_generate_genome
    run: ./subworkflows/tools/star_generate_genome.cwl
    in:
      - id: genomeFastaFiles
        source: decide_multi_single/fasta
      - id: sjdbGTFfile
        source: decide_multi_single/gtf
      - id: runThreadN
        source: thread_count
    out:
      - id: chrLength_txt
      - id: chrNameLength_txt
      - id: chrName_txt
      - id: chrStart_txt
      - id: exonGeTrInfo_tab
      - id: exonInfo_tab
      - id: geneInfo_tab
      - id: Genome
      - id: genomeParameters_txt
      - id: Log_out
      - id: SA
      - id: SAindex
      - id: sjdbInfo_txt
      - id: sjdbList_fromGTF_out_tab
      - id: sjdbList_out_tab
      - id: transcriptInfo_tab

  - id: compress_dbsnp
    run: subworkflows/tools/bcftools_bgzip.cwl
    in:
      - id: input
        source: decide_multi_single/dbsnp
      - id: index
        valueFrom: $(false)
      - id: threads
        source: thread_count
    out:
      - id: output
    when: $(inputs.input !== null)

  - id: index_dbsnp
    run: subworkflows/tools/bcftools_tabix.cwl
    in:
      - id: input
        source: compress_dbsnp/output
      - id: preset
        valueFrom: vcf
    out:
      - id: output
    when: $(inputs.input !== null)

  - id: dict_fasta
    run: subworkflows/tools/picard_createsequencedictionary.cwl
    in:
      - id: reference
        source: decide_multi_single/fasta
      - id: species
        source: species
    out:
      - id: output

  - id: index_fasta
    run: subworkflows/tools/samtools_faidx.cwl
    in:
      - id: input
        source: decide_multi_single/fasta
    out:
      - id: output

  - id: root_fasta_dict_index
    run: subworkflows/tools/root_fasta.cwl
    in:
      - id: fasta
        source: decide_multi_single/fasta
      - id: fasta_index
        source: index_fasta/output
      - id: fasta_dict
        source: dict_fasta/output
    out:
      - id: output

  - id: gtftogenepred
    run: subworkflows/tools/gtftogenepred.cwl
    in:
      - id: input
        source: decide_multi_single/gtf
      - id: genePredExt
        valueFrom: $(true)
      - id: geneNameAsName2
        valueFrom: $(true)
      - id: ignoreGroupsWithoutExons
        valueFrom: $(true)
    out:
      - id: output

  # https://github.com/broadinstitute/picard/issues/805
  - id: genepred2refflat
    run: subworkflows/tools/awk.cwl
    in:
      - id: input
        source: gtftogenepred/output
      - id: awkexpression
        valueFrom: 'BEGIN { OFS="\t"} {print $12, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}'
      - id: outname
        source: gtftogenepred/output
        valueFrom: $(self.nameroot).refflat
    out:
      - id: output
        
  - id: gtf2rrnainterval
    run: subworkflows/gtf2rrnainterval.cwl
    in:
      - id: bedcutstring
        source: bedcutstring
      - id: dict
        source: dict_fasta/output
      - id: fasta
        source: decide_multi_single/fasta
      - id: gtf
        source: decide_multi_single/gtf_nodecoy
      - id: gtf_keyvalues
        source: gtf_keyvalues
      - id: gtf_modname
        source: gtf_modname
    out:
      - id: output

  - id: collapse_annotation
    run: subworkflows/tools/collapse_annotation.cwl
    in:
      - id: gtf
        source: decide_multi_single/gtf_nodecoy
    out:
      - id: collapsed_gtf

  - id: collapsed_gtf_to_bed
    run: subworkflows/tools/bedops_gtf2bed.cwl
    in:
      - id: gtf
        source: collapse_annotation/collapsed_gtf
    out:
      - id: bed

  - id: kallisto_index
    run: subworkflows/tools/kallisto_index.cwl
    in:
      - id: index
        source: decide_multi_single/fasta_cdna
        valueFrom: $(self.basename.split('.').slice(0,-1).join('.')).ki
      - id: fasta
        source: decide_multi_single/fasta_cdna
    out:
      - id: indexed

  - id: kallisto_hawsh_index
    run: subworkflows/tools/kallisto_hawsh_index.cwl
    in:
      - id: index
        source: decide_multi_single/fasta_cdna
        valueFrom: $(self.basename.split('.').slice(0,-1).join('.')).hawsh.ki
      - id: fasta
        source: decide_multi_single/fasta_cdna
    out:
      - id: indexed
