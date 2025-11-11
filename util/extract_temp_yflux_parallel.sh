#!/bin/bash
# extract_temp_yflux_parallel.sh
# Parallel extraction of temp_yflux_adv using ncks with progress display

input_dir="/g/data/p73/archive/non-CMIP/ACCESS-ESM1-5/PI-GWL-B2060/history/ocn"
output_dir="/g/data/ob22/as8561/data/enso_trans_stable/sst_grad_res/oht_files/stable_2060"
var="temp_yflux_adv"
n_jobs=32   # number of parallel processes (tune for your system)

mkdir -p "$output_dir"

echo "Scanning for files in $input_dir ..."
files=(${input_dir}/ocean_month*)
total=${#files[@]}
echo "Found $total files. Starting parallel extraction of '$var' using $n_jobs jobs."
echo

# Export vars for GNU parallel
export var output_dir

# Run extraction in parallel
ls ${input_dir}/ocean_month* | parallel -j ${n_jobs} --bar '
    fname=$(basename {});
    out="${output_dir}/${fname}";
    if [ ! -f "$out" ]; then
        ncks -O -v "$var" {} "$out";
    fi
'

echo
echo "✅ DONE! Extracted '$var' from $total files into: $output_dir"