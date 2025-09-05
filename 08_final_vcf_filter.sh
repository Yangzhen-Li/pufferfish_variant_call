#!/bin/bash
# This script performs additional filtering on the hard-filtered SNP VCF using VCFtools.
# It filters for bi-allelic SNPs, allele frequency, depth, quality, and missingness.

# Define input and output paths (update paths accordingly)
input_vcf="/path/to//vcf/snps_hardfiltered.vcf.gz"
output_prefix="/path/to/vcf/snps_final"

# Run VCFtools to filter SNPs based on various criteria
nohup vcftools \
    --gzvcf "${input_vcf}" \
    --recode-INFO-all \
    --max-alleles 2 \
    --min-alleles 2 \
    --maf 0.05 \
    --maxDP 3000 \
    --minDP 3 \
    --min-meanDP 3 \
    --minQ 200 \
    --max-missing 0.8 \
    --recode \
    --remove-filtered-all \
    --out "${output_prefix}" > "/path/to/vcf/vcftools_filter.log" 2>&1 &
