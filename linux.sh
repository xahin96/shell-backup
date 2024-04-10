#!/bin/bash

# complete backup counter
cbw_counter=0
# incremental backup counter
ibw_counter=0
# differential backup counter
dbw_counter=0

# retreiving username
username=$(whoami)
# complete backup folder location
cbw_location="/home/$username/home/backup/cbw24"
# incremental backup folder location
ibw_location="/home/$username/home/backup/ib24"
# differential backup folder location
dbw_location="/home/$username/home/backup/db24"
# backup log file folder location
backup_log_loc="/home/$username/home/backup"
# backup parent folder location
backup_dir="/home/$username/home"
# target backup folder location
target_directory="/home/$username/Desktop/ASP"

# check and create backup log if not found
check_and_create_backup_log() {
    # checking if it's a regular file or not
    if [ ! -f "$backup_log_loc/backup.log" ]; then
        touch "$backup_log_loc/backup.log"
    fi
}

# check and create complete backup folders
check_and_create_cbw_location() {
    # checking if valid directory or not
    if [ ! -d "$cbw_location" ]; then
        # if does not exist, creating the folder
        if mkdir -p "$cbw_location"; then
            echo "Created directory: $cbw_location"
        else
            echo "Error: Failed to create directory: $cbw_location"
            exit 1
        fi
    fi
}

# check and create complete backup folders
check_and_create_ibw_location() {
    # checking if valid directory or not
    if [ ! -d "$ibw_location" ]; then
        # if does not exist, creating the folder
        if mkdir -p "$ibw_location"; then
            echo "Created directory: $ibw_location"
        else
            echo "Error: Failed to create directory: $ibw_location"
            exit 1
        fi
    fi
}

# check and create complete backup folders
check_and_create_dbw_location() {
    # checking if valid directory or not
    if [ ! -d "$dbw_location" ]; then
        # if does not exist, creating the folder
        if mkdir -p "$dbw_location"; then
            echo "Created directory: $dbw_location"
        else
            echo "Error: Failed to create directory: $dbw_location"
            exit 1
        fi
    fi
}

# method for searching all tge file that was updated specific time
# duration ago
get_recently_modified_files() {
    # receiving the second passed for checking
    local seconds="$1"

    # Step 1: Finding files and directories in the target directory while skipping
    # the backup directory as it will change regularly but no need for considering
    # as a folder that requires backup
    local files=$(find "$target_directory" -type f -not -path "$backup_dir/*")

    # checking is file list is not zero
    if [ -z "$files" ]; then
        echo "No readable files found in $target_directory"
        return 1
    fi

    # Step 2: Extracting modification times and filenames using stat command
    local file_info=$(stat --format='%Y :%y %n' $files)

    # Step 3: Calculating the timestamp for specific seconds ago
    local timestamp=$(date -d "now - $seconds seconds" +'%s')

    # Step 4: Filtering files modified within specific time
    local filtered_files=$(echo "$file_info" | awk -v d="$timestamp" '$1 >= d {print $NF}')

    # Step 5: Returning the file list
    echo "$filtered_files"
}

# sleep utility method
sleep_after_backup(){
  sleep 10
}

# Main loop
while true; do
    # incrementing complete backup counter everytime
    ((cbw_counter++))

    current_time=$(date +"%a %d %b %Y %I:%M:%S %p %Z")

    # Check if the backup files exist or not. If not creating it
    check_and_create_cbw_location
    check_and_create_ibw_location
    check_and_create_dbw_location

    # Check for backup.logs existance
    check_and_create_backup_log

    # STEP 1
    # Creating tar backup of target_directory in cbw_location
    if tar -cf "$cbw_location/cbw24-$cbw_counter.tar" "$target_directory"; then
        echo "$current_time cbw24-$cbw_counter.tar was created" >> "$backup_log_loc/backup.log"
    else
        echo "$current_time Error creating tar archive: $cbw_location/cbw24-$cbw_counter.tar" >> "$backup_log_loc/backup.log"
    fi

    sleep_after_backup

    # STEP 2
    # Listing all the files that has been changed within past 2 minutes
    file_list=$(get_recently_modified_files "10")

    # checking if any file was found or not that was changed withtin last 2 minutes
    # after taking the complete backup
    if [ -n "$file_list" ]; then
        # incrementing the incremental backup counter if found
        ((ibw_counter++))
        # Creating tar backup of target_directory in ibw_location
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

    # checking if any file was found or not that was changed withtin last 2 minutes
    # after taking the complete backup
    if [ -n "$file_list" ]; then
        # incrementing the incremental backup counter if found
        ((ibw_counter++))
        # Creating tar backup of target_directory in ibw_location
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
    # Listing all the files that has been changed within past 6 minutes
    file_list=$(get_recently_modified_files "30")

    # checking if any file was found or not that was changed withtin last 2 minutes
    # after taking the complete backup
    if [ -n "$file_list" ]; then
        # incrementing the differential backup counter if found
        ((dbw_counter++))
        # Creating tar backup of target_directory in ibw_location
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

    # checking if any file was found or not that was changed withtin last 2 minutes
    # after taking the complete backup
    if [ -n "$file_list" ]; then
        # incrementing the incremental backup counter if found
        ((ibw_counter++))
        # Creating tar backup of target_directory in ibw_location
        if echo "$file_list" | tar -cf "$ibw_location/ibw24-$ibw_counter.tar" -T -; then
            echo "$current_time ibw24-$ibw_counter.tar was created" >> "$backup_log_loc/backup.log"
        else
            echo "$current_time Error creating tar archive: $ibw_location/ibw24-$ibw_counter.tar" >> "$backup_log_loc/backup.log"
        fi
    else
        echo "$current_time No changes-Incremental backup was not created" >> "$backup_log_loc/backup.log"
    fi

done