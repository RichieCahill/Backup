#!/usr/bin/env bash

# rdl - differential backup using rdiff-backup and logrotate
#
# Copyright (C) 2021  Alice Huston
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# usage: rdl <source directory> <destination directory>

#######################################
# Print a line separator
#
# Quite literally just prints '-' 80 times
#
# OUTPUTS:
#   Write separator to stdout
# RETURN:
#   0 if print succeeds, non-zero on error.
#######################################
function gen_sep() {
	i=0
	printf "<"
	while [ "$i" -lt 78 ]; do
		printf "-"
		((++i))
	done
	printf ">"
}

# Check if run with 2 arguments, output usage otherwise
if [ $# -eq 2 ]; then
	# Parse date and source path
	datetime="$(date +%F-%H:%M)"
	srcdir=$(realpath "$1")

	# Create destination directory with log directory if needed
	if [ ! -d "$2" ]; then
		mkdir -p "$2/logs"
	fi

	# Parse destination path
	dstdir=$(realpath "$2")
	log="$dstdir/logs/rdl.log"

	# Do rdiff-backup and append to logfile
	{
		# Insert basic information
		printf "%s\nTimestamp: %s\n\nBacking up %s to %s\n\n" "$(gen_sep)" "$datetime" "$srcdir" "$dstdir"
		printf "Begin rdiff-backup logs\n\n"

		# Begin backup
		rdiff-backup -v5 --print-statistics "$srcdir" "$dstdir/backup" 2>&1
		printf "\n\n\n"

		# Prune old backups, if needed
		rdiff-backup --remove-older-than 3M "$dstdir/backup" 2>&1
	} >>"$log"

	printf "\n\nBegin logrotate logs\n\n" >>"$log"

	# Generate logrotate configuration file if necessary
	if [ ! -f "$dstdir/logs/logrotate.conf" ]; then
		cat <<-EOF >"$dstdir/logs/logrotate.conf"
			$dstdir/logs/rdl.log {
			    weekly
			    create
			    rotate 13
			    compress
			    dateext
			    dateformat -%d-%m-%Y
			    missingok
			    notifempty
			}
		EOF
	fi

	# Rotate logs
	logrotate "$dstdir/logs/logrotate.conf" --state "$dstdir/logs/logrotate-state" --verbose >>"$log" 2>&1
else
	# If the wrong number of arguments are passed, print usage
	echo "Usage: $0 <source directory> <destination directory>"
fi
