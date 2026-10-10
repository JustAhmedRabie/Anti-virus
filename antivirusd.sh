#!/bin/bash

# simple antivirus daemon
# usage: ./antivirusd.sh dir malicious_dir interval_secs

if [ $# -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval_secs"
    exit 1
fi

dir=$1
malicious_dir=$2
interval=$3

# make sure the folders exist
mkdir -p "$dir"
mkdir -p "$malicious_dir"

# flagged extensions and keywords (hardcoded)
extensions="exe bat vbs scr ps1"
keywords="virus trojan malware worm ransomware"

# this function checks one file and returns 0 if malicious, 1 if not
check_file() {
    file=$1
    name=$(basename "$file")

    # check whitelist first
    if [ -f whitelist.txt ]; then
        if grep -q "^$name$" whitelist.txt; then
            return 1
        fi
    fi

    # check the extension
    if [ "${name##*.}" != "$name" ]; then
        ext="${name##*.}"
        for e in $extensions; do
            if [ "$ext" = "$e" ]; then
                return 0
            fi
        done
    fi

    # check the content
    for k in $keywords; do
        if grep -qi "$k" "$file"; then
            return 0
        fi
    done

    return 1
}

# this function scans every file in dir
scan_dir() {
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            if check_file "$file"; then
                name=$(basename "$file")
                echo "$name is malicious and it is DELETED"
                cp "$file" "$malicious_dir/$name"
                rm "$file"
            fi
        fi
    done
}

# first time running: no directory-info.last yet, so scan now
if [ ! -f directory-info.last ]; then
    scan_dir
    ls -l "$dir" > directory-info.last
fi

# then keep checking every interval
while true; do
    sleep "$interval"
    ls -l "$dir" > directory-info.new

    # if the two listings are different, something changed
    if ! diff -q directory-info.last directory-info.new > /dev/null; then
        scan_dir
        cp directory-info.new directory-info.last
    fi
done
