#!/bin/bash
user=$(whoami)
arch=$(uname -m | grep arm | wc -c)
if [ user != 'pi' ] && [[ $arch == *"arm"* ]];
then
    echo "This appears to be a Raspberry Pi, but you are not running this as the 'pi' user"
fi
if [[ $user != "root" ]];
then
    echo "Please enter the sudo password"
    sudoexit=`sudo echo "Yes" > /dev/null`
    if [ $? -eq 1 ]
    then
        exit 1
    fi
fi
if [ `command -v python3 | wc -l` -lt 1 ]
then
    answer='y'
    if [[ $1 != '-y' ]]; then
        echo "This system does not have python 3 installed, but it is required"
        echo "Is it OK to install python 3? (y/n) [n]"
        read answer
    fi
    if [ $answer == 'n' ]
    then
        exit 1
    fi
    installcode=`sudo apt-get install update && sudo apt-get install python3 python3-dev -y`
    if [ $? -eq 1 ]
    then
        echo "Python install failed, please install manually"
        exit 1
    fi
fi
if [ `command -v pip3 | wc -l` -lt 1 ]
then
    answer='y'
    if [[ $1 != '-y' ]]; then
        echo "This system does not have pip installed, but it is required"
        echo "Is it OK to install pip? (y/n) [n]"
        read answer
    fi
    if [ $answer == 'n' ]
    then
        exit 1
    fi
    installcode=`sudo apt-get update &> /dev/null && sudo apt-get install python3-pip -y`
    if [ $? -eq 1 ]
    then
        echo "Pip install failed, please install manually"
        exit 1
    fi
fi
reqmods=`egrep -rw '^(import|from)' | cut -d ' ' -f2 | cut -d '.' -f1 | sort | uniq`
notinstalled=''
echo "Installing the following required python modules"
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
    echo $module
done
echo -e "OK to continue? (y/n) [n] "
read packanswer
if [ $packanswer != 'y' ]
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
    sudo pip3 install $module && echo "$module installed" || echo "$module not installed"
    if [ $? == 0 ]
    then
        continue
    fi
    echo "Install failed with pip, trying install with apt"
    sudo apt-get install python3-$module && echo "$module installed" || echo "$module not installed"
    if [ $? == 0 ]
    then
        continue
    fi
    echo "Failed to install $module"
done
if [ ! -e 'install.py' ]
then
    echo "Unable to find install.py, please run manually"
    echo 'python3 install.py'
    exit 1
fi
sudo python3 install.py
