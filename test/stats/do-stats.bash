#!/bin/bash

# Clear csv, png leftovers of preceding run
# cut elapsed column from jtl, paste to single-column csv
# paste csv into paste.csv
# call stats

install_stats_packages() {
    pip install --user 'statsmodels==0.14.1' 'seaborn==0.12.2'
}

remove_leftovers() {
    rm -rf paste.csv anova.csv ks.csv desc.csv tukeyhsd.csv *.png
}

jtl_to_csv() {
    # https://stackoverflow.com/a/55817578
    # https://stackoverflow.com/a/48735405
    local JTL_FILES=$(find . -type f -name "*.jtl" | sed -e "s+^\./++g" | sort)
    # https://stackoverflow.com/a/1469863
    for jtl_file in ${JTL_FILES}; do
        filename=$(printf "${jtl_file}\n" | cut -d '.' -f1)
        printf "${filename}\n" >"${filename}".csv
        # https://unix.stackexchange.com/a/97072
        awk -F ',' '{ if ($4 == 200)  print }' ${jtl_file} | cut -d ',' -f2 >>${filename}.csv
        # https://stackoverflow.com/a/15400287
        # remove 'elapsed' word
        sed -i '2d' ${filename}.csv
    done
}

create_paste_csv() {
    local CSV_FILES=$(find . -type f -name "*.csv" | sed -e "s+^\./++g" | sort)
    local MIN=$(echo "2^63-1" | bc -lq)
    for csv_file in ${CSV_FILES}; do
        local LINES_COUNT=$(cat ${csv_file} | wc -l)
        if [[ ${LINES_COUNT} -lt ${MIN} ]]; then
            MIN=${LINES_COUNT}
        fi
    done
    paste -d ',' *.csv >paste-raw.csv
    head -n ${MIN} paste-raw.csv >paste.csv
    rm -rf paste-raw.csv

}

closure() {
    # https://stackoverflow.com/a/1482133
    local _SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$0")")
    cd ${_SCRIPT_DIR}
    remove_leftovers
    jtl_to_csv
    create_paste_csv
    install_stats_packages
    python statistics.py
}

# Main procedure
closure
