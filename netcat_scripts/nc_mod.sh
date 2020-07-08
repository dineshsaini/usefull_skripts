#!/usr/bin/bash

lport="4444"
i=0;


while [ true ]; do
	echo "opening socket $(( i++ ))";
	
	if [[ "$(ss sport = :$lport -l -H | wc -l)" -eq 0 ]]; then
		nc -l -vv -p $lport & 
		#do something else to process or detach nc server
	fi;
	if [[ "$(ss sport = :$lport -l -H | wc -l)" -ne 0 ]]; then
		watch -n 0.1 -g "ss sport = :$lport -l -H" > /dev/null;
	fi;

	if [[ i -eq 10 ]]; then
		break;
	fi;
done;
