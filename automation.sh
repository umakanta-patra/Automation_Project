#!/bin/bash

############################
#Problem Statement (Task 2)#
############################

#Update package details
echo "[INFO] Initiating package update process."
sudo apt update -y
echo "[INFO] Package update process completed."

#Initialize variables
myname="Umakanta"
s3_bucket="upgrad-umakanta"
timestamp=$(date '+%d%m%Y-%H%M%S')
log_type="httpd-logs"
tar_file_name="${myname}-${log_type}-${timestamp}.tar"
log_path="/var/log/apache2"
inventory_file_path="/var/www/html/inventory.html"
cron_job_file="/etc/cron.d/automation"

#Check if apache2 is installed.
installation_status=$(dpkg --get-selections | grep apache2 | wc -l)

if [ ${installation_status} -ge 1 ]
then
    echo "[INFO] apache2 is currently installed. Skipping installation process."
else
    echo "[INFO] apache2 package is not installed currently. Commencing installation..."
    sudo apt install apache2
    echo "[INFO] apache2 package has been installed."
fi

#Check if apache2 service is enabled. If disabled, enable the service.
is_service_enabled=$(systemctl is-enabled apache2)
if [ "${is_service_enabled}" == "enabled" ]
then
    echo "[INFO] apache2 service is currently enabled."
else
    echo "[INFO] apache2 service is not enabled currently."
    echo "[INFO] Enabling apache2 service..."
    sudo systemctl enable apache2 && echo "[INFO] apache2 service enabled."
fi

#Check if apache2 service is running. If not running, start the service.
current_status=$(service apache2 status | grep 'active (running)' | wc -l)

if [ ${current_status} -eq 1 ]
then
    echo "[INFO] apache2 service is currently running."
else
    echo "[INFO] apache2 service is not running currently."
    echo "[INFO] Starting apache2 service..."
    sudo systemctl start apache2 && echo "[INFO] apache2 service started."
fi

#Create tar archive & save it under /tmp
echo "[INFO] Initiating Tar archive process."
tar -cvf /tmp/${tar_file_name} ${log_path}/access.log ${log_path}/error.log && echo "[INFO] Tar archive ${tar_file_name} created under /tmp/ directory."

#Copy the tar archive from /tmp/ to S3 bucket
echo "[INFO] Initiating Tar archive upload to S3 Bucket."
aws s3 cp /tmp/${tar_file_name} s3://${s3_bucket}/${tar_file_name} && echo "[INFO] Tar archive /tmp/${tar_file_name} uploaded to s3://${s3_bucket}"

############################
#Problem Statement (Task 3)#
############################

#Check if /var/www/html/inventory.html exists. If not, create it.
if [ -f ${inventory_file_path} ]
then
    echo "${inventory_file_path} file exists."
else
    echo "[INFO] ${inventory_file_path} file does not exist."
    touch ${inventory_file_path} && echo "[INFO] ${inventory_file_path} created."
    chmod -v 755 ${inventory_file_path}
    echo -e "Log Type\tTime Created\tType\tSize" > ${inventory_file_path}
fi

if [ -f ${inventory_file_path} ] && [ ! -z ${inventory_file_path} ]
then
    size_of_archive_file=$(du -h /tmp/${tar_file_name} | tr -s "\t " | cut -f1)
    file_type=$(echo /tmp/${tar_file_name} | cut -d"." -f2)
    entry_to_be_added="${log_type}\t${timestamp}\t${file_type}\t${size_of_archive_file}"
    echo -e "${entry_to_be_added}" >> ${inventory_file_path} && echo "[INFO] Entry added to ${inventory_file_path}"
fi

#Create a cron job to schedule the this script on a daily basis.
cron_job="0 0 * * * root /root/Automation_Project/automation.sh"
cron_flag=0
if [ -f ${cron_job_file} ]
then
    cron_flag=$(grep -F "${cron_job}" ${cron_job_file} | wc -l)
fi

if [ ${cron_flag} -eq 0 ]
then
    echo "0 0 * * * root /root/Automation_Project/automation.sh" > ${cron_job_file} && echo "[INFO] Cronjob has been added."
    crontab ${cron_job_file}
else
    echo "[INFO] Daily Cronjob for /root/Automation_Project/automation.sh exists."
fi
