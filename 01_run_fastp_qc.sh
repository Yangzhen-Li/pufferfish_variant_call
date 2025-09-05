#!/bin/bash
# This script performs quality control on raw FASTQ files using fastp.
# It processes all FASTQ files in the raw_data_dir, running fastp in parallel (up to max_jobs at a time).
# Adjust the directory paths and max_jobs as needed before running.

# Directory paths (update these to your paths)
raw_data_dir="/path/to/rawdata/"
clean_data_dir="/path/to/cleandata/"

# Ensure the output directory exists
mkdir -p "${clean_data_dir}"

# Maximum number of simultaneous fastp jobs
max_jobs=50

# Function to wait if max_jobs are already running
function wait_for_jobs {
    while [ "$(jobs -pr | wc -l)" -ge "$max_jobs" ]; do
        sleep 5
    done
}

# Loop through all raw FASTQ files and process in background
for raw_file_1 in "${raw_data_dir}"*_raw_1.fq.gz; do
    if [[ ! -e "$raw_file_1" ]]; then
        echo "No raw FASTQ files found in ${raw_data_dir}"
        break
    fi
    sample_id=$(basename "$raw_file_1" _raw_1.fq.gz)
    raw_file_2="${raw_data_dir}${sample_id}_raw_2.fq.gz"

    # Check if both paired raw files exist
    if [[ -f "$raw_file_2" ]]; then
        # Define output file paths for cleaned reads and JSON report
        clean_file_1="${clean_data_dir}${sample_id}_clean_1.fq.gz"
        clean_file_2="${clean_data_dir}${sample_id}_clean_2.fq.gz"
        json_report="${clean_data_dir}${sample_id}.json"

        # Run fastp for quality control (trimming/filtering) in background
        fastp -i "$raw_file_1" -I "$raw_file_2" \
              -o "$clean_file_1" -O "$clean_file_2" \
              -j "$json_report" \
              > "${clean_data_dir}${sample_id}_fastp.log" 2>&1 &

        # Limit number of simultaneous jobs
        wait_for_jobs
    else
        echo "Raw mate file for ${sample_id} not found, skipping..."
    fi
done

# Wait for all background jobs to finish before exiting
wait
