#!/bin/bash
# This script applies hard filters to the SNP VCF using GATK VariantFiltration.
# Variants failing filters will be marked in the output VCF's FILTER column.

# Define input and output paths (update paths accordingly)
input_vcf="/path/to/vcf/raw_snps.vcf.gz"
output_vcf="/path/to/vcf/snps_hardfiltered.vcf.gz"

# Run GATK VariantFiltration to apply hard filter criteria to SNPs
nohup gatk VariantFiltration \
    -V "${input_vcf}" \
    --filter-expression "QD < 2.0 || MQ < 40.0 || FS > 60.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
    --filter-name "Filter" \
    -O "${output_vcf}" > "/path/to/vcf/hardfilter.log" 2>&1 &
