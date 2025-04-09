#!/usr/bin/env bash

__NO_COLOR="${NO_COLOR##\/usr\/bin\/}"
NO_COLOR=/usr/bin/false
if [ "$__NO_COLOR" == "true" ]; then
	NO_COLOR=/usr/bin/true
fi
unset __NO_COLOR


# colors
c_red="$(tput setaf 196)"
c_cyan="$(tput setaf 44)"
c_light_green_2="$(tput setaf 10)"
c_yellow="$(tput setaf 190)"
c_orange="$(tput setaf 202)"
c_light_blue="$(tput setaf 42)"
c_light_green="$(tput setaf 2)"
c_light_red="$(tput setaf 9)"


# backgrounds
b_black="$(tput setab 16)"
b_dark_black="$(tput setab 233)"
b_light_black="$(tput setab 236)"


# styles
s_bold="$(tput bold)"
s_dim="$(tput dim)"
s_underline="$(tput smul)"


# reset
p_reset="$(tput sgr0)"


function __cont {
    printf '%s' "${1//$p_reset/$p_reset$2}"
}

function _color {
    $NO_COLOR && printf '%s' "$1" || printf '%s' "$2$(__cont "$1" "$2")$p_reset"
}

function as_red {
    printf '%s' "$(_color "$1" "$c_red")"
}

function as_cyan {
    printf '%s' "$(_color "$1" "$c_cyan")"
}

function as_yellow {
    printf '%s' "$(_color "$1" "$c_yellow")"
}

function as_orange {
    printf '%s' "$(_color "$1" "$c_orange")"
}

function as_light_blue {
    printf '%s' "$(_color "$1" "$c_light_blue")"
}

function as_light_green {
    printf '%s' "$(_color "$1" "$c_light_green")"
}

function as_light_green_2 {
    printf '%s' "$(_color "$1" "$c_light_green_2")"
}

function as_light_red {
    printf '%s' "$(_color "$1" "$c_light_red")"
}

function on_black {
    printf '%s' "$(_color "$1" "$b_black")"
}

function on_light_black {
    printf '%s' "$(_color "$1" "$b_light_black")"
}

function on_dark_black {
    printf '%s' "$(_color "$1" "$b_dark_black")"
}

function as_bold {
    printf '%s' "$(_color "$1" "$s_bold")"
}

function as_dim {
    printf '%s' "$(_color "$1" "$s_dim")"
}

function as_underline {
    printf '%s' "$(_color "$1" "$s_underline")"
}

