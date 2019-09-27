#!/usr/bin/env bash

set -e

REQUIRED_PYTHON_VERSION="3.7"
TRAIL_CONFIG_DIR=$HOME/.config/trailcli
BUILD_DIR=$TRAIL_CONFIG_DIR/build

if [ -f $HOME/.zshrc ]
then
	PROFILE_FILE=$HOME/.zshrc
elif [ -f $HOME/.bashrc ]
then
	PROFILE_FILE=$HOME/.bashrc
fi

echo -n "Pypi Username: "
read PYPI_USERNAME

echo -n "Pypi Password: "
read -s PYPI_PASSWORD
echo ""

PYENV_BASH_LINE_1="export PATH=$HOME/.pyenv/bin:\$PATH"
PYENV_BASH_LINE_2='eval "$(pyenv init -)"'
PYENV_BASH_LINE_3='eval "$(pyenv virtualenv-init -)"'

PIPENV_BASH_LINE_1="export PIPENV_PIPFILE=$BUILD_DIR/Pipfile"
PIPENV_BASH_LINE_2='alias trail="pipenv run trail"'

install_pyenv () {
	if ! command -v pyenv 1>/dev/null
	then
		echo "Installing pyenv..."
		curl -L https://raw.githubusercontent.com/matrix-io/trail-installer/master/pyenv-installer.sh | bash 1>/dev/null 2>&1
        echo "Done"
	fi
	array=("$PYENV_BASH_LINE_1" "$PYENV_BASH_LINE_2" "$PYENV_BASH_LINE_3")
	for LINE in "${array[@]}"; do
		if ! grep -Fxq "$LINE" $PROFILE_FILE
		then
			echo "Adding $LINE to $PROFILE_FILE"
			echo -e "$LINE" >> $PROFILE_FILE
		fi
		eval "$LINE"
	done
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
	python -m pip install --user pipenv
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
	cd $OLD_DIR
}

install_trail () {
	OLD_DIR=$(pwd)
	mkdir -p $BUILD_DIR && cd $BUILD_DIR
    PYTHON_BINARIES_PATH="$(python -m site --user-base)/bin"
	$PYTHON_BINARIES_PATH/pipenv install --python $REQUIRED_PYTHON_VERSION trail-core
	array=("$PIPENV_BASH_LINE_1" "$PIPENV_BASH_LINE_2")
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

check_pip
install_pyenv
install_pipenv
create_pipfile
install_trail
