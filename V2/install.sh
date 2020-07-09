#!/bin/bash
## NOTE: For mare savvy users, you culd easily do these things yourself with
## instructions, but this was designed to be easy to install by newbies :)
## Feel free to poke around and run the necessities yourself. There shouldn't
## be anything majorly intrusive, I tried to make this run happily without
## affecting a current running system. This would ideally have all been in the
## python script, but in case python3 is not installed, I do some of it here.
user=$(whoami)
arch=$(uname -m | grep arm | wc -c)
RESET="\e[0m"
MAGENTA="\e[1;35m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
WARN="\t[ ${YELLOW}WARN$RESET ]"
OK="\t[  ${GREEN}OK$RESET  ]"
FAIL="\t[ ${RED}FAIL$RESET ]"
FAILED="\t[${RED}FAILED$RESET]"
clear
echo "More detailed info is stored in install.log"
## Git would not let me commit the chmods, so they're going here....
chmod -R o-rwx *
## Check for run as root, had issues using sudo
echo -en "${MAGENTA}Root$RESET"
if [[ $user != "root" ]];
then
    echo -e "\t\t\t\t$FAIL"
    echo -e "\t${YELLOW}Please run as root$RESET"
    exit 1
else
    echo -e "\t\t\t\t$OK"
fi
## check for and install missing packages
echo -en "${MAGENTA}Packages$RESET"
failedpackage=0
for package in $(cat Package.list);
do
    if dpkg --get-selections | grep -q "^$package[[:space:]]*install$" &> /dev/null;
    then
        continue
    fi
    apt install -y $package &> install.log && continue || $failedpackage = "$failedpackage $package"
done
if [ $failedpackage -ne 0 ];
then
    echo -e "\t\t\t$FAIL"
    echo -e "Package install $FAILED to install $failedpackage"
    exit 1
fi
echo -e "\t\t\t$OK"
## check for py3, install if missing
echo -en "${MAGENTA}Python$RESET"
if [ `command -v python3 | wc -l` -lt 1 ];
then
    echo -e "\t\t\t\t$WARN"
    echo -e "\t${YELLOW}This system does not have python 3 installed, it will be installed$RESET"
    installcode=`sudo apt-get install update &>> install.log && sudo apt-get install python3 python3-dev -y &>> install.log`
    if [ $? -eq 1 ];
    then
        echo -e "Python install $FAILED, please install manually"
        exit 1
    fi
    echo -e "${MAGENTA}Python$RESET\t\t\t\t$OK"
else
    echo -e "\t\t\t\t$OK"
fi
## Check for pip and install if missing
echo -en "${MAGENTA}Pip$RESET"
if [ `command -v pip3 | wc -l` -lt 1 ];
then
    echo -e "\t\t\t\t$WARN"
    echo -e "\t${YELLOW}This system does not have pip installed, it will be installed$RESET"
    installcode=`sudo apt-get update &>> install.log && sudo apt-get install python3-pip -y &>> install.log`
    if [ $? -eq 1 ];
    then
        echo -e "\nPip install $FAILED, please install manually"
        exit 1
    fi
    echo -e "${MAGENTA}Pip$RESET\t\t\t\t$OK"
else
    echo -e "\t\t\t\t$OK"
fi
## Same again for python modules...
echo -en "${MAGENTA}Python modules$RESET"
reqmods=`egrep -rw '^(import|from)' | cut -d ' ' -f2 | sort | uniq`
notinstalled=''
for module in $reqmods;
do
    if [ -e bin/$module.py ];
    then
        continue
    fi
    python3 -c "import $module" &> /dev/null
    if [ $? -eq 0 ];
    then
        continue
    fi
    notinstalled="$notinstalled $module"
done
if [ `echo -n $notinstalled | wc -c` -gt 0 ];
then
    echo -e "\t\t\t$WARN"
    echo -e "\t${YELLOW}The following python modules will need to be installed:$RESET"
    for module in $notinstalled;
    do
        echo -e "\t$module"
    done
    echo ""
    apt-get update &>> install.log
    for module in $notinstalled;
    do
        if [ -e bin/$module.py ];
        then
            continue
        fi
        echo -e "\tInstalling $module"
        pip3 install $module &>> install.log && echo -e "\t\t${MAGENTA}pip$RESET\t$OK" || echo -e "\t\t${MAGENTA}pip$RESET\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
        apt-get install python3-$module &>> install.log && echo -e "\t\t${MAGENTA}apt$RESET\t$OK" || echo -e "\t\t${MAGENTA}apt$RESET\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
    done
