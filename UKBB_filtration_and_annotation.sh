#!/bin/bash

BASE_DIR="~/runs/sitkicem/JULY_UKBB"
UKBB_DIR="/project/rpp-aevans-ab/neurohub/ukb/genetics/exome/pop_variants_pvcf"

# STEP 0: Indexing the VCF file via tabix
srun -c 1 --mem=10g -t 0:15:0 bash tabix.sh ukb23156_c12_b13_v1.vcf.gz
# STEP 1: Limiting the VCF file by LRRK2 boundaries 40618781	40763172 and filtering for GQ20, DP 10, missingness
srun -c 2 --mem=17g -t 3:0:0 bash GATK_interval_and_filtration.sh ~/runs/sitkicem/JULY_UKBB ukb23156_c12_b13_v1 20 10 380000 LRRK2.bed &&
# STEP 2: Convert VCF output after GATK into PLINK format
srun -c 2 --mem=15g -t 0:30:0 plink --vcf LRRK2_GQ20_DP10_MISS_filtered.vcf.gz --vcf-half-call m --make-bed --out LRRK2_after_GATK &&
# STEP 3: Convert VCF to ANNOVAR format
srun -c 1 --mem=10g -t 0:30:0 perl ~/runs/sitkicem/annovar/convert2annovar.pl --format vcf4 LRRK2_GQ20_DP10_MISS_filtered.vcf.gz --allsample --withfreq --outfile chr12_b13_recode_convert &&
# STEP 4: Annotate SNPs with MAF3 using ANNOVAR
srun -c 1 --mem=8g -t 0:30:0 perl ~/runs/sitkicem/annovar/table_annovar.pl chr12_b13_recode_convert ~/runs/sitkicem/annovar/humandb/ --buildver hg38 --out chr12_b13_recode_convert.annovar --remove --protocol refGene,ljb26_all,dbnsfp41c --operation g,f,f --nastring .




