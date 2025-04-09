#!/usr/bin/env bash
__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

export __PROJECT_DIR__=`realpath "$__PWD__/../"`
export  __LIB_DIR__=`realpath "$__PROJECT_DIR__/lib/"`
export __CONFIG_DIR__=`realpath "$__PROJECT_DIR__/config/"`
export  __SCRIPT_DIR__=`realpath "$__PROJECT_DIR__/scripts/"`

declare -p __LOADED_LIBS__ &> /dev/null || declare -Ag __LOADED_LIBS__=()
declare -p __LOADED_SCRIPTS__ &> /dev/null || declare -Ag __LOADED_SCRIPTS__=()

unset __PWD__
unset __FILE__


load_lib(){
	local lib_name="$1"
	if [ -z "$lib_name" ]; then
		printf "%s\n" "[ERROR]: Lib name not provided." 1>&2
		return 1
	fi
	local lib_file="$__LIB_DIR__/$lib_name"

	[[ "$lib_file" =~ \.sh$ ]] || lib_file="$lib_file.sh"

	if ! [ -f "$lib_file" ]; then
		printf "%s\n" "[ERROR]: Lib file not found." 1>&2
		return 1
	fi

	lib_name="${lib_name%.sh}"
	[ -z "${__LOADED_LIBS__["$lib_name"]}" ] && . "$lib_file"

	__LOADED_LIBS__["$lib_name"]="$lib_file"
}


load_script(){
	local script_name="$1"
	if [ -z "$script_name" ]; then
		printf "%s\n" "[ERROR]: Script name not provided." 1>&2
		return 1
	fi
	local script_file="$__SCRIPT_DIR__/$script_name"

	[[ "$script_file" =~ \.sh$ ]] || script_file="$script_file.sh"

	if ! [ -f "$script_file" ]; then
		printf "%s\n" "[ERROR]: Script file not found." 1>&2
		return 1
	fi

	script_name="${script_name%.sh}"
	[ -z "${__LOADED_SCRIPTS__["$script_name"]}" ] && . "$script_file"

	__LOADED_SCRIPTS__["$script_name"]="$script_file"
}


get_loaded_libs(){
	printf "%s " "${!__LOADED_LIBS__[@]}"
}


get_loaded_scripts(){
	printf "%s " "${!__LOADED_SCRIPTS__[@]}"
}


get_lib_loc(){
	local lib_name="$1"
	if [ -z "$lib_name" ]; then
		printf "%s\n" "[ERROR]: Lib name not provided." 1>&2
		return 1
	fi

	printf "%s" "${__LOADED_LIBS__["$lib_name"]}"
}


get_script_loc(){
	local script_name="$1"
	if [ -z "$script_name" ]; then
		printf "%s\n" "[ERROR]: Script name not provided." 1>&2
		return 1
	fi

	printf "%s" "${__LOADED_SCRIPTS__["$script_name"]}"
}


reload_libs(){
	local _lib=""
	for _lib in "$@"; do
		load_lib "$_lib"
	done
}


reload_scripts(){
	local _script=""
	for _script in "$@"; do
		load_script "$_script"
	done
}

