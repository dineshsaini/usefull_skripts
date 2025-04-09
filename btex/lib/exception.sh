#!/usr/bin/env bash
__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

. "$__PWD__/base.sh"
load_lib "logger"


try(){
	ln=`set | grep -E "^__TRY_EXCEPTION__[0-9]+_=" | cut -d= -f2 | sort -n | sed -n '$p'`
	ln=$(( ln + 1 ))
	eval "__TRY_EXCEPTION__${ln}_=$ln"
}


# syntax:
# raise <exception_name> <msg>
# exception name must end with 'Exception' or else this will
# be considered as message.
raise(){
	name="$1"
	shift
	msg="$*"

	if ! [[ "$name" =~ ^.*Exception$ ]]; then
		msg="$name $msg"
		name="Exception"
	fi

	log_error "$name: $msg"
	cnt=${#BASH_SOURCE[@]}
	__="  "
	strace="Traceback (most recent call last):\n"
	while [[ $cnt -gt 0 ]]; do
		fname="${BASH_SOURCE[$cnt]}"
		[ -z "$fname" ] && fname="bash"
		strace="$strace${__}${__}File '$fname', line ${BASH_LINENO[$(( cnt - 1 ))]}, in ${FUNCNAME[$(( cnt - 1 ))]}\n"
		cnt=$(( cnt - 1 ))
	done
	strace="$strace${__}$name: $msg"

	tn=`set | grep -E '^__TRY_EXCEPTION__[0-9]+_=' | cut -d= -f2 | sort -n | sed -n '$p'`

	if ! [ -v "__TRY_EXCEPTION__${tn}_" ]; then
		echo -e "`log_error "$strace" 2>&1`"
		exit 1
	fi
}


catch(){
	ename="$1"
	shift
	ehandle="$@"

	# if exception not specified or invalid  then capture all exception
	if ! [[ "$ename" =~ Exception$ ]]; then
		ehandle="$ename $ehandle"
		ename="Exception"
	fi

	tn=`set | grep -E '^__TRY_EXCEPTION__[0-9]+_=' | cut -d= -f2 | sort -n | sed -n '$p'`

	if ! [ -v "__TRY_EXCEPTION__${tn}_" ]; then
		raise "Exception" "catch statement without try."
	fi
	eval "unset __TRY_EXCEPTION__${tn}_"
	eval "$ehandle"
}

