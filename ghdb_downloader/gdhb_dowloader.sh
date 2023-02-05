#!/usr/bin/env bash

GHDB_URL="https://www.exploit-db.com/ghdb"
from=
upto=
total=
outdir=

TEMPLATE="$(cat <<EOT
GHDB URL:           %s
Severity:           %s
Category:           %s
Published Date:     %s
Author:             %s
GoogleDork:         %s
Description:        %s
EOT
)"

xpath_cat='/html/head/meta[5]/@content'
xpath_pdate='/html/head/meta[12]/@content'
xpath_author='/html/head/meta[6]/@content'
xpath_dork='/html/head/meta[7]/@content'
xpath_desc='/html/head/meta[4]/@content'


help(){
    cat <<EOS
$0 --from=N [--upto=N] [--total=N] [--help|-h]
where, N is integer.
--from              Required.
--upto|--total      One from them is required, If both present, --total will be ignored.
--help|-h           To print this help.
EOS
exit 0
}

url_to_file(){
    local url="$GHDB_URL/$1"
    local temp_file="$(mktemp)"
    echo "file is $temp_file" > /dev/stderr
    wget -q "$url" -O "$temp_file"

    if [ $? -ne 0 ]; then
        rm "$temp_file"
        return 1
    fi

    echo "$temp_file"
}

extract_xpath_from(){
    local xpath="$1"
    local xml_file="$2"
    local element_body=

    element_body=$(xmllint --html --noblanks --nonet --nowarning --noout --noent --xpath "$xpath" "$xml_file" 2>/dev/null)
    element_body=$(printf "%s" "$element_body" | cut -d= -f2- | sed -e 's/^"//;s/"$//' \
        -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&amp;/\&/g' -e 's/&quot;/"/g' \
        -e "s/&apos;/'/g" -e 's/\&#13;\&#10;/\n/g')
    printf "%s" "$element_body"
}

while [[ $# -gt 0 ]]; do
    i="$1"
    shift
    case "$i" in
        --from=[0-9]*)
            from="$(printf "%s" "$i" | cut -d= -f2)"
            ;;
        --upto=[0-9]*)
            upto="$(printf "%s" "$i" | cut -d= -f2)"
            ;;
        --total=[0-9]*)
            total="$(printf "%s" "$i" | cut -d= -f2)"
            ;;
        --outdir=*)
            outdir="$(printf "%s" "$i" | cut -d= -f2-)"
            ;;
        -h|--help)
            help
            ;;
        *)
            echo "Invalid option <$i>, exiting."
            exit 1
            ;;
    esac
done

if [ -z "$outdir" ]; then
    echo "--outdir missing"
    exit
fi

if [ -z "$from" ]; then
    echo "--from missing"
    exit 1
fi

if [ -z "$upto" ] && [ -z "$total" ]; then
    echo "--upto|--from atleast one must be provided"
    exit 1
fi

endc=
if [ -n "$total" ]; then
    endc=$(( from + total - 1 ))
fi

if [ -n "$upto" ]; then
    endc="$upto"
fi

mkdir -p "$outdir"

# correct formatting of numbers that starts with 0
i="$(( from + 1 - 1 ))"

while [[ "$i" -le "$endc" ]]; do
    echo ">> Processing for <$i>:"
    dork_file="$(url_to_file "$i")"

    if [ $? -eq 0 ]; then
        echo ">>  Got response."
    else
        echo ">>  No response."
        continue
    fi

    ghdb_url="$GHDB_URL/$i"
    severity=""
    category="$(extract_xpath_from "$xpath_cat" "$dork_file")"
    p_date="$(extract_xpath_from "$xpath_pdate" "$dork_file")"
    author="$(extract_xpath_from "$xpath_author" "$dork_file")"
    dork="$(extract_xpath_from "$xpath_dork" "$dork_file")"
    desc="$(extract_xpath_from "$xpath_desc" "$dork_file")"

    printf "$TEMPLATE" "$ghdb_url" "$severity" "$category" "$p_date" "$author" "$dork" "$desc" > "$outdir/$i.txt"

    #[ -f "$dork_file" ] && rm -f $dork_file 

    sleep 1
    i="$(( i + 1 ))"
done





