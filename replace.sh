#!/bin/bash

usage() {
    echo "Usage: $0 <directory> <search_string> <replace_string> [-d]"
    echo "  -d : Delete backup files (only applies on macOS/BSD sed)"
    exit 1
}

if [[ $# -lt 3 ]]; then
    usage
fi

DIR=$1
SEARCH=$2
REPLACE=$3
shift 3

DELETE_BACKUP=false

while getopts "d" opt; do
    case ${opt} in
        d) DELETE_BACKUP=true ;;
        *) usage ;;
    esac
done

# Find and replace in all files
find "$DIR" -type f | while IFS= read -r file; do
    sed -i.bak "s/${SEARCH}/${REPLACE}/g" "$file"
done

if [[ "$DELETE_BACKUP" == true ]]; then
    find "$DIR" -type f -name "*.bak" -delete
fi

echo "Replacement complete."

