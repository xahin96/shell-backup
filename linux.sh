#!/bin/bash

cbw_counter=0
ibw_counter=0
dbw_counter=0
username=$(whoami)
cbw_location="/home/$username/backup/cbw24"
ibw_location="/home/$username/backup/ib24"
dbw_location="/home/$username/backup/db24"
target_directory="/home/rahman8j/Desktop/ASP/assignment4"
previous_checksum=""

# Function to calculate checksum of the target directory
calculate_checksum() {
  find "$target_directory" -type f -exec md5sum {} + | md5sum | cut -d' ' -f1
}

# Main loop
while true; do
  ((cbw_counter++))
  ((ibw_counter++))
  ((dbw_counter++))

  # Check if backup.log exists, if not create it
  if [ ! -f "backup.log" ]; then
    touch backup.log
    echo "Created backup.log"
  fi

  # Get the current timestamp in the desired format
  current_time=$(date +"%a %d %b %Y %I:%M:%S %p %Z")

  # Check if cbw_location exists, if not create it
  if [ ! -d "$cbw_location" ]; then
    if mkdir -p "$cbw_location"; then
      echo "Created directory: $cbw_location"
    else
      echo "Error: Failed to create directory: $cbw_location"
      exit 1
    fi
  fi

  # Calculate checksum of the current target directory
  current_checksum=$(calculate_checksum)

  # Compare checksums to check for changes
  if [ "$current_checksum" != "$previous_checksum" ]; then
    # Create tar backup of target_directory in cbw_location
    if tar -cf "$cbw_location/cbw24-$cbw_counter.tar" "$target_directory"; then
      echo "Tar archive created successfully: $cbw_location/cbw24-$cbw_counter.tar"
    else
      echo "Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar"
    fi

    # Update previous_checksum to the current checksum
    previous_checksum="$current_checksum"
  else
    echo "No changes detected. Skipping tar creation."
  fi

  # Output the current timestamp to backup.log
  echo "$current_time" >> backup.log

  # Sleep for 10 seconds before starting again
  sleep 10
done