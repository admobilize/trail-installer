#!/usr/bin/env bash

TRAIL_CONFIG_DIR=$HOME/.config/trailcli
REQUIRED_PYTHON_VERSION="3.7.4"
PYENV_DIR=$HOME/.pyenv
PYENV_BIN_DIR=$PYENV_DIR/versions/$REQUIRED_PYTHON_VERSION/bin

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
        rm -rf $PYENV_DIR 1>/dev/null 2>&1
        echo "pyenv dir deleted."
    fi
}

remove_virtualenv () {

    VIRTUAL_ENV_DIR=$($PYENV_BIN_DIR/pipenv --venv)
    if [ -d "$VIRTUAL_ENV_DIR" ]
    then
        rm -rf $VIRTUAL_ENV_DIR
        echo "virtualenv dir deleted."
    fi
}

remove_pyenv_source_lines () {
    sed -i'' '/# trail-pyenv-start/,/# trail-pyenv-end/d' $PROFILE_FILE
}

remove_pipenv_source_lines () {
    sed -i'' '/# trail-pipenv-start/,/# trail-pipenv-end/d' $PROFILE_FILE
}

remove_trail_config () {
    if [ -d "$TRAIL_CONFIG_DIR" ]
    then
        rm -rf $TRAIL_CONFIG_DIR
        echo "trail config dir deleted."
    fi
}

remove_virtualenv
remove_pipenv_source_lines
remove_trail_config
remove_pyenv_source_lines

echo "Would you like to remove pyenv? [y/n]"
read DEL_PYENV
case $DEL_PYENV in
    y | Y)
        uninstall_pyenv
        ;;
    *)
        echo "Skipping pyenv removal."
        ;;
esac
