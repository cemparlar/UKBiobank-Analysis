#!/bin/bash
#SBATCH --job-name=plink_analysis
#SBATCH --output=plink_analysis.out
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --time=02:00:00

# Define your variables
vcf="LRRK2_GQ20_DP10_MISS_filtered.vcf.gz"
sex="covar_unrelated/sex_UKBB.txt"
pheno="covar_unrelated/pheno_UKBB.txt"
covar="covar_unrelated/covar_UKBB.txt"
name="LRRK2_GQ20_DP10_MISS_filtered"

# Load Plink module if needed
module load plink

zcat $vcf | awk 'BEGIN{FS=OFS="\t"}{if ($0~/^#/) {next;} print $3,$4}' > REF_ALLELE.txt

# Step 1: Convert VCF to Plink binary format
srun plink --vcf $vcf --update-sex $sex --make-bed --allow-no-sex --out $name --output-chr M

# Step 2: Add phenotype and covariate information
srun plink --bfile $name --pheno $pheno --make-bed --allow-no-sex --out $name --output-chr M

# Step 3: Perform logistic regression analysis
srun plink --bfile $name --a2-allele REF_ALLELE.txt --logistic hide-covar --covar $covar --covar-name Townsend, AgeAtRecruit, Sex, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10 --ci 0.95 --allow-no-sex --out $name --output-chr M

# Step 4: Perform association analysis
srun plink --bfile $name --a2-allele REF_ALLELE.txt --assoc fisher --out $name --output-chr M

# End of script