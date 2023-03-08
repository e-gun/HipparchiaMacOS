#!/bin/sh

# to kill local changes
# git fetch --all
# git reset --hard master

cd ~/hipparchia_venv/HipparchiaServer/ && git pull https://github.com/e-gun/HipparchiaServer.git
cd ~/hipparchia_venv/HipparchiaBuilder/ && git pull https://github.com/e-gun/HipparchiaBuilder.git
cd ~/hipparchia_venv/HipparchiaSQLoader/ && git pull https://github.com/e-gun/HipparchiaSQLoader.git
# cd ~/hipparchia_venv/HipparchiaNIX/ && git pull https://github.com/e-gun/HipparchiaNIX.git
cd ~/hipparchia_venv/HipparchiaMacOS/ && git pull https://github.com/e-gun/HipparchiaMacOS.git
cd ~/hipparchia_venv/HipparchiaThirdPartySoftware/ && git pull https://github.com/e-gun/HipparchiaThirdPartySoftware.git
# cd ~/hipparchia_venv/HipparchiaWindows/ && git pull https://github.com/e-gun/HipparchiaWindows.git
cd ~

HIPPHOME="$HOME/hipparchia_venv"
SERVERPATH="$HIPPHOME/HipparchiaServer"
HELPERBIN="$SERVERPATH/server/externalbinaries"

U=$(uname)
A=$(uname -p)
U="${U}-${A}"

R=$(curl https://raw.githubusercontent.com/e-gun/HipparchiaGoBinaries/stable/cli_prebuilt_binaries/latest_${U}_md5.txt)
L=$(md5 $HELPERBIN/HipparchiaGoDBHelper | cut -d" " -f 4)

if [ $L != $R ]; then
  echo "md5sum of latest golang binary does not match local copy: replacing local with remote"
  cd $HELPERBIN
  wget https://github.com/e-gun/HipparchiaGoBinaries/raw/stable/cli_prebuilt_binaries/HipparchiaGoDBHelper-${U}-latest.bz2
  bunzip2 $HELPERBIN/HipparchiaGoDBHelper-${U}-latest.bz2
  mv HipparchiaGoDBHelper-${U}-latest $HELPERBIN/HipparchiaGoDBHelper
  chmod 755 $HELPERBIN/HipparchiaGoDBHelper
  cd ~
fi
