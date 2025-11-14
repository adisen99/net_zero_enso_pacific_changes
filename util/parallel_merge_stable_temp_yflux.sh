#!/bin/bash
#!/bin/bash

INPUT_PATTERN="/g/data/ob22/as8561/data/enso_trans_stable/sst_grad_res/oht_files/stable_2030/*"
BATCH_SIZE=10 # Number of files per parallel batch

# ... (Previous code to list and split files is fine) ...
ALL_FILES=$(ls $INPUT_PATTERN)
TOTAL_FILES=$(echo $ALL_FILES | wc -w)

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "Error: No input files found matching $INPUT_PATTERN"
    exit 1
fi

ls $INPUT_PATTERN | split -l $BATCH_SIZE -d -a 3 - input_batch_

NUM_BATCHES=$(ls input_batch_* | wc -w)
echo "Total files: $TOTAL_FILES, split into $NUM_BATCHES batches of $BATCH_SIZE files each."


# Define the merge function
run_cdo_batch_merge() {
    BATCH_FILE=$1
    cdo mergetime $(cat $BATCH_FILE) intermediate_${BATCH_FILE}.nc
}

# 3. Export the function AND explicitly set the SHELL for parallel
export -f run_cdo_batch_merge
# Set SHELL to bash explicitly, so parallel knows which shell to use
export SHELL=$(which bash) 

echo "Starting parallel batch processing..."
# Run the intermediate merges in parallel
parallel --bar -j 4 run_cdo_batch_merge ::: input_batch_*

# ... (Rest of the script for the final merge and cleanup) ...

echo "Merging intermediate files into final output..."
cdo mergetime intermediate_*.nc final_output.nc

echo "Cleaning up..."
rm intermediate_*.nc input_batch_*

echo "Finished. Final output file: final_output.nc"
