#!/bin/bash
user=$(whoami)
arch=$(uname -m | grep arm | wc -c)
RESET="\e[39m"
PINK="\e[35m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
WARN="\t[ \e[33mWARN\e[39m ]"
OK="\t[  \e[32mOK\e[39m  ]"
FAIL="\t[ \e[31mFAIL\e[39m ]"
FAILED="\t[\e[31mFAILED\e[39m]"

echo "More detailed info is stored in install.log"

echo -en "\e[35mRoot\e[39m"
if [[ $user != "root" ]];
then
    echo -e "\t\t\t\t$FAIL"
    echo -e "\t\e[33mPlease run as root\e[39m"
    exit 1
else
    echo -e "\t\t\t\t$OK"
fi

echo -en "\e[35mPackages\e[39m"
failedpackage=0
for package in $(cat Package.list);
do
    if dpkg --get-selections | grep -q "^$package[[:space:]]*install$" &> /dev/null;
    then
        continue
    fi
    apt install -y $package &> /dev/null && continue || $failedpackage = "$failedpackage $package"
done
if [ $failedpackage -ne 0 ];
then
    echo -e "\t\t\t$FAIL"
    echo -e "Package install $FAILED to install $failedpackage"
    exit 1
fi
echo -e "\t\t\t$OK"

echo -en "\e[35mPython\e[39m"
if [ `command -v python3 | wc -l` -lt 1 ];
then
    echo -e "\t\t\t\t$WARN"
    echo -e "\t\e[33mThis system does not have python 3 installed, it will be installed$RESET"
    installcode=`sudo apt-get install update &>> install.log && sudo apt-get install python3 python3-dev -y &>> install.log`
    if [ $? -eq 1 ];
    then
        echo -e "Python install $FAILED, please install manually"
        exit 1
    fi
    echo -e "\e[35mPython$RESET\t\t\t\t$OK"
else
    echo -e "\t\t\t\t$OK"
fi

echo -en "\e[35mPip$RESET"
if [ `command -v pip3 | wc -l` -lt 1 ];
then
    echo -e "\t\t\t\t$WARN"
    echo -e "\t\e[33mThis system does not have pip installed, it will be installed$RESET"
    installcode=`sudo apt-get update &>> install.log && sudo apt-get install python3-pip -y &>> install.log`
    if [ $? -eq 1 ];
    then
        echo -e "\nPip install $FAILED, please install manually"
        exit 1
    fi
    echo -e "\e[35mPip\e[39m\t\t\t\t$OK"
else
    echo -e "\t\t\t\t$OK"
fi

echo -en "\e[35mPython modules$RESET"
reqmods=`egrep -rw '^(import|from)' | cut -d ' ' -f2 | sort | uniq`
notinstalled=''
for module in $reqmods;
do
    if [ -e $module.py ];
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
    echo -e "\t\e[33mThe following python modules will to be installed:$RESET"
    for module in $notinstalled;
    do
        echo -e "\t$module"
    done
    echo ""
    apt-get update &>> install.log
    for module in $notinstalled;
    do
        if [ -e $module.py ];
        then
            continue
        fi
        echo -e "\tInstalling $module"
        pip3 install $module &>> install.log && echo -e "\t\t\e[35mpip$RESET\t$OK" || echo -e "\t\t\e[35mpip$RESET\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
        apt-get install python3-$module &>> install.log && echo -e "\t\t\e[35mapt$RESET\t$OK" || echo -e "\t\t\e[35mapt$RESET\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
    done
else
    echo -e "\t\t\t$OK"
fi

echo -en "\e[35mCreating heatingpi user$RESET"
if [ $(id -u heatingpi &> /dev/null; echo $?) == 1 ];
then
    useradd \
    -rU \
    -s /bin/bash \
    -c "User for managing heating control" \
    -d /usr/local/bin/HeatingPi \
    heatingpi
fi
echo -e "\t\t$OK"

echo -en "\e[35mSetting permissions for heatingpi$RESET"
echo "heatingpi" >> /etc/at.allow &&\
echo -e "$OK" || echo -e "$FAIL" && exit 1

echo -en "\e[35mCreating files\e[39m"
touch /var/log/heatingpi-error.log &&\
chown heatingpi:heatingpi /var/log/heatingpi-error.log &&\
chmod 664 /var/log/heatingpi-error.log &&\
echo "Listen 5000" >> /etc/apache2/ports.conf &&\
cp heating.conf /etc/apache/sites-available/ &&\
a2ensite heating.conf &&\
systemctl restart apache2 &> /dev/null &&\
echo -e "\t\t\t$OK" || (echo -e "\t\t\t$FAIL" && exit 1)

echo "Prerequisutes done. Running HeatingPi install"
if [ ! -e 'install.py' ];
then
    echo -e "\e[31mUnable to run install.py\e[33m, please run manually$RESET"
    echo 'python3 install.py'
    exit 1
fi
sudo python3 install.py || echo -e "\e[31mUnable to run install.py\e[33m, please run manually$RESET"
