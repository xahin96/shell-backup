#!/bin/bash

#---------------------------------------------------- Variable Declaration ----------------------------------------------------
cbw_counter=0
ibw_counter=0
dbw_counter=0


#---------------------------------------------------- File path Declaration ----------------------------------------------------
username=$(whoami)
cbw_location="/home/$username/backup/cbw24"
ibw_location="/home/$username/backup/ib24"
dbw_location="/home/$username/backup/db24"
target_directory="/home/$username/Desktop/ASP/assignment5/a"
previous_checksum=""


#---------------------------------------------------- calculate_checksum ----------------------------------------------------
# Function to calculate checksum of the target directory
calculate_checksum() {
    find "$target_directory" -type f -exec md5sum {} + | md5sum | cut -d' ' -f1
}

check_and_create_backup_log() {
    if [ ! -f "backup.log" ]; then
        touch backup.log
        echo "Created backup.log"
    fi
}

check_and_create_cbw_location() {
    if [ ! -d "$cbw_location" ]; then
        if mkdir -p "$cbw_location"; then
            echo "Created directory: $cbw_location"
        else
            echo "Error: Failed to create directory: $cbw_location"
            exit 1
        fi
    fi
}

check_and_create_ibw_location() {
    if [ ! -d "$ibw_location" ]; then
        if mkdir -p "$ibw_location"; then
            echo "Created directory: $ibw_location"
        else
            echo "Error: Failed to create directory: $ibw_location"
            exit 1
        fi
    fi
}

check_and_create_dbw_location() {
    if [ ! -d "$dbw_location" ]; then
        if mkdir -p "$dbw_location"; then
            echo "Created directory: $dbw_location"
        else
            echo "Error: Failed to create directory: $dbw_location"
            exit 1
        fi
    fi
}

# Main loop
while true; do
#---------------------------------------------------- counter increment ----------------------------------------------------
    ((cbw_counter++))
    ((ibw_counter++))
    ((dbw_counter++))


    # Check if backup.log exists, if not create it
    check_and_create_backup_log

    # Get the current timestamp in the desired format
    current_time=$(date +"%a %d %b %Y %I:%M:%S %p %Z")

    # Check if cbw_location exists, if not create it
    check_and_create_cbw_location
    check_and_create_ibw_location
    check_and_create_dbw_location

    # STEP 1
    # Create tar backup of target_directory in cbw_location
    if tar -cf "$cbw_location/cbw24-$cbw_counter.tar" "$target_directory"; then
        echo "Tar archive created successfully: $cbw_location/cbw24-$cbw_counter.tar"
        echo "$current_time " >> backup.log
    else
        echo "Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar"
    fi


    sleep 20

    # STEP 2
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(find "$target_directory" -type f -exec stat --format '%Y :%y %n' {} \; | \
        awk -v d="$(date -d 'now - 20 seconds' +'%s')" '$1 >= d {print $NF}')
    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        # Create tar backup of target_directory in cbw_location
        if echo "$file_list" | tar -cf "$cbw_location/cbw24-$cbw_counter.tar" -T -; then
            echo "Tar archive created successfully: $cbw_location/cbw24-$cbw_counter.tar"
            echo "$current_time " >> backup.log
        else
            echo "Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar"
        fi
    else
        echo "No changes detected. Skipping tar creation."
        echo "$current_time No changes-Incremental backup was not created" >> backup.log
    fi
done