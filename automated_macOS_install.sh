#!/bin/bash

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

HIPPHOME="$HOME/hipparchia_venv"
# change $HOME? [problems on older systems]
# printf "${WHITE}Where should Hipparchia live?${NC}\n"
# read -p "Press RETURN to install in the default directory [$DEFAUTLTHIPPHOME] otherwise submit a directory PATH: " HIPPHOME
# HIPPHOME=${HIPPHOME:-$DEFAUTLTHIPPHOME}
# HIPPHOME=$DEFAUTLTHIPPHOME

printf "${WHITE}Installing to '${YELLOW}${HIPPHOME}${NC}${WHITE}'${NC} \n"

SERVERPATH="$HIPPHOME/HipparchiaServer"
BUILDERPATH="$HIPPHOME/HipparchiaBuilder"
LOADERPATH="$HIPPHOME/HipparchiaSQLoader"
BSDPATH="$HIPPHOME/HipparchiaBSD"
MACPATH="$HIPPHOME/HipparchiaMacOS"
DATAPATH="$HIPPHOME/HipparchiaData"
THIRDPARTYPATH="$HIPPHOME/HipparchiaThirdPartySoftware"
EXTRAFONTPATH="$HIPPHOME/HipparchiaExtraFonts"
WINDOWSPATH="$HIPPHOME/HipparchiaWindows"
STATIC="$SERVERPATH/server/static"
TTF="$STATIC/ttf"
THEDB="hipparchiaDB"

# install brew
BREW='/usr/local/bin/brew'

if [ -f "$BREW" ]
then
	echo "brew found; no need to install it"
else
	echo "brew not found; installing"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [ ! -f  '/usr/local/bin/git' ]; then
	$BREW install git
else
	echo "`/usr/local/bin/git --version` installed; will not ask brew to install git"
fi

GIT='/usr/local/bin/git'

# printf "testing for availability of ${YELLOW}command line tools${NC} tools"
# # git is provided by command line tools...
# $GIT --version > /dev/null
# printf "if you do not already have them installed\n"
# printf "allow the system to do the installation before you input any other information into this script\n"

# ready the installation files and directories
printf "${WHITE}preparing the installation files and directories${NC}\n"

for dir in $HIPPHOME $SERVERPATH $BUILDERPATH $LOADERPATH $BSDPATH $DATAPATH $MACPATH $WINDOWSPATH $EXTRAFONTPATH $THIRDPARTYPATH
do
	if [ ! -d $dir ]; then
		/bin/mkdir $dir
	else
		echo "$dir already exists; no need to create it"
	fi
done

if [[ ${OPTION} == 'devel' ]]; then
	cd $SERVERPATH && $GIT init && $GIT clone -b devel https://github.com/e-gun/HipparchiaServer.git
else
	cd $SERVERPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaServer.git
fi

cd $BUILDERPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaBuilder.git
cd $LOADERPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaSQLoader.git
cd $BSDPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaBSD.git
cd $MACPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaMacOS.git
cd $THIRDPARTYPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaThirdPartySoftware.git
cd $EXTRAFONTPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaExtraFonts.git
cd $WINDOWSPATH && $GIT init && $GIT pull https://github.com/e-gun/HipparchiaWindows.git

cp $MACPATH/macOS_selfupdate.sh $HIPPHOME/selfupdate.sh
chmod 700 $HIPPHOME/selfupdate.sh
cp -rp $MACPATH/macos_launch_hipparchia_application.app $HIPPHOME/launch_hipparchia.app
cp -rp $MACPATH/macos_dbload_hipparchia.app $LOADERPATH/load_hipparchia_data.app

if [ ! -f  '/usr/local/bin/python3' ]; then
	$BREW install python3
else
	echo "`/usr/local/bin/python -V` installed; will not ask brew to install python"
fi

if [ ! -f  '/usr/local/bin/psql' ]; then
	$BREW install postgresql
	$BREW services start postgresql
