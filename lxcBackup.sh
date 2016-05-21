#! /usr/bin/env bash
# Description: simple script to cleanly and safely back up your containers either for migration or disaster recovery
# Author: Chris Sabo (https://github.com/csabo)
# Todo: Logging, and error handling

# options
compressBackups="true" # if true, backup will be gzipped
maintainContainerState="true" # if true, the container will not be started after backup if it was not already active (running or frozen)

# directory where gzipped backups should go
backupDirectory="/mnt/backups"

# directory containing your containers (defaults to /var/lib/lxc )
containerDirectory="/var/lib/lxc"

# generates an array of each of your containers using an ls (due to logs showing up in there i've added a grep -v)
containerArray=($(ls "$containerDirectory" |grep -v ".log"))

# array of containers that are currently active
activeContainers=$(lxc-ls --active)

# array of containers you DONT want stopped or backed up
excludedContainers=("ignoredContainer")

# cleanly stop the container function
function stopContainer() {
	/usr/bin/lxc-stop -n "$1"
}

# start the container in the background function
function startContainer() {
	if [[ "$activeContainers" == *"$container"* ]] && [[ "$maintainContainerState" == "true" ]]; then
		/usr/bin/lxc-start -d -n "$1"
	fi
}

# backup the container function (filename example: ServerName.container.05-20-16.tgz )
function backupContainer() {
	if [[ "$compressBackups" == "true" ]]; then
		/usr/bin/tar --numeric-owner -czf "$backupDirectory"/"$1".container.$(date +%m-%d-%y).tgz "$containerDirectory"/"$1"/*
	else
		/usr/bin/tar --numeric-owner -cf "$backupDirectory"/"$1".container.$(date +%m-%d-%y).tar "$containerDirectory"/"$1"/*
	fi
}

# iterate through the array of your containers, and back them up
for container in "${containerArray[@]}"; do
	for ignoredContainer in "${excludedContainers[@]}"; do
		if [[ ! "$ignoredContainer" == "$container" ]]; then
			stopContainer "$container"
			backupContainer "$container"
			startContainer "$container"
		fi
	done
done
