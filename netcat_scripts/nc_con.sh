#!/usr/bin/bash

#open parallel independent connections

lport="4444"
i=1;
inf=0; #infinite run {true=1, false=0}

while [ true ]; do
	echo "Trying new...";
	trap break SIGINT;
	if [[ "$(ss sport = :$lport -l -H | wc -l)" -eq 0 ]]; then
		echo "opening socket $(( i++ ))";
		nc -4 -l -p $lport & 
		#do something else to process or detach nc server or attach seperate command to each request
	fi;
	if [[ "$(ss sport = :$lport -l -H | wc -l)" -ne 0 ]]; then
		watch -n 0.1 -g "ss sport = :$lport -l -H" > /dev/null;
	fi;
	if [[ "$inf" -eq 0 ]] && [[ "$i" -eq 11 ]]; then
		break;
	fi;
done;
