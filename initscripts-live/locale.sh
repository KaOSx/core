unset LANG

if [ -s /etc/locale.conf ]; then
	. /etc/locale.conf
fi

if [ -z "$LANG" ] && [ -s /etc/rc.conf ]; then
	LANG=$(. /etc/rc.conf 2>/dev/null; echo "$LOCALE")
fi

export LANG=${LANG:-C}

if [ -n "$LC_CTYPE" ]; then
	export LC_CTYPE
else
	unset LC_CTYPE
fi

if [ -n "$LC_NUMERIC" ]; then
	export LC_NUMERIC
else
	unset LC_NUMERIC
fi

if [ -n "$LC_TIME" ]; then
	export LC_TIME
else
	unset LC_TIME
fi

if [ -n "$LC_COLLATE" ]; then
	export LC_COLLATE
else
	unset LC_COLLATE
fi

if [ -n "$LC_MONETARY" ]; then
	export LC_MONETARY
else
	unset LC_MONETARY
fi

if [ -n "$LC_MESSAGES" ]; then
	export LC_MESSAGES
else
	unset LC_MESSAGES
fi

if [ -n "$LC_PAPER" ]; then
	export LC_PAPER
else
	unset LC_PAPER
fi

if [ -n "$LC_NAME" ]; then
	export LC_NAME
else
	unset LC_NAME
fi

if [ -n "$LC_ADDRESS" ]; then
	export LC_ADDRESS
else
	unset LC_ADDRESS
fi

if [ -n "$LC_TELEPHONE" ]; then
	export LC_TELEPHONE
else
	unset LC_TELEPHONE
fi

if [ -n "$LC_MEASUREMENT" ]; then
	export LC_MEASUREMENT
else
	unset LC_MEASUREMENT
fi

if [ -n "$LC_IDENTIFICATION" ]; then
	export LC_IDENTIFICATION
else
	unset LC_IDENTIFICATION
fi
