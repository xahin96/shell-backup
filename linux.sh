#!/bin/bash

cbw_counter=0
ibw_counter=0
dbw_counter=0

username=$(whoami)
cbw_location="/home/$username/home/backup/cbw24"
ibw_location="/home/$username/home/backup/ib24"
dbw_location="/home/$username/home/backup/db24"
backup_log_loc="/home/$username/home/backup"
backup_dir="/home/$username/home"
target_directory="/home/$username/Desktop"

check_and_create_backup_log() {
    if [ ! -f "$backup_log_loc/backup.log" ]; then
        touch "$backup_log_loc/backup.log"
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

get_recently_modified_files() {
    local seconds="$1"

    # Step 1: Find valid files and directories in the global target directory
    local files=$(find "$target_directory" -type f -not -path "$backup_dir/*")

    if [ -z "$files" ]; then
        echo "No readable files found in $target_directory"
        return 1
    fi

    # Step 2: Extract modification times and filenames using stat
    local file_info=$(stat --format='%Y :%y %n' $files)

    # Step 3: Calculate the timestamp for N seconds ago
    local timestamp=$(date -d "now - $seconds seconds" +'%s')

    # Step 4: Filter files modified within the last N seconds
    local filtered_files=$(echo "$file_info" | awk -v d="$timestamp" '$1 >= d {print $NF}')

    # Step 5: Return the filtered files
    echo "$filtered_files"
}

sleep_after_backup(){
  sleep 10
}

# Main loop
while true; do
    ((cbw_counter++))

    # Get the current timestamp in the desired format
    current_time=$(date +"%a %d %b %Y %I:%M:%S %p %Z")

    # Check if cbw_location exists, if not create it
    check_and_create_cbw_location
    check_and_create_ibw_location
    check_and_create_dbw_location

    # Check if backup.log exists, if not create it
    check_and_create_backup_log

    # STEP 1
    # Create tar backup of target_directory in cbw_location
    if tar -cf "$cbw_location/cbw24-$cbw_counter.tar" "$target_directory"; then
        echo "$current_time cbw24-$cbw_counter.tar was created" >> "$backup_log_loc/backup.log"
    else
        echo "$current_time Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar" >> "$backup_log_loc/backup.log"
    fi

    sleep_after_backup

    # STEP 2
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(get_recently_modified_files "10")

    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> "$backup_log_loc/backup.log"
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> "$backup_log_loc/backup.log"
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> "$backup_log_loc/backup.log"
    fi

    sleep_after_backup

    # STEP 3
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(get_recently_modified_files "10")

    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> "$backup_log_loc/backup.log"
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> "$backup_log_loc/backup.log"
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> "$backup_log_loc/backup.log"
    fi

    sleep_after_backup

    # STEP 4
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(get_recently_modified_files "30")

    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((dbw_counter++))
        # Create tar backup of target_directory in dbw_location
        if echo "$file_list" | tar -cf "$dbw_location/dbw24-$dbw_counter.tar" -T -; then
            echo "$current_time dbw24-$dbw_counter.tar was created" >> "$backup_log_loc/backup.log"
        else
            echo "$current_time Error creating tar archive: $dbw_location/dbw24-$dbw_counter.tar" >> "$backup_log_loc/backup.log"
        fi
    else
        echo "$current_time No changes-differential backup was not created" >> "$backup_log_loc/backup.log"
    fi

    sleep_after_backup

    # STEP 5
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(get_recently_modified_files "10")

    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> "$backup_log_loc/backup.log"
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> "$backup_log_loc/backup.log"
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> "$backup_log_loc/backup.log"
    fi

done