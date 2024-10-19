#!/usr/bin/env bash

# URL to crawl
URL="https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/"

# Temporary file to store the HTML content
TEMP_FILE="/tmp/trash_guides_temp.html"

# Output file for the results
OUTPUT_DIR="${HOME}/trash_guides"
OUTPUT_FILE="${OUTPUT_DIR}/sonarr_custom_formats.txt"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Download the webpage
curl -s "$URL" \
	-H "User-Agent: TrashGuidesCustomFormatExtractor/1.0" \
	-H "From: ${USER_EMAIL}" \
	>"$TEMP_FILE"

# Extract and process JSON blocks
# Thanks to Claude, since I'm bad at shell scripting and regex
awk '
    /^```json/ {flag=1; next}
    /^```/ {flag=0; next}
    flag {print}
' "$TEMP_FILE" | jq -r '. | select(.trash_id != null) | "\(.trash_id),\(.name)"' >"$OUTPUT_FILE"

# Clean up
rm "$TEMP_FILE"

echo "Extraction complete. Results saved in $OUTPUT_FILE"
