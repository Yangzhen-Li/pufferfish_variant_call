#!/bin/bash
# This script extracts SNP variants from the multi-sample VCF using GATK SelectVariants.

# Define input and output files (update paths accordingly)
input_vcf="/path/to/vcf/all_samples.vcf.gz"
output_vcf="/path/to/vcf/raw_snps.vcf.gz"

# Run GATK SelectVariants to select only SNPs from the VCF
gatk SelectVariants \
  -select-type SNP \
  -V "$input_vcf" \
  -O "$output_vcf"
