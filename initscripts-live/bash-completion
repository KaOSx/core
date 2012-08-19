# rc.d bash completion by Seblu <seblu@seblu.net>

_rc_d()
{
	local action cur prev
	actions='help list start stop reload restart'
	options='-s --started -S --stopped -a --auto -A --noauto'
	_get_comp_words_by_ref cur prev
	_get_first_arg
	if [[ -z "$arg" ]]; then
		COMPREPLY=($(compgen -W "${actions} ${options}" -- "$cur"))
	elif [[ "$arg" == help ]]; then
		COMPREPLY=()
	elif [[ "$arg" == start ]]; then
		COMPREPLY=($(comm -23 <(cd /etc/rc.d && compgen -f -X 'functions*' "$cur"|sort) <(cd /run/daemons/ && compgen -f "$cur"|sort)))
	elif [[ "$arg" =~ stop|restart|reload ]]; then
		COMPREPLY=($(cd /run/daemons/ && compgen -f "$cur"|sort))
	else
		COMPREPLY=($(compgen -W "${options} $(cd /etc/rc.d && compgen -f -X 'functions*')" -- "$cur"))
	fi
}
complete -F _rc_d rc.d

# vim: set ts=2 sw=2 ft=sh noet:
