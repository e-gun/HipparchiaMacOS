#!/bin/bash

# bash-3.2$ ./automated_macOS-M1_install.sh standard vectors

# only need admin if you are installing homebrew?
# installing homebrew can timeout the sudo

if (sudo -vn && sudo -ln) 2>&1 | grep 'required' >/dev/null; then
  echo "run the following before executing this script (you will need admin rights and will be asked to supply a password):"
  echo "	sudo echo"
  echo
  exit 0
fi

if (sudo -vn && sudo -ln) 2>&1 | grep 'Sorry' >/dev/null; then
  echo "You do not have admin rights and will be unable to install the require packages."
  exit 0
fi

RED='\033[0;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

# $1 and $2 indicate installation type and vectors options

[[ 'standard minimal devel' =~ (^|[[:space:]])"$1"($|[[:space:]]) ]] && OPTION=$1 || OPTION='standard'

if [[ $2 == 'vectors' ]]; then
  VECTORS="y"
else
  VECTORS="n"
fi

# change $HOME? [problems on older systems]
# printf "${WHITE}Where should Hipparchia live?${NC}\n"
# read -p "Press RETURN to install in the default directory [$DEFAUTLTHIPPHOME] otherwise submit a directory PATH: " HIPPHOME
# HIPPHOME=${HIPPHOME:-$DEFAUTLTHIPPHOME}
# HIPPHOME=$DEFAUTLTHIPPHOME

printf "${WHITE}Installing to '${YELLOW}${HIPPHOME}${NC}${WHITE}'${NC} \n"

HIPPHOME="$HOME/hipparchia_venv"
SERVERPATH="$HIPPHOME/HipparchiaServer"
HELPERBIN="$SERVERPATH/server/externalbinaries"
HELPERMOD="$SERVERPATH/server/externalmodule"
BUILDERPATH="$HIPPHOME/HipparchiaBuilder"
LOADERPATH="$HIPPHOME/HipparchiaSQLoader"
NIXPATH="$HIPPHOME/HipparchiaNIX"
MACPATH="$HIPPHOME/HipparchiaMacOS"
DATAPATH="$HIPPHOME/HipparchiaData"
THIRDPARTYPATH="$HIPPHOME/HipparchiaThirdPartySoftware"
EXTRAFONTPATH="$HIPPHOME/HipparchiaExtraFonts"
WINDOWSPATH="$HIPPHOME/HipparchiaWindows"
LEXDATAPATH="$HIPPHOME/HipparchiaLexicalData"
STATIC="$SERVERPATH/server/static"
TTF="$STATIC/ttf"
THEDB="hipparchiaDB"

# install brew
BREWHOME="/opt/homebrew"
BREWBIN="${BREWHOME}/bin"
BREW="${BREWBIN}/brew"

if [ -f "$BREW" ]; then
  echo "brew found; no need to install it"
else
  echo "brew not found; installing"
  # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if [ ! -f '${BREWBIN}/git' ]; then
  $BREW install git
else
  echo "$(/usr/local/bin/git --version) installed; will not ask brew to install git"
fi

GIT="${BREWBIN}/git"

# printf "testing for availability of ${YELLOW}command line tools${NC} tools"
# # git is provided by command line tools...
# $GIT --version > /dev/null
# printf "if you do not already have them installed\n"
# printf "allow the system to do the installation before you input any other information into this script\n"

# ready the installation files and directories
printf "${WHITE}preparing the installation files and directories${NC}\n"

#for dir in $HIPPHOME $SERVERPATH $BUILDERPATH $LOADERPATH $NIXPATH $DATAPATH $MACPATH $WINDOWSPATH $EXTRAFONTPATH $THIRDPARTYPATH $LEXDATAPATH; do
#  if [ ! -d $dir ]; then
#    /bin/mkdir $dir
#  else
#    echo "$dir already exists; no need to create it"
#  fi
#done

if [ ! -d $HIPPHOME ]; then
  /bin/mkdir $HIPPHOME
fi

cd $HIPPHOME
$GIT clone https://github.com/e-gun/HipparchiaServer.git

if [[ ${OPTION} == 'devel' ]]; then
  cd $SERVERPATH
  $GIT checkout devel
  cd $HIPPHOME
fi

