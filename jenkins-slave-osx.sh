#!/bin/bash
set -e

VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 [--option]

DESCRIPTION:
    This script installs and manages a Jenkins slave on OSX. The slave runs as a daemon by the current user and will automatically launch on startup.

    --install    Install Jenkins slave for the current user
    --remove     Uninstall the Jenkins slave
    --start      Start the daemon
    --stop       Stop the daemon

    NOTE: This script is depend on Java Development Kit. So you must install JDK first.

AUTHOR:
    Arthur Krupa<arthur.krupa@gmail.com>

LICENSE:
    This script is licensed under the terms of the MIT license.

EXAMPLE:
    $0 -install
EOF
}

success() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}SUCCESS${normal}] $1"
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

getJenkinsNodeName() {
	echo -n "1. Enter Jenkins node name: "
	read JENKINS_NODE_NAME
	
	if [ "$JENKINS_NODE_NAME" == "" ]; then
		error "node name not specified"
		exit -1
	fi
}

getJenkinsUrl() {
	echo -n "2. Enter Jenkins URL (without proxy): "
	read JENKINS_URL_NOPROXY
	
	if [ "$JENKINS_URL_NOPROXY" == "" ]; then
		error "URL not specified"
		exit -1
	fi
}

getJenkinsSecret() {
	echo -n "3. Enter Jenkins secret: "
	read JENKINS_SECRET
	
	if [ "$JENKINS_SECRET" == "" ]; then
		echo "secret not specified"
		exit -1
	fi
}

startJenkinsSlave() {
	sudo -i launchctl load -w /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	success "Jenkins slave deamon started"
	exit 1
}

stopJenkinsSlave() {
	sudo -i launchctl unload /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	success "Jenkins slave deamon stopped"
	exit 1
}

# Jenkins settings
JENKINS_URL_NOPROXY=''
JENKINS_NODE_NAME=''
JENKINS_SECRET=''

# Local variables
OSX_USER=$USER
OSX_JENKINS_DIR=/Users/$OSX_USER/Jenkins
OSX_JENKINS_PROCESS=com.jenkins.slave
OSX_JENKINS_PLIST_FILE="$OSX_JENKINS_PROCESS.plist"

# Install process
if [[ $# -lt 1 ]]; then 
	usage
	exit 1
fi

# Check for JDK
command -v javac -version >/dev/null 2>&1 || { error >&2 "JDK is not installed"; exit -1; }

# Uninstall process
if [ "$1" == "--start" ]; then 
	startJenkinsSlave
fi

# Uninstall process
if [ "$1" == "--stop" ]; then 
	stopJenkinsSlave
fi

# Uninstall process
if [ "$1" == "--remove" ]; then 
	sudo -i rm /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	success "Jenkins slave deamon uninstalled"
	exit 1
fi

# Install process
if [ "$1" == "--install" ]; then 
	# Ask user for input
	getJenkinsNodeName
	getJenkinsUrl
	getJenkinsSecret

	# Download JNLP
	mkdir -p $OSX_JENKINS_DIR
	curl -s "$JENKINS_URL_NOPROXY/jnlpJars/slave.jar" > "$OSX_JENKINS_DIR/slave.jar"
	cp $OSX_JENKINS_PLIST_FILE "$OSX_JENKINS_DIR/$OSX_JENKINS_PLIST_FILE"

	# Replace strings in PLIST file
	sed -i "" \
		-e "s/{{OSX_USER}}/$OSX_USER/g" \
		-e "s#{{OSX_JENKINS_DIR}}#$OSX_JENKINS_DIR#g" \
		-e "s/{{OSX_JENKINS_PROCESS}}/$OSX_JENKINS_PROCESS/g" \
		-e "s#{{JENKINS_URL}}#$JENKINS_URL#g" \
		-e "s#{{JENKINS_URL_NOPROXY}}#$JENKINS_URL_NOPROXY#g" \
		-e "s/{{JENKINS_NODE_NAME}}/$JENKINS_NODE_NAME/g" \
		-e "s/{{JENKINS_SECRET}}/$JENKINS_SECRET/g" \
		$OSX_JENKINS_DIR/$OSX_JENKINS_PLIST_FILE

	# Install process, set permissions and launch
	sudo -i mv $OSX_JENKINS_DIR/$OSX_JENKINS_PLIST_FILE /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	sudo chown root /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	sudo chmod 644 /Library/LaunchDaemons/$OSX_JENKINS_PLIST_FILE
	success "Jenkins slave deamon installed"

	startJenkinsSlave
fi