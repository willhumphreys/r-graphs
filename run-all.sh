#!/usr/bin/env bash
set -e

# Hardcoded aggregated trades file
AGGREGATED_FILE="es-1mF/s_-3000..-100..400___l_100..7500..400___o_-800..800..100___d_14..14..7___out_8..8..4/aggregated-es-1mF_s_-3000..-100..400___l_100..7500..400___o_-800..800..100___d_14..14..7___out_8..8..4_aggregationQueryTemplate-all.csv.lzo"

# Define the R scripts to run
declare -a SCRIPTS=("src/bestTraders.r" "src/stops.r" "src/years.r")

# Run each script in sequence
for script in "${SCRIPTS[@]}"; do
    echo "========================================================"
    echo "Running ${script} with ${AGGREGATED_FILE}"
    echo "========================================================"

    # Call the original script with the aggregated file and the current R script
    ./runStopsRScript.sh "${AGGREGATED_FILE}" "${script}"

    echo "Completed ${script}"
    echo ""
done

echo "All scripts have been executed successfully."