$GIT clone https://github.com/e-gun/HipparchiaBuilder
$GIT clone https://github.com/e-gun/HipparchiaSQLoader
$GIT clone https://github.com/e-gun/HipparchiaNIX
$GIT clone https://github.com/e-gun/HipparchiaMacOS
$GIT clone https://github.com/e-gun/HipparchiaThirdPartySoftware
$GIT clone https://github.com/e-gun/HipparchiaExtraFonts
$GIT clone https://github.com/e-gun/HipparchiaWindows
$GIT clone https://github.com/e-gun/HipparchiaLexicalData

cp $MACPATH/macOS_selfupdate.sh $HIPPHOME/selfupdate.sh
chmod 700 $HIPPHOME/selfupdate.sh
cp -rp $MACPATH/macos_launch_hipparchia_application.app $HIPPHOME/launch_hipparchia.app
cp -rp $MACPATH/macos_dbload_hipparchia.app $LOADERPATH/load_hipparchia_data.app

$BREW install python
PYTHON="${BREWBIN}/python3"

if [ ! -f '${BREWBIN}/psql' ]; then
  $BREW install postgresql
  $BREW services start postgresql
else
  echo "$(/usr/local/bin/psql -V) installed; will not ask brew to install psql"
fi

if [ ! -f '${BREWBIN}/wget' ]; then
  $BREW install wget
else
  echo "wget already installed; will not ask brew to install wget"
fi

if [ ! -f '${BREWBIN}/redis-server' ]; then
  $BREW install redis
  $BREW services start redis
fi

# prepare the python virtual environment
printf "${WHITE}preparing the python virtual environment${NC}\n"
$PYTHON -m venv $HIPPHOME
source $HIPPHOME/bin/activate


$HIPPHOME/bin/pip3 install flask websockets flask_wtf flask_login rich redis

# psycopg2 no longer does streamcopy properly (2.9.1)?
# psycopg2 is a PITA; you have to build it, but it is not easy to build
$BREW install openssl
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
$HIPPHOME/bin/pip3 install psycopg2==2.8.5

if [ "$VECTORS" == "y" ]; then
  $HIPPHOME/bin/pip3 install cython scipy numpy gensim pyLDAvis matplotlib networkx scikit-learn

  # umap-learn broken with python 3.9 (at the moment...) [because llvmlite installation will die]
  # putting this last so that you at least get the ones above properly installed
  # [see https://github.com/cvxgrp/pymde/issues/49 and https://stackoverflow.com/questions/67567987/m1-mac-how-to-install-llvm]
  arch -arm64 $BREW install llvm@11
  LLVM_CONFIG="/opt/homebrew/Cellar/llvm@11/11.1.0_4/bin/llvm-config" arch -arm64 $HIPPHOME/bin/pip3 install llvmlite
  $HIPPHOME/bin/pip3 install umap-learn
fi

# build the db framework
# held off on this because we were getting here before '$BREW services start postgresql' was ready for us

${BREWBIN}/createdb -E UTF8 $THEDB
${BREWBIN}/psql -d $THEDB -a -f $BUILDERPATH/builder/sql/generate_hipparchia_dbs.sql

# harden postgresql

printf "${WHITE}hardening postgresql${NC}\n"
HBACONF='${BREWHOME}/var/postgres/pg_hba.conf'

sed -i "" "s/local   all             all                                     trust/local   all   $(whoami)   trust/" $HBACONF
sed -i "" "s/host    all             all             127.0.0.1\/32            trust/host   all   $(whoami)   127.0.0.1\/32   trust/" $HBACONF

if grep hipparchiaDB $HBACONF; then
  echo "found hipparchia rules in pg_hba.conf; leaving it untouched"
else
  echo "local   $THEDB   hippa_rd,hippa_wr   password" >>$HBACONF
  echo "host   $THEDB   hippa_rd,hippa_wr   127.0.0.1/32   password" >>$HBACONF
fi

# set up some random passwords

SSL="/usr/bin/openssl"

WRPASS=$(${SSL} rand -base64 12)
RDPASS=$(${SSL} rand -base64 12)
SKRKEY=$(${SSL} rand -base64 24)
RUPASS=$(${SSL} rand -base64 12)

