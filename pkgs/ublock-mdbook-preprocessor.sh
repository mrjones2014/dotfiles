#!/usr/bin/env bash

set -euo pipefail

# This script replaces the Rust ublock-mdbook preprocessor
# It can run in two modes:
# 1. As an mdbook preprocessor (default) - reads JSON from stdin, processes book, writes JSON to stdout
# 2. As a filter list generator (gen-filter-list command) - generates ublock-filters.txt

YAML_FILE="${UBLOCK_FILTERS_YAML:-"${0%/*}/../docs/src/ublock-filters.yml"}"

# Function to parse YAML and generate the three outputs needed
parse_ublock_filters() {
    local yaml_file="$1"
    local temp_dir=$(mktemp -d)
    
    # Get the number of items in the array
    local count=$(yq eval 'length' "$yaml_file")
    
    local filters_all=""
    local filters_toc=""
    local filters_sections=""
    
    for ((i=0; i<count; i++)); do
        # Get the site name (first key of the object)
        local site_name=$(yq eval ".[$i] | keys | .[0]" "$yaml_file")
        # Get the filters text for this site - properly quote it
        local filters_text=$(yq eval ".[$i][\"$site_name\"]" "$yaml_file")
        
        # Generate TOC entry (convert site name to markdown anchor)
        local anchor=$(echo "$site_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
        filters_toc+="- [$site_name](#$anchor)"$'\n'
        
        # Generate individual section using printf to avoid substitution issues
        filters_sections+=$(printf '\n## %s\n\n```adblock\n%s\n```\n' "$site_name" "$filters_text")
        
        # Generate entry for "all" filters with comment header
        local padding_needed=$((36 - ${#site_name}))
        local padding=""
        if [ $padding_needed -gt 0 ]; then
            padding=$(printf "%*s" $padding_needed "")
        fi
        
        filters_all+=$(printf '\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n!! %s%s!!\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n%s\n\n' "$site_name" "$padding" "$filters_text")
    done
    
    # Trim leading newlines from filters_all
    filters_all=$(echo "$filters_all" | sed '/./,$!d')
    
    # Add final newline to TOC
    filters_toc+=$'\n'
    
    # Save the results to temp files
    printf '%s' "$filters_all" > "$temp_dir/all"
    printf '%s' "$filters_toc" > "$temp_dir/toc"
    printf '%s' "$filters_sections" > "$temp_dir/sections"
    
    echo "$temp_dir"
}

# Function to handle mdbook preprocessor protocol
handle_preprocessor() {
    local yaml_file="$1"
    
    # Read the entire JSON input
    local input=$(cat)
    
    # Parse the input to extract the book content
    local temp_dir=$(parse_ublock_filters "$yaml_file")
    
    local filters_all=$(cat "$temp_dir/all")
    local filters_toc=$(cat "$temp_dir/toc")
    local filters_sections=$(cat "$temp_dir/sections")
    
    # Process the JSON and replace template tags
    local processed_input=$(echo "$input" | jq --arg filters_all "$filters_all" --arg filters_toc "$filters_toc" --arg filters_sections "$filters_sections" '
        def process_item:
            if type == "object" and has("Chapter") then
                .Chapter.content = (.Chapter.content
                | gsub("{{#ublockfilters-all}}"; "```adblock\n" + $filters_all + "\n```")
                | gsub("{{#ublockfilters-toc}}"; $filters_toc)
                | gsub("{{#ublockfilters}}"; $filters_sections))
            else
                .
            end;
        
        if type == "object" and has("sections") then
            .sections = [.sections[] | process_item]
        else
            walk(process_item)
        end
    ')
    
    # Clean up temp files
    rm -rf "$temp_dir"
    
    echo "$processed_input"
}

# Function to generate filter list file
generate_filter_list() {
    local yaml_file="$1"
    local output_path="$2"
    
    local temp_dir=$(parse_ublock_filters "$yaml_file")
    local filters_all=$(cat "$temp_dir/all")
    
    printf '%s' "$filters_all" > "$output_path"
    
    # Clean up temp files
    rm -rf "$temp_dir"
}

# Main logic
case "${1:-}" in
    "supports")
        # For mdbook preprocessor support check
        # We support all renderers
        exit 0
        ;;
    "gen-filter-list")
        if [ $# -lt 2 ]; then
            echo "Usage: $0 gen-filter-list <output-path>" >&2
            exit 1
        fi
        generate_filter_list "$YAML_FILE" "$2"
        ;;
    *)
        # Default: run as preprocessor
        handle_preprocessor "$YAML_FILE"
        ;;
esac