else
    echo -e "\t\t\t$OK"
fi
## Create dedicate user
echo -en "${MAGENTA}Creating heatingpi user$RESET"
if [ $(id -u heatingpi &> /dev/null; echo $?) == 1 ];
then
    useradd \
    -rUm \
    -s /bin/bash \
    -c "User for managing heating control" \
    -d /usr/local/bin/HeatingPi \
    heatingpi && \
    usermod -a -G www-data heatingpi && \
    usermod -a -G gpio heatingpi && \
    chown heatingpi:www-data /usr/local/bin/HeatingPi && \
    chmod -R o-rwx /usr/local/bin/HeatingPi/
fi
echo -e "\t\t$OK"
## Give it the required perms
echo -en "${MAGENTA}Setting permissions for heatingpi$RESET"
echo "heatingpi" >> /etc/at.allow &&\
echo -e "$OK" || { echo -e "$FAIL"; exit 1; }
## Create the logfile and chown it for ease
echo -en "${MAGENTA}Creating files$RESET"
logs=0
logdir=`cat config/config.json | jq .logdir`
for log in api wui; do
    logfile=$logdir
    logfile+=`cat config/config.json | jq .logspecs.$log.filename`
    logfile=`echo $logfile | sed 's/"//g'`
    if [ ! -e $logfile ];
    then
        touch $logfile &>> install.log &&\
        chown heatingpi:www-data $logfile  &>> install.log &&\
        chmod 664 $logfile  &>> install.log &&\
        logs=$((logs+1))
    else
        logs=$((logs+1))
    fi
done
if [[ $logs -eq 2 ]]; then
    echo -e "\t\t\t$OK"
else
    echo -e "\t\t\t$FAIL"; exit 1;
fi
## Add and enable apache config
echo -en "${MAGENTA}Applying Apache2 config$RESET"
remdef=0
ls /etc/apache2/sites-enabled/000-default.conf &> /dev/null && echo "Apache default site detected, would you like to remove this? [y/n] {n}"; read remdef
if [ $remdef == 'y' ];
then
    rm -f /etc/apache2/sites-enabled/000-default.conf
fi
if [ `cat /etc/apache2/ports.conf | grep 'Listen 5000' | wc -l` -eq 0 ];
then
    echo "Listen 5000" >> /etc/apache2/ports.conf || { echo -e "\t\t$FAIL"; exit 1; }
fi
if [ ! -e /etc/apache2/sites-available/heating.conf ];
then
    cp config/heating.conf /etc/apache2/sites-available/ || { echo -e "\t\t$FAIL"; exit 1; }
fi
if [ ! -e /etc/apache2/sites-enabled/heating.conf ];
then
    a2ensite heating.conf &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
fi
systemctl restart apache2 &>> install.log &&\
echo -e "\t\t$OK" || { echo -e "\t\t$FAIL"; exit 1; }
## Now run python script
echo "Prerequisutes done. Running HeatingPi install"
if [ ! -e 'install.py' ];
then
    echo -e "${RED}Unable to run install.py${YELLOW}, please run manually$RESET"
    echo 'python3 install.py'
    exit 1
fi
python3 install.py || exit 1
## Reset git to undo any changes install made, allows for pull and upgrade
git reset --hard &> /dev/null

function sysd {
    echo -en "${MAGENTA}Adding systemd service$RESET"
    cp service/heating-pi-init.sh /usr/local/bin/ &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
    chmod +x /usr/local/bin/heating-pi-init.sh &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
    cp service/heatingPi.service /lib/systemd/system/ &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
    chmod 644 /lib/systemd/system/heatingPi.service &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
    systemctl enable heatingPi.service &>> install.log || { echo -e "\t\t$FAIL"; exit 1; }
    systemctl stop heatingPi.service &> /dev/null
    systemctl start heatingPi.service &>> /dev/null || { echo -e "\t\t$FAIL"; exit 1; }
    echo -e "\t\t$OK"
}

[[ -L "/sbin/init" ]] && sysd || echo -e "${RED}Systemd is required for the HeatingPi service.$RESET\nHeatingPi will run without it, but restarts can be unpredictable (sorry)."
myip=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
echo -e "${GREEN}Finished$RESET. Go to http://$myip/ to get started."
