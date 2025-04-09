#!/usr/bin/env bash
__FILE__=`realpath "${BASH_SOURCE[0]}"`
__PWD__=`dirname "$__FILE__"`

. "$__PWD__/base.sh"
load_lib "exception"
load_lib "file"


# convert bash scripts from text file, and place thier output inplace.
# bash commands that needs to be replaced atre to be placed in between backticks
# backtick can be placed in same line or in multiple line or one combination after
# another.

# btex <file_loc>
btex(){
   local file="$1"
   local fd=
   local line=
   local rem_line=

   [ -z "$file" ] && raise EmptyArgException "Argument value not supplied."
   [ -f "$file" ] || raise InvaildFileException "Provided file is either invalid, or doesn't exists."

   open_file "$file" "fd"

   while [ -n "$rem_line" ] || has_next_line "$fd" > /dev/null; do
      if [ -z "$rem_line" ]; then
         read_line "$fd" "line"
      else
         line="$rem_line"
      fi

      while [[ "$line" =~ \`([^\`]*)\` ]]; do
         local pat="${BASH_REMATCH[0]}"
         local cmd="${BASH_REMATCH[1]}"

         cmd="`eval "$cmd"`"

         line="${line//"$pat"/$cmd}"
         [ -n "$rem_line" ] && rem_line="${rem_line//"$pat"/}"
      done

      rem_line=
      if [[ "$line" =~ \`([^\`]*)$ ]]; then
         local pat="${BASH_REMATCH[0]}"
         local cmd="${BASH_REMATCH[1]}"

         while has_next_line "$fd" > /dev/null; do
            local line2=

            read_line "$fd" "line2"

            if [[ "$line2" =~ ^([^\`]*)$ ]]; then
               local cmd2="${BASH_REMATCH[1]}"

               cmd="`cat <<-EOF
                  $cmd
                  $cmd2
EOF
               `"
            elif [[ "$line2" =~ ^([^\`]*)\` ]]; then
               local pat2="${BASH_REMATCH[0]}"
               local cmd2="${BASH_REMATCH[1]}"
               cmd="`cat <<-EOF
                  $cmd
                  $cmd2
EOF
               `"
               rem_line=${line2/#"$pat2"/}
               break
            fi
         done

         cmd="`eval "$cmd"`"
         line="${line/%"$pat"/$cmd}"
      fi

      printf "%s\n" "$line"
   done
}

