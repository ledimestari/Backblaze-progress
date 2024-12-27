#!/bin/bash

while true; do

# Define the file paths
# These are likely to be found at C:\ProgramData\Backblaze\bzdata 
total_file_path="/path/to/file/bzstat_totalbackup.xml"
remaining_file_path="/path/to/file/bzstat_remainingbackup.xml"
bzinfo_file_path="/path/to/file/bzinfo.xml"

# Define influxDB credentials
influx_uri=""     # example http://192.168.1.131:8763/api/v2/write?org=MY_ORG&bucket=MY_BUCKET&precision=s
influx_token=""   # example Z9m_TqBY8k2Dexamplex8vVP7CFQ_-UTqp5Krb2_7UKwy13YrjTtx29FcPRxRhoMwb3q2Udw1gQ3bHyi3gnvcy==

# Get drive Guid list
guid_list=$(cat $total_file_path | grep bzVolumeGuid | cut -d \" -f2 | sort)
echo "$guid_list"

# Process stats drive by drive
while IFS= read -r guid; do
    echo "Drive: $guid"
    drive_letter=$(cat $bzinfo_file_path | grep bzVolumeGuid | grep $guid | cut -d \" -f4 | cut -d: -f1)
    echo "  Drive letter: $drive_letter"
    
    # Get drive statistics
    selected_files=$(cat $total_file_path | grep $guid | cut -d = -f3 | tr -d -c 0-9)
    selected_b=$(cat $total_file_path | grep $guid | cut -d = -f4 | tr -d -c 0-9)
    remaining_files=$(cat $remaining_file_path | grep $guid | cut -d = -f3 | tr -d -c 0-9)
    remaining_b=$(cat $remaining_file_path | grep $guid | cut -d = -f4 | tr -d -c 0-9)

    # Convert bytes to MB (1 MB = 1024 * 1024 bytes)
    # Decided to do this for similarity with backblaze UI, which also talks in MB
    selected_MB=$(echo "$selected_b / (1024 * 1024)" | bc)
    remaining_MB=$(echo "$remaining_b / (1024 * 1024)" | bc)

    echo "  Selected files:  $selected_files"
    echo "  Selected MB:     $selected_MB"
    echo "  Remaining files: $remaining_files"
    echo "  Remaining MB:    $remaining_MB"

    timestamp=$(date +%s)

    # Post to influxdb
    curl --request POST \
    "$influx_uri" \
      --header "Authorization: Token $influx_token" \
      --header "Content-Type: text/plain; charset=utf-8" \
      --header "Accept: application/json" \
      --data-binary "drives,sensor_id=DRIVE_$drive_letter selected_files=$selected_files,selected_MB=$selected_MB,remaining_files=$remaining_files,remaining_MB=$remaining_MB $timestamp"

    # Optional sleep between drives
    #sleep 1

done <<< "$guid_list"

# Totals
selected_files=$(cat $total_file_path | grep totnumfilesforbackup= | cut -d = -f2 | tr -d -c 0-9)
selected_b=$(cat $total_file_path | grep totnumfilesforbackup= | cut -d = -f3 | tr -d -c 0-9)
remaining_files=$(cat $remaining_file_path | grep remainingnumfilesforbackup= | cut -d = -f2 | tr -d -c 0-9)
remaining_b=$(cat $remaining_file_path | grep remainingnumfilesforbackup= | cut -d = -f3 | tr -d -c 0-9)

# Convert bytes to MB (1 MB = 1024 * 1024 bytes)
selected_MB=$(echo "$selected_b / (1024 * 1024)" | bc)
remaining_MB=$(echo "$remaining_b / (1024 * 1024)" | bc)

echo "---- Totals ----"
echo "Selected files: $selected_files"
echo "Selected MB: $selected_MB"
echo "Remaining files: $remaining_files"
echo "Remaining MB: $remaining_MB"

timestamp=$(date +%s)

# Post to influxdb
curl --request POST \
"$influx_uri" \
  --header "Authorization: Token $influx_token" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "backblaze,sensor_id=backblaze_ui selected_files=$selected_files,selected_MB=$selected_MB,remaining_files=$remaining_files,remaining_MB=$remaining_MB $timestamp"

# An optional extra step to save the progress percentage into a text file, to be easily parsed for some other use
output_file="bb_percentage.txt"

if [ "$selected_MB" -ne 0 ]; then
  # Calculate progress using bc with higher precision
  progress=$(echo "scale=4; (($selected_MB - $remaining_MB) / $selected_MB) * 100" | bc)
  # Use printf to format the result to exactly 2 decimal places
  progress=$(printf "%.2f" "$progress")
  # Save the progress to a text file
  echo "$progress" > "$output_file"
  echo "Progress saved to $output_file"
else
  echo "Error: selected_MB cannot be zero." > "$output_file"
  echo "Error: selected_MB cannot be zero."
fi
# End of the optional part

sleep 60

done
