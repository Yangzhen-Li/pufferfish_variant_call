#!/bin/bash
# This script combines all per-sample GVCF files into a single GVCF using GATK CombineGVCFs.
# Run this after all GVCFs are generated in the gvcf_dir.

# Define directories and inputs (update paths accordingly)
ref_genome="/path/to/reference_genome.fa"
gvcf_dir="/path/to/gvcf/"               # Directory containing individual *.g.vcf files
output_dir="/path/to/combined_gvcf/"    # Directory for the combined GVCF output
combined_gvcf_file="${output_dir}combined.g.vcf.gz"       # Name of the combined GVCF to produce
log_file="${output_dir}combine_gvcfs.log"                 # Log file for this process

threads=36    # Number of threads for GATK to use (adjust based on your system)
memory="480g" # Java heap memory (adjust based on available RAM)

# Create output directory if it does not exist
mkdir -p "$output_dir"

# Combine GVCFs using GATK CombineGVCFs
nohup gatk --java-options "-Xmx${memory} -XX:ParallelGCThreads=${threads}" CombineGVCFs \
    -R "${ref_genome}" \
    $(find "$gvcf_dir" -name "*.g.vcf" -exec echo --variant {} \;) \
    -O "${combined_gvcf_file}" > "$log_file" 2>&1 &

echo "Process started with no hang-up. Check ${log_file} for progress."
