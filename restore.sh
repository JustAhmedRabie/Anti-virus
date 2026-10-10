#!/bin/bash

# restore tool
# usage: ./restore.sh dir malicious_dir

if [ $# -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

dir=$1
malicious_dir=$2

while true; do
    # gather the list of files in malicious_dir
    files=$(ls "$malicious_dir" 2>/dev/null)

    if [ -z "$files" ]; then
        echo "No malicious files to review."
        exit 0
    fi

    echo "Files in quarantine:"
    i=1
    for f in $files; do
        echo "$i) $f"
        i=$((i + 1))
    done

    read -p "Pick a file by number (0 to exit): " choice

    if [ "$choice" = "0" ]; then
        exit 0
    fi

    # get the selected file name
    selected=$(echo "$files" | sed -n "${choice}p")

    if [ -z "$selected" ]; then
        echo "Invalid choice."
        continue
    fi

    echo "1) Restore (false positive)"
    echo "2) Permanently delete (genuinely malicious)"
    echo "3) Leave it and go back"
    read -p "Option: " option

    if [ "$option" = "1" ]; then
        cp "$malicious_dir/$selected" "$dir/$selected"
        rm "$malicious_dir/$selected"
        echo "$selected" >> whitelist.txt
        echo "Restored $selected to $dir."
    elif [ "$option" = "2" ]; then
        rm "$malicious_dir/$selected"
        echo "$selected permanently deleted."
    elif [ "$option" = "3" ]; then
        echo "Skipped."
    else
        echo "Invalid option."
    fi
done
