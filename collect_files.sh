#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Error: Missing arguments"
    echo "Example: $0 /input_folder /output_folder"
    exit 1
fi

input="$1"
output="$2"
max_depth=999
rename_files=1

if [ $# -ge 3 ] && [ "$3" == "--max_depth" ]; then
    if ! [[ "$4" =~ ^[0-9]+$ ]]; then
        echo "Error: Max depth must be a number"
        exit 1
    fi
    max_depth="$4"
    rename_files=0
fi

if [ ! -d "$input" ]; then
    echo "Error: Input folder not found!"
    exit 1
fi

mkdir -p "$output"

function copy_files {
    local current_dir="$1"
    local current_depth="$2"
    
    if [ $current_depth -gt $max_depth ]; then
        return
    fi
    
    for item in "$current_dir"/*; do
        if [ -f "$item" ]; then
            filename=$(basename "$item")
            
            if [ $rename_files -eq 1 ]; then
                counter=1
                base="${filename%.*}"
                ext="${filename##*.}"
                
                if [ "$base" == "$ext" ]; then
                    ext=""
                else
                    ext=".$ext"
                fi
                
                newfile="${base}${ext}"
                while [ -e "$output/$newfile" ]; do
                    newfile="${base}_${counter}${ext}"
                    counter=$((counter+1))
                done
                cp "$item" "$output/$newfile"
            else
                cp "$item" "$output/$filename"
            fi
            
        elif [ -d "$item" ]; then
            copy_files "$item" $((current_depth+1))
        fi
    done
}

copy_files "$input" 1

echo "Done! Files copied to $output"