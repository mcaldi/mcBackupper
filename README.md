# mcBackupper
Personal Local Backupper - still in BETA, to be used at your own risk
Bash script to backup your personal file or directory
## How to use
1) Popolate config file. Each Row is an folder/file to backup:
```
  PATH src|PATH destination|compression(use none or zip)|avoid_destination_delete (use true o false) work only with no compression
```
2) Change parameters in mcBackupper.sh:
```
CONFIG_FILE_PATH: config file path
LOG_DIR : logs directory
```

3) Launch:
```
  ./mcBackupper.sh
```