else
	echo "`/usr/local/bin/psql -V` installed; will not ask brew to install psql"
fi

if [ ! -f  '/usr/local/bin/wget' ]; then
	$BREW install wget
else
	echo "wget already installed; will not ask brew to install wget"
fi

if [[ ${OPTION} == 'devel' ]]; then
	$BREW install redis
	$BREW services start redis
fi

# prepare the python virtual environment
printf "${WHITE}preparing the python virtual environment${NC}\n"
/usr/local/bin/python3 -m venv $HIPPHOME
source $HIPPHOME/bin/activate
$HIPPHOME/bin/pip3 install flask psycopg2-binary websockets
# websockets 5.0.1 does not support python3.7, but master repo does...
# $HIPPHOME/bin/pip3 install https://github.com/aaugustin/websockets/archive/master.zip
if [ "$VECTORS" == "y" ]; then
	$HIPPHOME/bin/pip3 install cython scipy numpy gensim pyLDAvis matplotlib networkx
	# sklearn is also broken with python3.7 unless you go to the master repo
	$HIPPHOME/bin/pip3 install https://github.com/scikit-learn/scikit-learn/archive/master.zip
fi
if [[ ${OPTION} == 'devel' ]]; then
	$HIPPHOME/bin/pip3 install redis
fi

# build the db framework
# held off on this because we were getting here before '$BREW services start postgresql' was ready for us

/usr/local/bin/createdb -E UTF8 $THEDB
/usr/local/bin/psql -d $THEDB -a -f $BUILDERPATH/builder/sql/generate_hipparchia_dbs.sql

# harden postgresql

printf "${WHITE}hardening postgresql${NC}\n"
HBACONF='/usr/local/var/postgres/pg_hba.conf'

sed -i "" "s/local   all             all                                     trust/local   all   `whoami`   trust/" $HBACONF
sed -i "" "s/host    all             all             127.0.0.1\/32            trust/host   all   `whoami`   127.0.0.1\/32   trust/" $HBACONF

if grep hipparchiaDB $HBACONF; then
	echo "found hipparchia rules in pg_hba.conf; leaving it untouched"
else
	echo "local   $THEDB   hippa_rd,hippa_wr   password" >>  $HBACONF
	echo "host   $THEDB   hippa_rd,hippa_wr   127.0.0.1/32   password" >>  $HBACONF
fi

# set up some random passwords

SSL="/usr/bin/openssl"

WRPASS=`${SSL} rand -base64 12`
RDPASS=`${SSL} rand -base64 12`
SKRKEY=`${SSL} rand -base64 24`

# you might have regex control chars in there if you are not lucky: 'VvIUkQ9CerGTo/sx5vneHeo+PCKpx7V5'
WRPASS=`echo ${WRPASS//[^[:word:]]/}`
RDPASS=`echo ${RDPASS//[^[:word:]]/}`
SKRKEY=`echo ${SKRKEY//[^[:word:]]/}`

printf "\n\n${WHITE}setting up your passwords in the configuration files${NC}\n"

if [ ! -f "$BUILDERPATH/config.ini" ]; then
	sed "s/DBPASS = >>yourpasshere<</DBPASS = $WRPASS/" $BUILDERPATH/sample_config.ini > $BUILDERPATH/config.ini
	# note: this only works if pg_hba.conf has 'trust' in localhost for `whoami`
	/usr/local/bin/psql -d $THEDB --command="ALTER ROLE hippa_wr WITH PASSWORD '$WRPASS';"
else
	echo "oops - found old config.ini: will not change the password for hippa_wr"
	echo "nb: your OLD password is still there; you will need to change it to your NEW one ($WRPASS)"
fi

if [ ! -f "$LOADERPATH/config.ini" ]; then
	sed "s/DBPASS = yourpasshere/DBPASS = $WRPASS/" $LOADERPATH/sample_config.ini > $LOADERPATH/config.ini
fi

