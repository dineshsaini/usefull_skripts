#!/usr/bin/env bash

basedir="$(realpath $1)"
dirfile=$2

echo "got $basedir, $dirfile"

l1="";
l2="";
l3="";
l4="";
while IFS= read -r i; do
    l="$(echo $i | sed 's/^ \+//')"

    case $l in
        \#*)
            l1="$(echo $l | sed -e 's/^# //' -e 's/(//g' -e 's/)//g' -e 's/ \+/ /g' -e 's/"//g' -e 's/ /_/g' -e 's/://g' -e 's/\./_/g' -e 's/\//_/g' -e "s/'//g" -e 's/_\+/_/g' -e 's/_-_/-/g')"
            d="$basedir/$l1"
            echo "> $d"
            mkdir $d
            ;;
        =*)
            l2="$(echo $l | sed -e 's/^= //' -e 's/(//g' -e 's/)//g' -e 's/ \+/ /g' -e 's/"//g' -e 's/ /_/g' -e 's/://g' -e 's/\./_/g' -e 's/\//_/g' -e "s/'//g" -e 's/_\+/_/g' -e 's/_-_/-/g')"
            d="$basedir/$l1/$l2"
            echo "> $d"
            mkdir $d
            ;;
        -*)
            l3="$(echo $l | sed -e 's/^- //' -e 's/(//g' -e 's/)//g' -e 's/ \+/ /g' -e 's/"//g' -e 's/ /_/g' -e 's/://g' -e 's/\./_/g' -e 's/\//_/g' -e "s/'//g" -e 's/_\+/_/g' -e 's/_-_/-/g')"
            d="$basedir/$l1/$l2/$l3"
            echo "> $d"
            mkdir $d
            ;;
        @*)
            l4="$(echo $l | sed -e 's/^@ //' -e 's/(//g' -e 's/)//g' -e 's/ \+/ /g' -e 's/"//g' -e 's/ /_/g' -e 's/://g' -e 's/\./_/g' -e 's/\//_/g' -e "s/'//g" -e 's/_\+/_/g' -e 's/_-_/-/g')"
            d="$basedir/$l1/$l2/$l3/$l4"
            echo "> $d"
            mkdir $d
            ;;
    esac;




done < <(cat $dirfile);

