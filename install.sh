#!/usr/bin/env bash

set -e

if [ $# -gt 2 ]; then
    echo "Too many arguments passed."
    echo "Usage: install.sh [admobilize_pypi_username [admobilize_pypi_password]]"
    exit 1
fi

if ! command -v git 1>/dev/null; then
    echo "Install git before trying to run this script."
    exit 1
fi

REQUIRED_PYTHON_VERSION="3.7.4"
REQUIRED_PYTHON_VERSION_MIN="3.7"
TRAIL_CONFIG_DIR=$HOME/.config/trailcli
BUILD_DIR=$TRAIL_CONFIG_DIR/build
DEBUG_FILE=/tmp/trail-installer.log
# Reuse the default PYENV_ROOT if exists
PYENV_ROOT=${PYENV_ROOT:-$HOME/.pyenv}
TRAIL_PYENV=${TRAIL_PYENV:-trail-cli}
PYENV_TRAIL_DIR=$PYENV_ROOT/versions/$TRAIL_PYENV
PYENV_TRAIL_BIN_DIR=$PYENV_TRAIL_DIR/bin
PIPCONF_FILE=$PYENV_TRAIL_DIR/pip.conf


# Check if admobilize pypi username was passed
if [ "$1" ]; then
    PYPI_USERNAME=$1
    # If there's an username, check if the password was passed
    if [ "$2" ]
    then
        PYPI_PASSWORD=$2
    fi
fi


if [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
    PROFILE_FILE=$HOME/.zshrc
elif [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
    PROFILE_FILE=$HOME/.bashrc
else
    echo "Unsupported shell: $SHELL"
    echo "Run again on bash or zsh."
    exit 1
fi

if [ -z "$PYPI_USERNAME" ]; then
    echo -n "Pypi Username: "
    read PYPI_USERNAME
fi

if [ -z "$PYPI_PASSWORD" ]; then
    echo -n "Pypi Password: "
    read -s PYPI_PASSWORD
fi
echo ""

PYENV_BASH_LINE_1="# trail-pyenv-start"
PYENV_BASH_LINE_2="alias trail=\"$PYENV_TRAIL_BIN_DIR/trail\""
PYENV_BASH_LINE_3="export PATH=\"$PYENV_ROOT/bin:\$PATH\""
PYENV_BASH_LINE_4="# trail-pyenv-end"

install_pyenv () {
    if [ -d "$PYENV_ROOT/bin" ]; then
        export PATH=$PYENV_ROOT/bin:$PATH
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi

    if ! command -v pyenv 1>/dev/null; then
        echo "Installing pyenv..."
        curl -L https://raw.githubusercontent.com/admobilize/trail-installer/master/pyenv-installer.sh | bash 1>$DEBUG_FILE 2>&1
        echo "Done"
        export PATH=$PYENV_ROOT/bin:$PATH
        eval "$($PYENV_ROOT/bin/pyenv init -)"
        eval "$($PYENV_ROOT/bin/pyenv virtualenv-init -)"
    fi

    array=("$PYENV_BASH_LINE_1" "$PYENV_BASH_LINE_2" "$PYENV_BASH_LINE_3" "$PYENV_BASH_LINE_4")
    for LINE in "${array[@]}"; do
        if ! grep -Fxq "$LINE" $PROFILE_FILE
        then
            echo "Adding $LINE to $PROFILE_FILE"
            echo -e "$LINE" >> $PROFILE_FILE
        fi
        eval "$LINE"
    done
}

install_python () {
    if ! command -v pyenv 1>/dev/null; then
        echo "Install pyenv before trying to install python."
        exit 1
    fi
    pyenv install -s $REQUIRED_PYTHON_VERSION
    pyenv global $REQUIRED_PYTHON_VERSION
    pyenv rehash
}

create_trail_pyenv () {
    if pyenv versions | grep -q "$TRAIL_PYENV"; then
        echo "pyenv version ${TRAIL_PYENV} exists, re-create ?"
        read YES_NO
        if [ "$YES_NO" = "y" ]; then
            pyenv virtualenv-delete -f $TRAIL_PYENV
            pyenv virtualenv $REQUIRED_PYTHON_VERSION trail-cli
        fi
    else
        pyenv virtualenv $REQUIRED_PYTHON_VERSION trail-cli
    fi
}

add_admob_repo_to_pipconf () {

    PIPCONF_DIR=$(dirname $PIPCONF_FILE)
    if [ ! -d "$PIPCONF_DIR" ]; then
        mkdir -p $PIPCONF_DIR
    fi

	cat > $PIPCONF_FILE <<- EOF
	[global]
	timeout = 60
	index-url = https://$PYPI_USERNAME:$PYPI_PASSWORD@pypi.admobilize.com
EOF
    unset PYPI_USERNAME
    unset PYPI_PASSWORD
}

install_trail () {
    pyenv activate $TRAIL_PYENV
    $PYENV_TRAIL_BIN_DIR/pip install --upgrade pip
    $PYENV_TRAIL_BIN_DIR/pip install --force-reinstall --upgrade trail-core
    echo "Done"
}

install_pyenv
install_python
create_trail_pyenv
add_admob_repo_to_pipconf
install_trail

echo ""
echo "Trail installation complete!"
echo "To start using it right away, run the following command:"
echo "source $PROFILE_FILE to load the trail alias"
