#!/bin/bash

install_conf () {
    local conf="$PWD/$1"
    if [[ ! -e "$conf" ]]; then
	echo Error: "$conf doesn't exist."
	exit 2
    fi
    if [[ -e "$2" ]] && ! diff "$conf" "$2"; then
	echo ======================================
	echo Error: "$conf" differs from "$2"
	echo ======================================
	diff "$conf" and "$2" | head -50
	exit 1
    else
	ln -fs "$conf" "$2"
    fi
}

install_conf emacs.conf ~/.emacs
install_conf bash.conf ~/.bash_profile
install_conf tmux.conf ~/.tmux.conf
if [[ "$(uname -s)" == Darwin ]]; then
    install_conf karabiner.conf "$HOME/Library/Application Support/Karabiner/private.xml"
fi
