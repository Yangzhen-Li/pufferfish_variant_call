#!/bin/bash
# This script runs GATK HaplotypeCaller on each marked BAM to produce a per-sample GVCF.
# It reads sample IDs from the id_list (generated in step 2) and runs jobs in parallel (up to max_jobs).

# Define directories (update paths accordingly)
ref_genome="/path/to/reference_genome.fa"
bam_dir="/path/to/bam/marked_duplicates/"  # Input marked BAMs from step 2
output_dir="/path/to/gvcf/"                # Output directory for GVCF files
tmp_dir="/path/to/tmp/"                    # Temp directory (for GATK if needed)
id_list="/path/to/cleandata/id_list"       # List of sample IDs

# Create output and temp directories if they do not exist
mkdir -p "$output_dir" "$tmp_dir"

# Set max concurrent jobs
max_jobs=20

# Function to control concurrency
wait_for_jobs() {
    while [ "$(jobs -pr | wc -l)" -ge "$max_jobs" ]; do
        sleep 5
    done
}

# Loop through each sample ID and call variants (GVCF) in background
while IFS= read -r sample_id; do
  bam_file="${bam_dir}${sample_id}.marked.bam"
  gvcf_file="${output_dir}${sample_id}.g.vcf"

  if [[ -f "$bam_file" ]]; then
    # Call variants with GATK HaplotypeCaller in GVCF mode
    nohup gatk --java-options "-Xmx16g -Djava.io.tmpdir=${tmp_dir}" HaplotypeCaller \
          -R "${ref_genome}" \
          -I "${bam_file}" \
          -ERC GVCF \
          -O "${gvcf_file}" > "${output_dir}${sample_id}.log" 2>&1 &

    wait_for_jobs
  else
    echo "BAM file ${bam_file} not found, skipping..."
  fi

done < "$id_list"

# Wait for all HaplotypeCaller jobs to finish
wait
