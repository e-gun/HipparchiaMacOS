#!/bin/sh

# to kill local changes
# git fetch --all
# git reset --hard master

cd ~/hipparchia_venv/HipparchiaServer/ && git pull https://github.com/e-gun/HipparchiaServer.git
cd ~/hipparchia_venv/HipparchiaBuilder/ && git pull https://github.com/e-gun/HipparchiaBuilder.git
cd ~/hipparchia_venv/HipparchiaSQLoader/ && git pull https://github.com/e-gun/HipparchiaSQLoader.git
cd ~/hipparchia_venv/HipparchiaNIX/ && git pull https://github.com/e-gun/HipparchiaNIX.git
cd ~/hipparchia_venv/HipparchiaMacOS/ && git pull https://github.com/e-gun/HipparchiaMacOS.git
cd ~/hipparchia_venv/HipparchiaThirdPartySoftware/ && git pull https://github.com/e-gun/HipparchiaThirdPartySoftware.git
cd ~/hipparchia_venv/HipparchiaWindows/ && git pull https://github.com/e-gun/HipparchiaWindows.git
cd ~
