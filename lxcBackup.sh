#!/bin/bash
# Description: simple script to cleanly and safely back up your containers either for migration or disaster recovery
# Author: Chris Sabo (https://github.com/csabo)
# Todo: Logging, and error handling

# directory where gzipped backups should go
backupDirectory="/mnt/backups"

# directory containing your containers (defaults to /var/lib/lxc )
containerDirectory="/var/lib/lxc"

# generates an array of each of your containers using an ls (due to logs showing up in there i've added a grep -v)
containerArray=($(ls "$containerDirectory" |grep -v ".log"))

# cleanly stop the container function
function stopContainer() {
	/usr/bin/lxc-stop -n "$1"
}

# start the container in the background function
function startContainer() {
	/usr/bin/lxc-start -d -n "$1"
}

# backup the container function (filename example: ServerName.container.05-20-16.tgz )
function backupContainer() {
	/usr/bin/tar --numeric-owner -czf "$backupDirectory"/"$1".container.$(date +%m-%d-%y).tgz "$containerDirectory"/"$1"/*
}

# iterate through the array of your containers, and back them up
for container in "${containerArray[@]}"; do
	stopContainer "$container"
	backupContainer "$container"
	startContainer "$container"
done
