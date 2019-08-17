#!/bin/bash

###################COMMON SHELL FUNCTIONS#################
function funcSetupApache()
{
	sudo yum -y install httpd mod_ssl
	sudo /usr/sbin/apachectl start
	sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
	sudo service iptables save

}

function logging()
{
	touch logs_apache
	echo "Completed" >> logs_apache

}

##################END FUNCTIONS RELATED######################

######################MAIN PROCEDURE##########################

# configure OS, install basic utilities like wget curl mount .etc

funcSetupApache
logging

###################END OF MAIN PROCEDURE##################
