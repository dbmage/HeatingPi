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
FAIL="\t[\e[31mFAILED\e[39m]"

echo -en "\e[35mUser\e[39m"
if [ user != 'pi' ] && [[ $arch == *"arm"* ]];
then
    echo -e "\t\t$WARN"
    echo -e "\t\e[33mThis appears to be a Raspberry Pi, but you are not running this as the 'pi' user\e[39m"
else
    echo -e "\t\t$OK"
fi
if [[ $user != "root" ]];
then
    echo -en "\e[35mSudo\e[39m"
    sudoexit=`sudo echo "Yes" > /dev/null`
    if [ $? -eq 1 ]
    then
        echo -e "\t\t$FAIL"
        exit 1
    fi
    echo -e "\t\t$OK"
fi
echo -en "\e[35mPython\e[39m"
if [ `command -v python3 | wc -l` -lt 1 ];
then
    echo -e "\t\t$WARN"
    answer='y'
    if [[ $1 != '-y' ]]; then
        echo -e "\t\e[33mThis system does not have python 3 installed, but it is required\e[39m"
        echo "Is it OK to install python 3? (y/n) [n]"
        read answer
    fi
    if [ $answer == 'n' ];
    then
        exit 1
    fi
    installcode=`sudo apt-get install update && sudo apt-get install python3 python3-dev -y`
    if [ $? -eq 1 ];
    then
        echo -e "Python install \e[31mfailed\e[39m, please install manually"
        exit 1
    fi
    echo -e "\e[35mPython\e[39m\t\t$OK"
else
    echo -e "\t\t$OK"
fi
echo -en "\e[35mPip\e[39m"
if [ `command -v pip3 | wc -l` -lt 1 ];
then
    echo -e "\t\t$WARN"
    answer='y'
    if [[ $1 != '-y' ]]; then
        echo -e "\t\e[33mThis system does not have pip installed, but it is required\e[39m"
        echo -n "\tIs it OK to install pip? (y/n) [n]  "
        read answer
    fi
    if [ $answer == 'n' ];
    then
        exit 1
    fi
    installcode=`sudo apt-get update &> /dev/null && sudo apt-get install python3-pip -y`
    if [ $? -eq 1 ];
    then
        echo -e "\nPip install \e[31mfailed\e[39m, please install manually"
        exit 1
    fi
    echo -e "\e[35mPip\e[39m\t\t$OK"
else
    echo -e "\t\t$OK"
fi
reqmods=`egrep -rw '^(import|from)' | cut -d ' ' -f2 | cut -d '.' -f1 | sort | uniq`
notinstalled=''
echo -en "\e[35mPython modules\e[39m"
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
    echo -e "\t$WARN"
    echo -e "\t\e[33mThe following python modules need to be installed:\e[39m"
    for module in $notinstalled;
    do
        echo -e "\t$module"
    done
    echo -en "\n\tOK to continue? (y/n) [n]  "
    read packanswer
    if [ $packanswer != 'y' ];
    then
        exit 1
    fi
    sudo apt-get update &> /dev/null
    for module in $notinstalled;
    do
        if [ -e $module.py ];
        then
            continue
        fi
        echo -e "\tInstalling $module"
        sudo pip3 install $module && echo -e "\t\t\e[35mpip\e[39m\t$OK" || echo -e "\t\t\e[35mpip\e[39m\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
        sudo apt-get install python3-$module && echo -e "\t\t\e[35mapt\e[39m\t$OK" || echo -e "\t\t\e[35mapt\e[39m\t$FAILED"
        if [ $? == 0 ];
        then
            continue
        fi
    done
else
    echo -e "\t$OK"
fi
echo "Prerequisutes done. Running HeatingPi install"
if [ ! -e 'install.py' ];
then
    echo -e "\e[31mUnable to find install.py\e[33m, please run manually\e[39m"
    echo 'python3 install.py'
    exit 1
fi
sudo python3 install.py || echo -e "\e[31mUnable to run install.py\e[33m, please run manually\e[39m"
