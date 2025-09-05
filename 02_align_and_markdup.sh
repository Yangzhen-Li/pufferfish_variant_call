#!/bin/bash
# This script aligns cleaned reads to the reference genome and marks duplicates.
# Step 1: Use BWA-MEM to align reads and samtools to sort BAMs.
# Step 2: Use Picard to mark duplicates in the sorted BAMs.
# It generates a list of sample IDs from the cleaned reads (id_list) to iterate through in step 2.

# Define directories and files (update paths accordingly)
ref_genome="/path/to/reference_genome.fa"              # Reference genome FASTA
clean_data_dir="/path/to/sole_WGS_pipeline/cleandata/" # Directory with cleaned FASTQ files from step 1
bam_dir="/path/to/sole_WGS_pipeline/bam/"              # Output directory for sorted BAM files
marked_dir="${bam_dir}marked_duplicates/"              # Output directory for duplicate-marked BAMs
gvcf_dir="/path/to/sole_WGS_pipeline/gvcf/"            # (Will be used in later steps, created here for completeness)
tmp_dir="/path/to/sole_WGS_pipeline/tmp/"              # Temp directory for Picard/GATK (if needed)
id_list="/path/to/sole_WGS_pipeline/cleandata/id_list" # File to store sample IDs
picard_jar="/path/to/picard.jar"                       # Path to Picard jar (MarkDuplicates tool)

# Create necessary directories if they don't exist
mkdir -p "$bam_dir" "$marked_dir" "$gvcf_dir" "$tmp_dir"

# Generate id_list file of sample IDs (based on cleaned FASTQ files present)
ls "${clean_data_dir}"*_clean_1.fq.gz | sed 's/_clean_1.fq.gz$//' | xargs -n1 basename > "$id_list"

# Set max concurrent jobs for alignment
max_jobs=30

# Function to control concurrency
wait_for_jobs() {
    while [ "$(jobs -pr | wc -l)" -ge "$max_jobs" ]; do
        sleep 5
    done
}

# Step 1: Align reads with BWA-MEM and sort with samtools
for clean_file_1 in "${clean_data_dir}"*_clean_1.fq.gz; do
    sample_id=$(basename "${clean_file_1}" _clean_1.fq.gz)
    clean_file_2="${clean_data_dir}${sample_id}_clean_2.fq.gz"

    # Align with BWA and sort output to BAM
    nohup bash -c "
    bwa mem -t 6 -R '@RG\tID:${sample_id}\tSM:${sample_id}\tPL:illumina' '${ref_genome}' '${clean_file_1}' '${clean_file_2}' | \
    samtools sort -@ 6 -o '${bam_dir}${sample_id}.sorted.bam' -
    " > "${bam_dir}${sample_id}.log" 2>&1 &

    wait_for_jobs
done
wait  # wait for all alignment jobs to finish

# Step 2: Mark duplicates using Picard
while IFS= read -r sample_id; do
    bam_file="${bam_dir}${sample_id}.sorted.bam"

    if [[ -f "${bam_file}" ]]; then
        nohup java -Xmx16G -jar "${picard_jar}" MarkDuplicates \
            I="${bam_file}" \
            O="${marked_dir}${sample_id}.marked.bam" \
            CREATE_INDEX=true \
            REMOVE_DUPLICATES=true \
            M="${marked_dir}${sample_id}.markedmetrics.txt" \
            > "${marked_dir}${sample_id}.log" 2>&1 &

        wait_for_jobs
    else
        echo "BAM file ${bam_file} not found, skipping..."
    fi

done < "$id_list"
wait  # wait for all MarkDuplicates jobs to finish
