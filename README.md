# Course Assignment - C1 DevOps Essentials - Automation Project

## Overview
This repository hold the automation.sh script which will be used for automation of multiple tasks as mentioned below.

### Problem Statement (Task 2)
1. Check if Apache Web Server (apache2) is installed. If not installed, install the same.
2. Check is apache2 service is running. If not running, start the service
3. Check if apache2 service enabled in case of EC2 instance reboot & then enable the service.
4. Tar archive the access logs & error logs to /tmp/ directory and then upload the file to S3 Bucket.

### Problem Statement (Task 3)
1. Automate bookkeeping for each log archival & archive file upload to S3 Bucket.
2. Install a cron job to automate the script execution as per daily schedule.
