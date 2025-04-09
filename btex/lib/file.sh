#!/usr/bin/env bash
__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

. "$__PWD__/base.sh"
load_lib "exception"


open_file(){
   local _file="$1"
   local _ret_var_name="$2"

   [ -z "$_file" ] && raise EmptyArgException "Argument value not supplied."
   [ -f "$_file" ] || raise InvaildFileException "Provided file is either invalid, or doesn't exists."

   declare -p __OPENED_FILES_CUR_LINE__ &> /dev/null || declare -Ag __OPENED_FILES_CUR_LINE__
   declare -p __OPENED_FILES_TOT_LINES__ &> /dev/null || declare -Ag __OPENED_FILES_TOT_LINES__
   declare -p __OPENED_FILES_NAMES__ &> /dev/null || declare -Ag __OPENED_FILES_NAMES__

   local _fd=$RANDOM

   while [[ ",`printf '%s,' "${!__OPENED_FILES_CUR_LINE__[@]}"`" =~ ,${_fd}, ]]; do
      _fd=$RANDOM
   done

   __OPENED_FILES_NAMES__[$_fd]="`realpath "$_file"`"
   __OPENED_FILES_CUR_LINE__[$_fd]=1
   __OPENED_FILES_TOT_LINES__[$_fd]="`wc -l --total=only "$_file"`"

   if [ -z "$_ret_var_name" ]; then
      printf "%s" "$_fd"
   else
      declare -n ref_tmp="$_ret_var_name"
      ref_tmp="$_fd"
      unset -n ref_tmp
   fi
}


has_next_line(){
   local _fd="$1"

   [ -z "$_fd" ] && raise EmptyArgException "Argument value not supplied."

   [[ ",`printf '%s,' "${!__OPENED_FILES_NAMES__[@]}"`" =~ ,${_fd}, ]] || raise InvalidFileDescriptorException "Provided file descriptor is invalid."

   [[ "${__OPENED_FILES_CUR_LINE__["$_fd"]}" -le "${__OPENED_FILES_TOT_LINES__["$_fd"]}" ]] && {
      echo /usr/bin/true;
      return `true`;
   } || {
      echo /usr/bin/false;
      return `false`;
   }
}


read_line(){
   local _fd="$1"
   local _ret_var_name="$2"
   local _line=

   has_next_line "$_fd" > /dev/null && {
      local n="${__OPENED_FILES_CUR_LINE__["$_fd"]}" ;
      _line="`sed -n "${n}p" "${__OPENED_FILES_NAMES__["$_fd"]}"`";
      n=$(( n + 1 )) ;
      __OPENED_FILES_CUR_LINE__["$_fd"]=$n
   } || raise EOLReachedException "Can't read, unexpected EOL."

   if [ -z "$_ret_var_name" ]; then
      printf "%s" "$_line"
   else
      declare -n ref_tmp="$_ret_var_name"
      ref_tmp="$_line"
      unset -n ref_tmp
   fi
}


peek_next_line(){
   local _fd="$1"
   local _ret_var_name="$2"
   local _line=

   has_next_line "$_fd" > /dev/null && {
      local n="${__OPENED_FILES_CUR_LINE__["$_fd"]}" ;
      _line="`sed -n "${n}p" "${__OPENED_FILES_NAMES__["$_fd"]}"`";
   } || raise EOLReachedException "Can't read, unexpected EOL."

   if [ -z "$_ret_var_name" ]; then
      printf "%s" "$_line"
   else
      declare -n ref_tmp="$_ret_var_name"
      ref_tmp="$_line"
      unset -n ref_tmp
   fi
}


# seek_line <fd> <line number>
# to seek from bottom of file
# seek_line <fd> -<line number>
# to seek from current line to up/down
# seek_line <fd> 0-<line number>
# seek_line <fd> 0+<line number>
# to jump on current line
# seek_line <fd> 0
seek_line(){
   local _fd="$1"
   local _ln="$2"

   [ -z "$_fd" ] && raise EmptyArgException "Argument value not supplied."
   [ -z "$_ln" ] && raise EmptyArgException "Argument value not supplied."

   [[ ",`printf '%s,' "${!__OPENED_FILES_NAMES__[@]}"`" =~ ,${_fd}, ]] || raise InvalidFileDescriptorException "Provided file descriptor is invalid."
   [[ "$_ln"  =~ ^0?[+-]?[0-9]+$ ]] || raise InvalidLineException "Supplied line no is not in supported format."

   local n=__OPENED_FILES_TOT_LINES__[$_fd]
   local c=__OPENED_FILES_CUR_LINE__[$_fd]
   local l=0

   if [[ "$_ln" =~ ^0([+-])([0-9]+)$ ]]; then
      local _op=${BASH_REMATCH[1]}
      local _jmp=${BASH_REMATCH[2]}
      l=$(( c $_op _jmp ))
   elif [[ "$_ln" -lt 0 ]]; then
      l=$(( n + _ln  + 1 ))
   elif [[ "$_ln" -eq 0 ]]; then
      l=$c
   else
      l=$_ln
   fi

   ( [[ $l -le $n ]] && [[ $l -gt 0 ]] )  && __OPENED_FILES_CUR_LINE__["$_fd"]=$l || raise InvalidLineException "Supplied line expression produces invalid line number."
}


close_file(){
   local _fd="$1"

   [ -z "$_fd" ] && raise EmptyArgException "Argument value not supplied."

   [[ ",`printf '%s,' "${!__OPENED_FILES_NAMES__[@]}"`" =~ ,${_fd}, ]] || raise InvalidFileDescriptorException "Provided file descriptor is invalid."

   unset __OPENED_FILES_NAMES__[$_fd]
   unset __OPENED_FILES_CUR_LINE__[$_fd]
   unset __OPENED_FILES_TOT_LINES__[$_fd]
}

