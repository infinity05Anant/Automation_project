#!/bin/bash

name="Anant"
s3_bucket="upgrad-anant"


apt update -y


if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]]; then
	#statements
	apt install apache2 -y
fi


running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; then
	#statements
	systemctl start apache2
fi

 
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
	#statements
	systemctl enable apache2
fi

timestamp=$(date '+%d%m%Y-%H%M%S')


cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log


if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]; then
	#statements
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi

docroot="/var/www/html"

if [[ ! -f ${docroot}/inventory.html ]]; then
	#statements
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docroot}/inventory.html
fi


if [[ -f ${docroot}/inventory.html ]]; then
	#statements
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${docroot}/inventory.html
fi


if [[ ! -f /etc/cron.d/automation ]]; then
	#statements
	echo "* * * * * root /root/automation.sh" >> /etc/cron.d/automation
fi