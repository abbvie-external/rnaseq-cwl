#!/usr/bin/env bash
mkdir -p join

export musculus_fasta=Mus_musculus.GRCm39.dna.primary_assembly.fa
export musculus_cdna=Mus_musculus.GRCm39.cdna.all.fa
export musculus_gtf=Mus_musculus.GRCm39.108.gtf
export musculus_vcf=homo_sapiens_clinically_associated.vcf
export sapiens_fasta=Homo_sapiens.GRCh38.dna.primary_assembly.fa
export sapiens_cdna=Homo_sapiens.GRCh38.cdna.all.fa
export sapiens_gtf=Homo_sapiens.GRCh38.108.gtf
export sapiens_vcf=homo_sapiens_somatic.vcf

export fastas="${sapiens_fasta};${musculus_fasta}"
export cdna="${sapiens_cdna};${musculus_cdna}"
export gtfs="${sapiens_gtf};${musculus_gtf}"
export vcfs="${sapiens_vcf};${musculus_vcf}"

export musculus_genome_name=$(head -n 1 ${musculus_fasta} | awk '{print $3}' | awk -F ':' '{print $2}')
export sapiens_genome_name=$(head -n 1 ${sapiens_fasta} | awk '{print $3}' | awk -F ':' '{print $2}')

# annotate references with species-specific contigs
sed "s/^>/>${musculus_genome_name}_/g" ${musculus_fasta} > join/${musculus_fasta}
sed "s/^>/>${sapiens_genome_name}_/g" ${sapiens_fasta} > join/${sapiens_fasta}
sed -E "s/(^[^#])/${musculus_genome_name}_\1/g" ${musculus_gtf} > join/${musculus_gtf}
sed -E "s/(^[^#])/${sapiens_genome_name}_\1/g" ${sapiens_gtf} > join/${sapiens_gtf}
sed -E "s/(^[^#])/${musculus_genome_name}_\1/g" ${musculus_vcf} > join/${musculus_vcf}
sed -E "s/(^[^#])/${sapiens_genome_name}_\1/g" ${sapiens_vcf} > join/${sapiens_vcf}

##FASTA
echo "\n\nFASTA\n\n"
joined_fasta=""
IFS=';' read -r -a fasta_array <<< "${fastas}"
for fasta in "${fasta_array[@]}"
do
    echo "${fasta}"
    IFS='.' read -r -a fasta_parts <<< "${fasta}"
    for index in "${!fasta_parts[@]}"
    do
        if [[ ${index} -eq 2 ]]; then
            break
        fi
        echo ${index}
        echo ${fasta_parts[${index}]}
        joined_fasta+=${fasta_parts[${index}]}"."
    done
done
joined_fasta+=${fasta_parts[2]}"."
joined_fasta+=${fasta_parts[3]}"."
joined_fasta+=${fasta_parts[4]}
echo ${joined_fasta}

cat_fastas="cat "
for fasta in "${fasta_array[@]}"
do
    cat_fastas+="join/${fasta} "
done
cat_fastas+="> join/${joined_fasta}"
echo "${cat_fastas}"
eval ${cat_fastas}

##GTF
echo "\n\nGTF\n\n"
joined_gtf=""
IFS=';' read -r -a gtf_array <<< "${gtfs}"
for gtf in "${gtf_array[@]}"
do
    echo "${gtf}"
    IFS='.' read -r -a gtf_parts <<< "${gtf}"
    for index in "${!gtf_parts[@]}"
    do
        if [[ ${index} -eq 3 ]]; then
            break
        fi
        echo ${index}
        echo ${gtf_parts[${index}]}
        joined_gtf+=${gtf_parts[${index}]}"."
    done
done
joined_gtf+=${gtf_parts[3]}
echo ${joined_gtf}

cat_gtfs="cat "
for gtf in "${gtf_array[@]}"
do
    cat_gtfs+="join/${gtf} "
done
cat_gtfs+="> join/${joined_gtf}"
echo "${cat_gtfs}"
eval ${cat_gtfs}

##VCF
echo "\n\nVCF\n\n"
joined_vcf=""
IFS=';' read -r -a vcf_array <<< "${vcfs}"
for vcf in "${vcf_array[@]}"
do
    echo "${vcf}"
    IFS='.' read -r -a vcf_parts <<< "${vcf}"
    for index in "${!vcf_parts[@]}"
    do
        if [[ ${index} -eq 1 ]]; then
            break
        fi
        echo ${index}
        echo ${vcf_parts[${index}]}
        joined_vcf+=${vcf_parts[${index}]}"."
    done
done
joined_vcf+=${vcf_parts[1]}
echo ${joined_vcf}

cat_vcfs="cat "
for vcf in "${vcf_array[@]}"
do
    cat_vcfs+="join/${vcf} "
done
cat_vcfs+="> join/${joined_vcf}"
echo "${cat_vcfs}"
eval ${cat_vcfs}
