__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

. "$__PWD__/base.sh"
load_lib "logger"
load_lib "exception"


# reg_arg_parser <parser_name>
reg_arg_parser(){
	local _pname="$1"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."

	declare -Ag "${_pname}_op_sh"
	declare -Ag "${_pname}_op_ln"
	declare -Ag "${_pname}_op_vals"
	declare -Ag "${_pname}_op_type"
	declare -Ag "${_pname}_op_help"
}


# unreg_arg_parser <parser_name>
unreg_arg_parser(){
	local _pname="$1"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."

	unset "${_pname}_op_sh"
	unset "${_pname}_op_ln"
	unset "${_pname}_op_vals"
	unset "${_pname}_op_type"
	unset "${_pname}_op_help"
}

# reg_arg <parser_name> <argument_name> <arg_opt1|arg_opt2> <type> <help msg>
# can only one long and one short or either one alone, cant have two short or long opts
# if has two long or short options then only later will be recognised.
# type can be either flag or value,
# type:flag dont need any value, and type:value except some value to be supplied.
reg_arg(){
	local _pname="$1"
	local _arg_name="$2"
	local _arg_opt1="`printf "%s" "$3" | cut -d'|' -f1`"
	local _arg_opt2="`printf "%s" "$3" | cut -d'|' -f2`"
	local _arg_type="$4"
	local _arg_help="$5"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_name" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_type" ] && raise EmptyArgException "Argument value not supplied."
	( [ -z "$_arg_opt1" ] && [ -z "$_arg_opt2" ] ) && raise EmptyArgException "Argument value not supplied."

	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."
	[[ "$_arg_name" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Argument name is invalid."
	( [ -z "$_arg_opt1" ] || [[ "$_arg_opt1" =~ ^--?[a-zA-Z_0-9]+$ ]] ) || raise InvalidOptionException "Argument option is invalid."
	( [ -z "$_arg_opt2" ] || [[ "$_arg_opt2" =~ ^--?[a-zA-Z_0-9]+$ ]] ) || raise InvalidOptionException "Argument option is invalid."
	[[ "$_arg_type" =~ ^(flag|value)$ ]] || raise InvalidValueException "Argument type is invalid."

	local _ln_opt=""
	local _sh_opt=""
	[ -n "$_arg_opt1" ] && { [[ "$_arg_opt1" =~ ^-- ]] && _ln_opt="$_arg_opt1" || _sh_opt="$_arg_opt1" ; }
	[ -n "$_arg_opt2" ] && { [[ "$_arg_opt2" =~ ^-- ]] && _ln_opt="$_arg_opt2" || _sh_opt="$_arg_opt2" ; }

	declare -n ref_op_sh="${_pname}_op_sh"
	declare -n ref_op_ln="${_pname}_op_ln"
	declare -n ref_op_help="${_pname}_op_help"
	declare -n ref_op_type="${_pname}_op_type"

	ref_op_sh["$_arg_name"]="$_sh_opt"
	ref_op_ln["$_arg_name"]="$_ln_opt"
	ref_op_help["$_arg_name"]="$_arg_help"
	ref_op_type["$_arg_name"]="$_arg_type"

	unset -n ref_op_sh
	unset -n ref_op_ln
	unset -n ref_op_help
	unset -n ref_op_type
}


# set_arg <parser_name> <argment_name> <argument_val>
set_arg(){
	local _pname="$1"
	local _arg_name="$2"
	local _arg_val="$3"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_name" ] && raise EmptyArgException "Argument value not supplied."

	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."
	[[ "$_arg_name" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Argument name is invalid."

	declare -n ref_op_val="${_pname}_op_vals"

	ref_op_val["$_arg_name"]="$_arg_val"

	unset -n ref_op_val
}


# get_arg_val <parser_name> <argument_name>
get_arg_val(){
	local _pname="$1"
	local _arg_name="$2"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_name" ] && raise EmptyArgException "Argument value not supplied."

	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."
	[[ "$_arg_name" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Argument name is invalid."

	declare -n ref_op_val="${_pname}_op_vals"
	declare -n ref_op_type="${_pname}_op_type"

	local _arg_type="${ref_op_type["$_arg_name"]}"

	retval="${ref_op_val["$_arg_name"]}"

	[ "$_arg_type" == "flag" ] && { [ "${retval#/usr/bin/}" == "true" ] || retval=/usr/bin/false ; }

	unset -n ref_op_val

	printf "%s" "$retval"
}


is_arg_set(){
	local _pname="$1"
	local _arg_name="$2"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_name" ] && raise EmptyArgException "Argument value not supplied."

	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."
	[[ "$_arg_name" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Argument name is invalid."

	declare -n ref_op_type="${_pname}_op_type"
	declare -n ref_op_val="${_pname}_op_vals"

	local _arg_type="${ref_op_type["$_arg_name"]}"
	local _arg_val="${ref_op_val["$_arg_name"]}"

	local _retval=/usr/bin/false
   local _retflag=1
	_arg_val=${_arg_val#/usr/bin/}

	# return true if type is flag and is set, else if non-empty
	[ "$_arg_type" == "flag" ] && {
         [ "$_arg_val" == "true" ] && { _retval=/usr/bin/true; _retflag=0; }
      } || {
         [ -n "$_arg_val" ] && { _retval=/usr/bin/true; _retflag=0; }
      }

	unset -n ref_op_type
	unset -n ref_op_val

	echo $_retval
   return $_retflag
}


# get_arg_from_opt <parser_name> <argument_opt>
get_arg_from_opt(){
	local _pname="$1"
	local _arg_opt="$2"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[ -z "$_arg_opt" ] && raise EmptyArgException "Argument value not supplied."

	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."
	[[ "$_arg_opt" =~ ^--?[a-zA-Z_0-9]+$ ]] || raise InvalidOptionException "Argument option is invalid."

	local _type=""
	[[ "$_arg_opt" =~ ^-- ]] && _type="ln" || _type="sh"

	declare -n ref_opts="${_pname}_op_${_type}"
	local retval=""
	local _n=""

	for _n in "${!ref_opts[@]}"; do
		[ "${ref_opts["$_n"]}" == "$_arg_opt" ]	&& { retval="${_n}"; break; }
	done

	unset -n ref_opts

	printf "%s" "$retval"
}


# parse_args <parser_name> "$@"
parse_args(){
	local _pname="$1"
	shift
	local _arg_opt=""
	local _arg_val=""

	declare -n ref_op_type="${_pname}_op_type"

	while [[ $# -gt 0 ]]; do
		_arg_opt="$1"
		shift

		local _name=`get_arg_from_opt "$_pname" "$_arg_opt"`

		 [ -z "$_name" ] && raise NoSuchOptionException "Invalid option('$_arg_opt') supplied."

		local _type="${ref_op_type["$_name"]}"

		[ "$_type" == "flag" ] && _arg_val=/usr/bin/true || { _arg_val="$1"; shift; }

		set_arg "$_pname" "$_name" "$_arg_val"
	done

	unset -n ref_op_type
}


# args_debug <parser_name> <no_exit>
# no_exit: 1|true|yes|0|false|no
# default is no, and can be skipped
args_print_help(){
	local _pname="$1"
   local _no_exit="$2"

	[ -z "$_pname" ] && raise EmptyArgException "Argument value not supplied."
	[[ "$_pname" =~ ^[a-zA-Z_][a-zA-Z_0-9]*$ ]] || raise InvalidNameException "Arg parser name is invalid."

	declare -n ref_op_sh="${_pname}_op_sh"
	declare -n ref_op_ln="${_pname}_op_ln"
	declare -n ref_op_help="${_pname}_op_help"

	local _n=""
	for _n in "${!ref_op_sh[@]}"; do
		local _sep="\t\t"
		local _arg_opts="${ref_op_sh["$_n"]}, ${ref_op_ln["$_n"]}"
		_arg_opts=${_arg_opts# }
		_arg_opts=${_arg_opts% }
		_arg_opts=${_arg_opts#,}
		_arg_opts=${_arg_opts%,}

		[ -z "${ref_op_ln["$_n"]}" ] && _sep="${_sep}\t"

		printf "%s${_sep}%s\n" "$_arg_opts" "${ref_op_help["$_n"]}"
	done
	unset -n ref_op_sh
	unset -n ref_op_ln
	unset -n ref_op_help

   [[ "${_no_exit@L}" =~ ^(1|true|yes|y)$ ]] || exit 0
}

