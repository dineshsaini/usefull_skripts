#!/usr/bin/env bash
__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

. "$__PWD__/base.sh"
load_lib "tcolor"

LOG_LEVEL_UNSET=0				# disable logging
LOG_LEVEL_DEBUG=1				# debug
LOG_LEVEL_INFO=2				# info
LOG_LEVEL_WARN=3				# warning
LOG_LEVEL_WARNING=$LOG_LEVEL_WARN		# warning
LOG_LEVEL_ERROR=4				# error
LOG_LEVEL_CRITICAL=5				# critical

LOG_LEVEL_DEFAULT=$LOG_LEVEL_INFO

[[ "$LOG_LEVEL" =~ ^[0-5]$ ]] || LOG_LEVEL=$LOG_LEVEL_DEFAULT

log_debug(){
	[[ "$LOG_LEVEL" -ne $LOG_LEVEL_UNSET ]] && [[ "$LOG_LEVEL" -le $LOG_LEVEL_DEBUG ]] && printf '%s\n' "[$(as_yellow 'DEBUG')]: $*"
}

log_info(){
	[[ "$LOG_LEVEL" -ne $LOG_LEVEL_UNSET ]] && [[ "$LOG_LEVEL" -le $LOG_LEVEL_INFO ]] && printf '%s\n' "[$(as_cyan 'INFO')]: $*"
}

log_warn(){
	[[ "$LOG_LEVEL" -ne $LOG_LEVEL_UNSET ]] && [[ "$LOG_LEVEL" -le $LOG_LEVEL_WARN ]] && printf '%s\n' "[$(as_orange 'WARN')]: $*"
}

log_error(){
	[[ "$LOG_LEVEL" -ne $LOG_LEVEL_UNSET ]] && [[ "$LOG_LEVEL" -le $LOG_LEVEL_ERROR ]] && printf '%s\n' "[$(as_red 'ERROR')]: $*" 1>&2
}

log_critical(){
	[[ "$LOG_LEVEL" -ne $LOG_LEVEL_UNSET ]] && [[ "$LOG_LEVEL" -le $LOG_LEVEL_CRITICAL ]] && printf '%s\n' "[$(as_bold "$(as_red 'CRITICAL')")]: $*" 1>&2
}

log_plain(){
	local _prompt="$1"
	shift

	local _pre=""
	[ -n "$_prompt" ] && _pre="[$(as_cyan "$_prompt")]: "

	printf '%s\n'  "${_pre}$*"
}