if [ ! -d "$SERVERPATH/settings/" ]; then
	cp -rp $SERVERPATH/server/sample_settings $SERVERPATH/server/settings
	CONFIGFILE="$SERVERPATH/server/settings/securitysettings.py"
	sed -i "" "s/DBPASS = 'yourpassheretrytomakeitstrongplease'/DBPASS = '$RDPASS'/" $CONFIGFILE
	sed -i "" "s/SECRET_KEY = 'yourkeyhereitshouldbelongandlooklikecryptographicgobbledygook'/SECRET_KEY = '$SKRKEY'/" $CONFIGFILE
	if [ "$VECTORS" == "y" ]; then
		sed -i "" "s/WRITEUSER = 'consider_re-using_HipparchiaBuilder_user'/WRITEUSER = 'hippa_wr'/" $CONFIGFILE
		sed -i "" "s/DBWRITEPASS = 'consider_re-using_HipparchiaBuilder_pass'/DBWRITEPASS = '$WRPASS'/" $CONFIGFILE
	fi
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

ZIPLIST=`ls -1 $TTF/*.zip`
for Z in $ZIPLIST; do unzip -o $Z; done

DBLSUBDIRS=`ls -d -1 $TTF/*/*/*.ttf`
for D in $DBLSUBDIRS; do mv $D $TTF/; done

INSUBDIRS=`ls -d -1 $TTF/*/*.ttf`
for F in $INSUBDIRS; do mv $F $TTF/; done

SUBDIRS=`ls -d -1 $TTF/*/`
for S in $SUBDIRS; do rm -rf $S; done

rm $TTF/*zip

# JS
cd $STATIC/
cp $THIRDPARTYPATH/minimal_installation/jquery-3.3.1.min.js $STATIC/jquery.min.js
cp $THIRDPARTYPATH/minimal_installation/jquery-ui-1.12.1.zip $STATIC/
cp $THIRDPARTYPATH/minimal_installation/js.cookie.js $STATIC/
cp $THIRDPARTYPATH/vector_helpers/*.* $STATIC/

ZIPLIST=`ls -1 $STATIC/*.zip`
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
	printf "${WHITE}fetching the lexica${NC}\n"
	mkdir $DATAPATH/lexica/
	cd $DATAPATH/lexica/
	GET="/usr/local/bin/wget"
	$GET https://community.dur.ac.uk/p.j.heslin/Software/Diogenes/Download/diogenes-linux-3.2.0.tar.bz2
	tar jxf diogenes-linux-3.2.0.tar.bz2
	mv $DATAPATH/lexica/diogenes-3.2.0/diogenes/perl/Perseus_Data/*.* $DATAPATH/lexica/
	rm -rf $DATAPATH/lexica/diogenes-3.2.0/
	mv $DATAPATH/lexica/1999.04.0057.xml $DATAPATH/lexica/greek-lexicon_1999.04.0057.xml
	mv $DATAPATH/lexica/1999.04.0059.xml $DATAPATH/lexica/latin-lexicon_1999.04.0059.xml
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
	printf "Not installed: ${RED}cython scipy numpy gensim sklearn pyLDAvis matplotlib networkx${NC}\n"
	printf "You will need to add them manually later if you turn on the relevant options in ${WHITE}config.py${NC}\n\n"
fi

printf "Additional packages are installed by executing the following command:\n\t${WHITE}${HIPPHOME}/bin/pip3 install packagename1 packagename2 packagename3 ...${NC}\n\n"

printf "\n"
printf "\n\n${WHITE}You have been assigned the following passwords:${NC}\n"
printf "\t${RED}hippa_wr${NC} password will be: ${YELLOW}${WRPASS}${NC}\n"
printf "\t${RED}hippa_rd${NC} password will be: ${YELLOW}${RDPASS}${NC}\n"
printf "\t${RED}secret key${NC} will be: ${YELLOW}${SKRKEY}${NC}\n\n"