# you might have regex control chars in there if you are not lucky: 'VvIUkQ9CerGTo/sx5vneHeo+PCKpx7V5'
WRPASS=$(echo ${WRPASS//[^[:word:]]/})
RDPASS=$(echo ${RDPASS//[^[:word:]]/})
SKRKEY=$(echo ${SKRKEY//[^[:word:]]/})
RUPASS=$(echo ${RUPASS//[^[:word:]]/})

printf "\n\n${WHITE}setting up your passwords in the configuration files${NC}\n"

if [ ! -f "$BUILDERPATH/config.ini" ]; then
  sed "s/DBPASS = >>yourpasshere<</DBPASS = $WRPASS/" $BUILDERPATH/sample_config.ini >$BUILDERPATH/config.ini
  # note: this only works if pg_hba.conf has 'trust' in localhost for `whoami`
  /usr/local/bin/psql -d $THEDB --command="ALTER ROLE hippa_wr WITH PASSWORD '$WRPASS';"
else
  echo "oops - found old config.ini: will not change the password for hippa_wr"
  echo "nb: your OLD password is still there; you will need to change it to your NEW one ($WRPASS)"
fi

if [ ! -f "$LOADERPATH/config.ini" ]; then
  sed "s/DBPASS = yourpasshere/DBPASS = $WRPASS/" $LOADERPATH/sample_config.ini >$LOADERPATH/config.ini
fi

if [ ! -d "$SERVERPATH/settings/" ]; then
  cp -rp $SERVERPATH/server/sample_settings $SERVERPATH/server/settings
  CONFIGFILE="$SERVERPATH/server/settings/securitysettings.py"
  sed -i "" "s/DBPASS = 'yourpassheretrytomakeitstrongplease'/DBPASS = '$RDPASS'/" $CONFIGFILE
  sed -i "" "s/SECRET_KEY = 'yourkeyhereitshouldbelongandlooklikecryptographicgobbledygook'/SECRET_KEY = '$SKRKEY'/" $CONFIGFILE
  sed -i "" "s/WRITEUSER = 'consider_re-using_HipparchiaBuilder_user'/WRITEUSER = 'hippa_wr'/" $CONFIGFILE
  sed -i "" "s/DBWRITEPASS = 'consider_re-using_HipparchiaBuilder_pass'/DBWRITEPASS = '$WRPASS'/" $CONFIGFILE
  sed -i "" "s/DEFAULTREMOTEPASS = 'yourremoteuserpassheretrytomakeitstrongplease'/DEFAULTREMOTEPASS = '$RUPASS'/" $CONFIGFILE
  # note: this only works if pg_hba.conf has 'trust' in localhost for `whoami`
  /usr/local/bin/psql -d $THEDB --command="ALTER ROLE hippa_rd WITH PASSWORD '$RDPASS';"
else
  echo "oops - found old config.py: will not change the password for hippa_rd"
  echo "nb: your OLD password is still there; you will need to change it to your NEW one ($RDPASS)"
fi

$BREW services restart postgresql

# support files
printf "${WHITE}unpacking 3rd party support files${NC}\n"

# FONTS
cd $TTF/
cp $THIRDPARTYPATH/minimal_installation/Noto*.zip $TTF/
if [[ ${OPTION} != 'minimal' ]]; then
  cp $EXTRAFONTPATH/*.ttf $TTF/
  cp $EXTRAFONTPATH/*.zip $TTF/
  CONFIGFILE="$SERVERPATH/server/settings/htmlandcssstylesettings.py"
  sed -i "" "s/ENBALEFONTPICKER = 'no'/ENBALEFONTPICKER = 'yes'/" $CONFIGFILE
fi

ZIPLIST=$(ls -1 $TTF/*.zip)
for Z in $ZIPLIST; do unzip -o $Z; done

DBLSUBDIRS=$(ls -d -1 $TTF/*/*/*.ttf)
for D in $DBLSUBDIRS; do mv $D $TTF/; done

INSUBDIRS=$(ls -d -1 $TTF/*/*.ttf)
for F in $INSUBDIRS; do mv $F $TTF/; done

SUBDIRS=$(ls -d -1 $TTF/*/)
for S in $SUBDIRS; do rm -rf $S; done

rm $TTF/*zip

# JS
cd $STATIC/
cp $THIRDPARTYPATH/minimal_installation/jquery-3.6.0.min.js $STATIC/jquery.min.js
cp $THIRDPARTYPATH/minimal_installation/jquery-ui-1.12.1.zip $STATIC/
cp $THIRDPARTYPATH/minimal_installation/js.cookie.js $STATIC/
cp $THIRDPARTYPATH/vector_helpers/*.* $STATIC/

ZIPLIST=$(ls -1 $STATIC/*.zip)
for Z in $ZIPLIST; do unzip -o $Z; done
rm $STATIC/*zip
rm $STATIC/*md
rm $STATIC/LICENSE
rm $STATIC/d3.js
mv $STATIC/d3.min.js $STATIC/jsd3.js
mv $STATIC/ldavis.v1.0.0.js $STATIC/jsforldavis.js
cp $STATIC/jquery-ui-1.12.1/j* $STATIC/
cp $STATIC/jquery-ui-1.12.1/images/*.png $STATIC/images/
rm -rf $STATIC/jquery-ui-1.12.1/

if [ ! -d "$DATAPATH/lexica" ]; then
  mkdir $DATAPATH/lexica/
  cd $DATAPATH/lexica/
  cp $LEXDATAPATH/*.gz $DATAPATH/lexica/
  gunzip $DATAPATH/lexica/*.gz
fi

printf "\n\n${RED}CONGRATULATIONS: You have installed the Hipparchia framework${NC}\n[provided you did not see any show-stopping error messages above...]\n\n"
printf "[A1] If you are ${WHITE}building${NC}, make sure that your ${YELLOW}data files${NC} are all in place\nand that their locations reflect the values set in:\n\t${YELLOW}$BUILDERPATH/config.ini${NC}\n\n"
printf "after that you can execute the following in the Terminal.app:\n"
printf "\t${WHITE}cd $BUILDERPATH && $HIPPHOME/bin/python3 ./makecorpora.py${NC}\n\n"
printf "[A2] Alternately you are ${WHITE}reloading${NC}. Make sure that your ${YELLOW}sqldump files${NC} are all in place\nand that their locations reflect the values set in:\n\t${YELLOW}$LOADERPATH/config.ini${NC}\n\n"
printf "after that you can double-click ${WHITE}load_hipparchia_data.app${NC} which is located at:\n\t${WHITE}${LOADERPATH}${NC}\n\n"
printf "[B] Once the databases are loaded all you need to do is double-click ${WHITE}launch_hipparchia.app${NC}\nThis app is presently located at:\n\t${WHITE}${HIPPHOME}${NC}\n\n"
printf "\n"
printf "Not installed: ${RED}tensorflow${NC}\n"
printf "You will need to add this manually later if you turn on the relevant option in ${WHITE}config.py${NC}\n\n"

if [ "$VECTORS" != "y" ]; then
  printf "Not installed: ${RED}cython scipy numpy gensim sklearn pyLDAvis matplotlib networkx umap-learn${NC}\n"
  printf "You will need to add them manually later if you turn on the relevant options in ${WHITE}config.py${NC}\n\n"
fi

cd $SERVERPATH/server
rm -rf $HELPERMOD
wget https://github.com/e-gun/HipparchiaGoBinaries/raw/stable/cli_prebuilt_binaries/HipparchiaGoDBHelper-Darwin-latest.bz2
wget https://github.com/e-gun/HipparchiaGoBinaries/raw/stable/module/golangmodule-Darwin-latest.tbz
tar jxf ./golangmodule-Darwin-latest.tbz
rm ./golangmodule-Darwin-latest.tbz
mv ./golangmodule-Darwin-latest $HELPERMOD
bunzip2 HipparchiaGoDBHelper-Darwin-latest.bz2
mv HipparchiaGoDBHelper-Darwin-latest $HELPERBIN/HipparchiaGoDBHelper
chmod 755 $HELPERBIN/HipparchiaGoDBHelper

printf "Additional packages are installed by executing the following command:\n\t${WHITE}${HIPPHOME}/bin/pip3 install packagename1 packagename2 packagename3 ...${NC}\n\n"

printf "\n"
printf "\n\n${WHITE}You have been assigned the following passwords:${NC}\n"
printf "\t${RED}hippa_wr${NC} password will be: ${YELLOW}${WRPASS}${NC}\n"
printf "\t${RED}hippa_rd${NC} password will be: ${YELLOW}${RDPASS}${NC}\n"
printf "\t${RED}secret key${NC} will be: ${YELLOW}${SKRKEY}${NC}\n\n"
