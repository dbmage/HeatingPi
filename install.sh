#!/bin/bash
user=$(whoami)
arch=$(uname -m | grep arm | wc -c)
RESET="\e[39m"
PINK="\e[35m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
WARN="\t[ \e[33mWARN\e[39m ]\n"
OK="\t[  \e[33mOK\e[39m  ]\n"
FAIL="\t[ \e[31mFAIL\e[39m ]\n"
echo -e "\e[35mUser\e[39m"
if [ user != 'pi' ] && [[ $arch == *"arm"* ]];
then
    echo -e $WARN
    echo -e "\t\e[33mThis appears to be a Raspberry Pi, but you are not running this as the 'pi' user\e[39m"
else
    echo -e $OK
fi
if [[ $user != "root" ]];
then
    echo -e "\e[35mSudo\e[39m"
    sudoexit=`sudo echo "Yes" > /dev/null`
    if [ $? -eq 1 ]
    then
        echo -e $FAIL
        exit 1
    fi
    echo -e $OK
fi
echo -e "\e[35mPython\e[39m"
if [ `command -v python3 | wc -l` -lt 1 ];
then
    echo -e $WARN
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
else
    echo -e $OK
fi
echo -e "\e[35mPip\e[39m"
if [ `command -v pip3 | wc -l` -lt 1 ];
then
    echo -e $WARN
    answer='y'
    if [[ $1 != '-y' ]]; then
        echo -e "\e[33mThis system does not have pip installed, but it is required\e[39m"
        echo -n "Is it OK to install pip? (y/n) [n]  "
        read answer
    fi
    if [ $answer == 'n' ];
    then
        exit 1
    fi
    installcode=`sudo apt-get update &> /dev/null && sudo apt-get install python3-pip -y`
    if [ $? -eq 1 ];
    then
        echo -e "Pip install \e[31mfailed\e[39m, please install manually"
        exit 1
    fi
else
    echo -e $OK
fi
reqmods=`egrep -rw '^(import|from)' | cut -d ' ' -f2 | cut -d '.' -f1 | sort | uniq`
notinstalled=''
echo -e "\e[35mPython modules\e[39m"
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
if [ `echo $notinstalled | wc -c` -gt 0 ];
then
    echo -e $WARN
    echo -e "\n\e[33mThe following python modules need to be installed:\e[39m\n"
    for module in $notinstalled;
    do
        echo $module
    done
    echo -en "\nOK to continue? (y/n) [n]  "
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
        echo "Installing $module"
        sudo pip3 install $module && echo -e "\t\e[35mpip\e[39m\t[  \e[32mOK\e[39m  ]\n" || echo -e "\t\e[35mpip\e[39m\t[\e[31mFAILED\e[39m]\n"
        if [ $? == 0 ];
        then
            continue
        fi
        sudo apt-get install python3-$module && echo -e "\tapt\t[  \e[32mOK\e[39m  ]\n" || echo -e "\tapt\t[\e[31mFAILED\e[39m]\n"
        if [ $? == 0 ];
        then
            continue
        fi
    done
else
    echo -e $OK
fi
echo "Prerequisutes done. Running HeatingPi install"
if [ ! -e 'install.py' ];
then
    echo -e "\e[31mUnable to find install.py\e[33m, please run manually\e[39m"
    echo 'python3 install.py'
    exit 1
fi
sudo python3 install.py
