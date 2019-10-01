#!/usr/bin/env bash

TRAIL_CONFIG_DIR=$HOME/.config/trailcli
REQUIRED_PYTHON_VERSION="3.7.4"
PYENV_DIR=$HOME/.pyenv

if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]
then
	PROFILE_FILE=$HOME/.zshrc
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]
then
	PROFILE_FILE=$HOME/.bashrc
else
    echo "Couldn't find out which shell is used. Run again on bash or zsh."
    exit 1
fi

uninstall_pyenv () {
    if [ -d "$PYENV_DIR" ]
    then
        rm -rf $PYENV_DIR
    fi
    sed -i'' '/# trail-pyenv-start/,/# trail-pyenv-end/d' $PROFILE_FILE
}

remove_pipenv_source_lines () {
    sed -i'' '/# trail-pipenv-start/,/# trail-pipenv-end/d' $PROFILE_FILE
}

remove_trail_config () {
    if [ -d "$TRAIL_CONFIG_DIR" ]
    then
        rm -rf $TRAIL_CONFIG_DIR
    fi
}

uninstall_pyenv
remove_pipenv_source_lines
remove_trail_config
