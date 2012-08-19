#!/bin/bash

. /etc/rc.conf
. /etc/rc.d/functions

# print usage and exit
usage() {
	local name=${0##*/}
	cat >&2 << EOF
usage: $name <action> [options] [daemons]

options:
  -s, --started     Filter started daemons
  -S, --stopped     Filter stopped daemons
  -a, --auto        Filter auto started daemons
  -A, --noauto      Filter manually started daemons

<daemons> is a space separated list of script in /etc/rc.d
<action> can be a start, stop, restart, reload, status, ...
WARNING: initscripts are free to implement or not the above actions.

e.g: $name list
     $name list sshd gpm
     $name list --started gpm
     $name start sshd gpm
     $name stop --noauto
     $name help
EOF
	exit ${1:-1}
}

# filter list of daemons
filter_daemons() {
	local -a new_daemons=()
	for daemon in "${daemons[@]}"; do
		# check if daemons is valid
		if ! have_daemon "$daemon"; then
			printf "${C_FAIL}:: ${C_DONE}Daemon script ${C_FAIL}${daemon}${C_DONE} does \
not exist or is not executable.${C_CLEAR}\n" >&2
			exit 2
		fi
		# check filter
		(( ${filter[started]} )) && ck_daemon "$daemon" && continue
		(( ${filter[stopped]} )) && ! ck_daemon "$daemon" && continue
		(( ${filter[auto]} )) && ck_autostart "$daemon" && continue
		(( ${filter[noauto]} )) && ! ck_autostart "$daemon" && continue
		new_daemons+=("$daemon")
	done
	daemons=("${new_daemons[@]}")
}

(( $# < 1 )) && usage

# ret store the return code of rc.d
declare -i ret=0
# daemons store daemons on which action will be executed
declare -a daemons=()
# filter store current filter mode
declare -A filter=([started]=0 [stopped]=0 [auto]=0 [noauto]=0)

# parse options
argv=$(getopt -l 'started,stopped,auto,noauto' -- 'sSaA' "$@") || usage
eval set -- "$argv"

# create an initial daemon list
while [[ "$1" != -- ]]; do
	case "$1" in
		-s|--started)		filter[started]=1 ;;
		-S|--stopped)		filter[stopped]=1 ;;
		-a|--auto)			filter[auto]=1 ;;
		-A|--noauto)		filter[noauto]=1 ;;
	esac
	shift
done

# remove --
shift
# get action
action=$1
shift

# get initial daemons list
for daemon; do
	daemons+=("$daemon")
done

# going into script directory
cd /etc/rc.d

case $action in
	help)
		usage 0 2>&1
	;;
	list)
		# list take all daemons by default
		[[ -z $daemons ]] && for d in *; do have_daemon "$d" && daemons+=("$d"); done
		filter_daemons
		for daemon in "${daemons[@]}"; do
			# print running / stopped satus
			if ! ck_daemon "$daemon"; then
				s_status="${C_OTHER}[${C_DONE}STARTED${C_OTHER}]"
			else
				s_status="${C_OTHER}[${C_FAIL}STOPPED${C_OTHER}]"
			fi
			# print auto / manual status
			if ! ck_autostart "$daemon"; then
				s_auto="${C_OTHER}[${C_DONE}AUTO${C_OTHER}]"
			else
				s_auto="${C_OTHER}[${C_FAIL}    ${C_OTHER}]"
			fi
			printf "$s_status$s_auto${C_CLEAR} $daemon\n"
		done
	;;
	*)
		# other actions need an explicit daemons list
		[[ -z $daemons ]] && usage
		filter_daemons
		# set same environment variables as init
		runlevel=$(/sbin/runlevel)
		ENV=('PATH=/bin:/usr/bin:/sbin:/usr/sbin'
			"PREVLEVEL=${runlevel%% *}"
			"RUNLEVEL=${runlevel##* }"
			"CONSOLE=${CONSOLE:-/dev/console}"
			"TERM=$TERM")
		cd /
		for daemon in "${daemons[@]}"; do
			env -i "${ENV[@]}" "/etc/rc.d/$daemon" "$action"
			(( ret += !! $? ))  # clamp exit value to 0/1
		done
	;;
esac

exit $ret

# vim: set ts=2 sw=2 ft=sh noet:
