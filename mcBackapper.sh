#!/bin/bash

# mcBackupper - BETA
# Author: mcaldi - info@marcocaldirola.it
# Version: 0.0.1-Beta
# License: GPL-3.0 license 

pushd ./

# >>>>> Parameters to change <<<<<

# @@@ Config file @@@ - Backup config file: this file contains folders to backup
CONFIG_FILE_PATH="/home/mcBackupper/mcBackapper.conf"
# @@@ Log directory @@@ - if EMPTY logs disabled
LOG_DIR="/home/mcBackupper/log/"
# >>>>> END Parameters to change <<<<<

if [ ! -z "$LOG_DIR" ]; then
	LOG_FILE=${LOG_DIR}backupper_log_$(date +"%Y_%m_%d_%H_%M").log
	echo "using log file: $LOG_FILE"
	touch ${LOG_FILE}
	echo > ${LOG_FILE}
else
	LOG_FILE="/dev/null"
	echo "log disabled"
fi

while IFS= read -r line; do

	#skip comments '#' at begin of the line
	if [[ $line == \#* ]]; then
		echo "commented line: $line ... SKIPPED" 
		continue
	fi
	
	#skip empty line
	if [ -z "$line" ]
	then
		echo "$line is empty ... SKIPPED"
		continue
	fi
	
	from_path=`cut -d '|' -f1 <<< $line`
	to_path=`cut -d '|' -f2 <<< $line`
	compression=`cut -d '|' -f3 <<< $line`
	avoid_delete=`cut -d '|' -f4 <<< $line`
	
	#file_directory=`cut -d '|' -f5 <<< $line`
	
	# Source Path checks
	# Check if source path exist
	#src_directory_name =""
	#src_file_name =""
	if [ -e "$from_path" ]; then
		if [ -d "$from_path" ]; then
			echo "the source DIRECTORY exists!"
			file_directory="D"
			# last char must be slash
			if  [[ "$from_path" != */ ]]; then
				from_path="${from_path}/"
			fi
			#src_directory_name = $from_path
  		else 
  			echo "the source FILE exists!"
			file_directory="F"
			#src_directory_name = "$(dirname "${from_path}")"
			#src_file_name = "$(basename "${from_path}")"
  		fi
	else
  		echo "ERROR - Source File or directory does not exist... $line ... SKIPPED" | tee -a "${LOG_FILE}" 
  		continue
	fi

#	echo "FROM_PATH: $from_path - TO:PATH: $to_path - compression: $compression - avoid_delete: $avoid_delete"

	#Destination Path checks: only directory accepped
	if [[ "$to_path" != */ ]]; then
		to_path="${to_path}/"
	fi
	
	if [ -d "$to_path" ]; then
		echo "the destination DIRECTORY exists!"
	else
		mkdir -p "$to_path"
		echo "the destination DIRECTORY : $to_path created"
	fi

	# Backup
	if  [[ "$compression" == none ]]; then
		# no compression
		opts=" "
		if [[ "$avoid_delete" != "true" ]]; then
			opts=" --delete "
		fi

		echo rsync -s -avzPth $opts "$from_path" "$to_path"
		rsync -avzPth -s $opts "$from_path" "$to_path" | tee -a "${LOG_FILE}"
		
	else
		# compression
		# parent directory
		src_parent_folder="$(dirname "${from_path}")"
		# last folder or file
		src_name="$(basename "${from_path}")"

		#using same name of source file or last directory name
		zip_filename="${src_name}.zip"

		pushd ./

		cd "$src_parent_folder"

		echo zip -r "$to_path""$zip_filename" ./$src_name
		zip -r "$to_path""$zip_filename" ./$src_name | tee -a "${LOG_FILE}"
	
		popd
	
	fi
  
done < "$CONFIG_FILE_PATH"


echo "Buckup done at `date`" | tee -a "${LOG_FILE}"
popd

