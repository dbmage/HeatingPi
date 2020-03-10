#!/bin/bash
user=$(whoami)
arch=$(uname -m | grep arm | wc -c)
if [ user != 'pi' ] && [[ $arch == *"arm"* ]];
then
    echo "This appears to be a Raspberry Pi, but you are not running this as the 'pi' user"
fi
if [[ $user != "root"]];
then
    echo "Please enter the sudo password"
    sudoexit=`sudo echo "Yes" > /dev/null`
    if [ $? -eq 1 ]
    then
        return
    fi
fi
if [ ! command -v python3 &>/dev/null ]
then
    answer = 'y'
    if $1 != '-y'; then
        echo "This system does not have python 3 installed, but it is required"
        echo "Is it OK to install python 3? (y/n) [n]"
        read answer
    fi
    if [ $answer == 'n' ]
    then
        return
    fi
    installcode=`sudo apt-get install update && sudo apt-get install python3 python3-dev -y`
    if [ $? -eq 1 ]
    then
        echo "Python install failed, please install manually"
        return
    fi
fi
if [ ! command -v pip3 &> /dev/null ]
then
    answer = 'y'
    if $1 != '-y'; then
        echo "This system does not have pip installed, but it is required"
        echo "Is it OK to install pip? (y/n) [n]"
        read answer
    fi
    if [ $answer == 'n' ]
    then
        return
    fi
    installcode=`sudo apt-get install update && sudo apt-get install python3-pip -y`
    if [ $? -eq 1 ]
    then
        echo "Pip install failed, please install manually"
        return
    fi
fi
reqpacks=`cat *.py | egrep '^(import|from)' | cut -d ' ' -f2 | sort | uniq`
echo "Installing the following required python packages"
for package in $rqpacks;
do
    if [ -e $package.py ];
    then
        continue
    fi
    echo $package
fi
echo -e "OK to continue? (y/n) [n] "
read packanswer
if [ $packanswer != 'y' ]
then
    return
fi
for package in $rqpacks;
do
    if [ -e $package.py ];
    then
        continue
    fi
    sudo pip3 install $package
    if [ $? == 0 ]
    then
        continue
    fi
    echo "Install failed with pip, trying install with apt"
    sudo apt-get install python3-$package
    if [ $? == 0 ]
    then
        continue
    fi
    echo "Failed to install $package"
fi
if [ ! -e 'install.py' ]
then
    echo "Unable to find install.py, please run manually"
    echo 'python3 install.py'
    return
fi
sudo python3 install.py
