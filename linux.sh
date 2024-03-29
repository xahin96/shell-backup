#!/bin/bash

cbw_counter=0
ibw_counter=0
dbw_counter=0

username=$(whoami)
cbw_location="/home/$username/backup/cbw24"
ibw_location="/home/$username/backup/ib24"
dbw_location="/home/$username/backup/db24"
target_directory="/home/$username/Desktop/ASP/assignment5/a"
previous_checksum=""

check_and_create_backup_log() {
    if [ ! -f "backup.log" ]; then
        touch backup.log
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
    ((cbw_counter++))

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
        echo "$current_time cbw24-$cbw_counter.tar was created" >> backup.log
    else
        echo "$current_time Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar" >> backup.log
    fi

    sleep 120

    # STEP 2
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(find "$target_directory" -type f -exec stat --format '%Y :%y %n' {} \; | \
        awk -v d="$(date -d 'now - 2 minutes' +'%s')" '$1 >= d {print $NF}')
    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> backup.log
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> backup.log
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> backup.log
    fi

    sleep 120

    # STEP 3
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(find "$target_directory" -type f -exec stat --format '%Y :%y %n' {} \; | \
        awk -v d="$(date -d 'now - 2 minutes' +'%s')" '$1 >= d {print $NF}')
    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> backup.log
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> backup.log
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> backup.log
    fi

    sleep 120

    # STEP 4
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(find "$target_directory" -type f -exec stat --format '%Y :%y %n' {} \; | \
        awk -v d="$(date -d 'now - 6 minutes' +'%s')" '$1 >= d {print $NF}')
    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((dbw_counter++))
        # Create tar backup of target_directory in dbw_location
        if echo "$file_list" | tar -cf "$dbw_location/dbw24-$dbw_counter.tar" -T -; then
            echo "$current_time dbw24-$dbw_counter.tar was created" >> backup.log
        else
            echo "$current_time Error creating tar archive: $dbw_location/dbw24-$dbw_counter.tar" >> backup.log
        fi
    else
        echo "$current_time No changes-differential backup was not created" >> backup.log
    fi

    sleep 120

    # STEP 5
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(find "$target_directory" -type f -exec stat --format '%Y :%y %n' {} \; | \
        awk -v d="$(date -d 'now - 2 minutes' +'%s')" '$1 >= d {print $NF}')
    # Compare checksums to check for changes
    if [ -n "$file_list" ]; then
        ((ibw_counter++))
        # Create tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> backup.log
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> backup.log
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> backup.log
    fi

done