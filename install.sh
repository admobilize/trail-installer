#!/usr/bin/env bash

set -e

if [ $# -gt 2 ]
then
    echo "Too many arguments passed."
    echo "Usage: install.sh [admobilize_pypi_username [admobilize_pypi_password]]"
    exit 1
fi

# Check if admobilize pypi username was passed
if [ "$1" ]
then
    PYPI_USERNAME=$1
    # If there's an username, check if the password was passed
    if [ "$2" ]
    then
        PYPI_PASSWORD=$2
    fi
fi

REQUIRED_PYTHON_VERSION="3.7.4"
REQUIRED_PYTHON_VERSION_MIN="3.7"
TRAIL_CONFIG_DIR=$HOME/.config/trailcli
BUILD_DIR=$TRAIL_CONFIG_DIR/build
DEBUG_FILE=/tmp/trail-installer.log

MACHINE_UNAME=$(uname -r)
if [[ $MACHINE_UNAME == *"Microsoft"* ]]
then
    MACHINE="Windows"
else
    MACHINE="Other"
fi

if [ -f $HOME/.zshrc ]
then
	PROFILE_FILE=$HOME/.zshrc
elif [ -f $HOME/.bashrc ]
then
	PROFILE_FILE=$HOME/.bashrc
fi

if [ -z "$PYPI_USERNAME" ]
then
    echo -n "Pypi Username: "
    read PYPI_USERNAME
fi

if [ -z "$PYPI_PASSWORD" ]
then
    echo -n "Pypi Password: "
    read -s PYPI_PASSWORD
fi
echo ""

PYENV_BASH_LINE_1="# trail-pyenv-start"
PYENV_BASH_LINE_2="export PATH=$HOME/.pyenv/bin:\$PATH"
PYENV_BASH_LINE_3='eval "$(pyenv init -)"'
PYENV_BASH_LINE_4='eval "$(pyenv virtualenv-init -)"'
PYENV_BASH_LINE_5="export PYENV_VERSION=$REQUIRED_PYTHON_VERSION"
PYENV_BASH_LINE_6="# trail-pyenv-end"

PIPENV_BASH_LINE_1="# trail-pipenv-start"
PIPENV_BASH_LINE_2="export PIPENV_PIPFILE=$BUILD_DIR/Pipfile"
PIPENV_BASH_LINE_3='alias trail="pipenv run trail"'
PIPENV_BASH_LINE_4='# trail-pipenv-end'

install_pyenv () {
    if [ -d "$HOME/.pyenv/bin" ]
    then
        export PATH=$HOME/.pyenv/bin:$PATH
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
	if ! command -v pyenv 1>/dev/null
	then
		echo "Installing pyenv..."
		curl -L https://raw.githubusercontent.com/matrix-io/trail-installer/master/pyenv-installer.sh | bash 1>$DEBUG_FILE 2>&1
        echo "Done"
	fi
	array=("$PYENV_BASH_LINE_1" "$PYENV_BASH_LINE_2" "$PYENV_BASH_LINE_3" "$PYENV_BASH_LINE_4" "$PYENV_BASH_LINE_5" "$PYENV_BASH_LINE_6")
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
	if ! command -v pyenv 1>/dev/null
	then
        echo "Install pyenv before trying to install python."
        exit 1
    fi
    pyenv install -s $REQUIRED_PYTHON_VERSION
    pyenv rehash
}

check_pip () {
	if ! command -v pip 1>/dev/null
	then
		echo "Pip not available. Please, install pip and run this script again."
		exit 1
	fi

}

install_pipenv () {
	echo "Installing pipenv.."
	$PYTHON -m pip install --user pipenv
}

create_pipfile () {
	OLD_DIR=$(pwd)
	mkdir -p $BUILD_DIR && cd $BUILD_DIR
	cat > Pipfile <<- EOF
	[[source]]
	name = "admobilize-pypi"
	url = "https://$PYPI_USERNAME:$PYPI_PASSWORD@pypi.admobilize.com"
	verify_ssl = true
EOF
    unset PYPI_USERNAME
    unset PYPI_PASSWORD
	cd $OLD_DIR
}

install_trail () {
	OLD_DIR=$(pwd)
	mkdir -p $BUILD_DIR && cd $BUILD_DIR
    PYTHON_BINARIES_PATH="$($PYTHON -m site --user-base)/bin"
    $PYTHON_BINARIES_PATH/pipenv install --python $REQUIRED_PYTHON_VERSION trail-core
	array=("$PIPENV_BASH_LINE_1" "$PIPENV_BASH_LINE_2" "$PIPENV_BASH_LINE_3" "$PIPENV_BASH_LINE_4")
	for LINE in "${array[@]}"; do
		if ! grep -Fxq "$LINE" $PROFILE_FILE
		then
			echo "Adding $LINE to $PROFILE_FILE"
			echo -e "$LINE" >> $PROFILE_FILE
		fi
		eval "$LINE"
	done
	cd $OLD_DIR
}

install_pyenv
install_python
PYTHON=$(pyenv which python$REQUIRED_PYTHON_VERSION_MIN)
install_pipenv
create_pipfile
install_trail
