# Trail installer scripts

```
$ sudo apt install libssl-dev zlib1g-dev libffi-devel

# On zsh
$ bash <(curl -fsSL https://raw.githubusercontent.com/admobilize/trail-installer/master/install.sh) && source ~/.zshrc

# On bash
$ bash <(curl -fsSL https://raw.githubusercontent.com/admobilize/trail-installer/master/install.sh) && source ~/.bashrc
```

## Troubleshooting

**If you experience Python build issues in Linux Debian/Ubuntu**

Make sure the following dependencies are installed: 

```
apt-get update && apt-get install --yes \
  build-essential \
  libffi-dev \
  libssl-dev \
  libreadline-dev \
  libbz2-dev \
  libsqlite3-dev \
  zlib1g-dev
```
