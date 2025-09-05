#!/bin/bash
# This script performs joint genotyping on the combined GVCF to produce a multi-sample VCF.
# It uses GATK GenotypeGVCFs on the output of CombineGVCFs.

# Define input and output (update paths accordingly)
ref_genome="/path/to/reference_genome.fa"
combined_gvcf_file="/path/to/sole_WGS_pipeline/combined_gvcf/combined.g.vcf.gz"
output_dir="/path/to/sole_WGS_pipeline/vcf"
output_vcf_file="${output_dir}/all_samples.vcf.gz"   # Output multi-sample VCF
log_file="${output_dir}/genotype_gvcf.log"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

threads=12
memory="240g"

# Run GATK GenotypeGVCFs to generate the combined VCF
nohup gatk --java-options "-Xmx${memory} -XX:ParallelGCThreads=${threads}" GenotypeGVCFs \
    -R "${ref_genome}" \
    -V "${combined_gvcf_file}" \
    -O "${output_vcf_file}" > "${log_file}" 2>&1 &

echo "Process started with no hang-up. Check ${log_file} for progress."
