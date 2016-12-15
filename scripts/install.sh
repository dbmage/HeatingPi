#!/bin/bash
whoami=$(whoami)
dir=$(pwd | rev | cut -d "/" -f1 | rev)
a=1
ip=$(ifconfig eth0 | grep 'inet addr' | cut -d":" -f2 | cut -d" " -f1 | awk '{ print $1 }')


## Pre checks ##
if [ $1 ] && [ $1 == "-nonpi" ]; then
    arch=1
else
    arch=$(uname -m | grep arm | wc -c)
fi
if [ $whoami != "root" ]; then ## check runnning as root
        echo "Please run as root"
        exit 1
fi
if [ $dir != "scripts" ]; then ## confirm correct folder
    echo "Cannot find required files"
    echo "Are you in the 'scripts' folder?"
    exit 1
fi
if [ $arch == 0 ]; then
    echo "This device does not appear to be a Pi"
    echo "Only Raspberry Pis are currently supported"
    echo "If you wish to continue please run with '-nonpi'"
    exit 1
fi
## 
cd ..
where=$(pwd)

function ipset {
    echo "Setting HeatingPi IP..."
    if [[ $ip =~ "0\." ]]; then
        cp ipzero.txt /etc/network/interfaces
        $ip = "192.168.0.100"
    elif [[ $ip =~ "1\." ]]; then
        cp ipone.txt /et/network/interfaces
        $ip = "192.168.1.100"
    else
        echo "Unable to detect IP address scheme"
        echo "Setting IP to DHCP"
    fi
}

function croninstall {
    echo "Installing crons..."
    crontab crons/root.cron || { echo "Root cron install failed" && echo $FUNCNAME > ./.progress && exit 1; }
    runuser -l heatingpi -c "crontab $where/crons/heatingpi.cron" || { echo "HeatingPi cron install failed" && echo $FUNCNAME > ./.progress && exit 1; }
    echo "done"
    ipset
}

function installpacks {
    echo "Installing packages..."
    apt-get -qqq -y install $(< Package.list)  || { echo "Package install failed" && echo $FUNCNAME > ./.progress && exit 1; }
    echo "done"
    croninstall
}

function aptprep {
    echo "Preparing apt for package installs..."
    echo "## Webmin apt repo##" >> /etc/apt/sources.list
    wget -q http://www.webmin.com/jcameron-key.asc
    echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
    apt-key add jcameron-key.asc
    apt-get -qqq update || { echo "Apt preparation failed" && echo $FUNCNAME > ./.progress && exit 1; }
    echo "done"
    installpacks
}

function setuserpw {
    echo "heatingpi:$firstpw" > pass.txt
    chpasswd < pass.txt || { echo "Failed to set password" && echo $FUNCNAME > ./.progress && exit 1; }
    rm pass.txt
    echo "done"
    aptprep
}

function addusertopi {
    echo "Adding user 'heatingpi'..."
    useradd heatingpi -m -s /bin/bash || { echo "Failed to add user" && echo $FUNCNAME > ./.progress && exit 1; }
    setuserpw
}

function copyingstuff {
    echo -e "\nCopying files..."
    ( cp -r scripts/ /scripts/ && cp -r www/ /var/ && cp *.php /var/ ) || { echo "Copying failed" && echo $FUNCNAME > ./.progress && exit 1; }
    echo "done"
    addusertopi
}

function whatuse {
    echo -n "Will you be using the system for heating only or hot water too? (h/hw) [h]"
    read usage
    if [[ $usage eq "" || $usage eq "h" ]]; then
        mv www/index1h.php www/index1.php
    else if [[ $usage eq "hw" ]]; then
        mv www/index1hw.php www/index1.php
    else
        echo "Incorrect answer... QUITTING!" && echo $FUNCNAME > ./.progress && exit 1
    fi
    copyingstuff
}

function setpassword { ## Get password for heating control user ##
    while [[ $a == "1" ]]; do
        echo -n "Please enter a password for the heating control user: "
        read -s firstpw
        echo
        echo -n "Re-enter the password: "
        read -s secondpw
        if [ $firstpw == $secondpw ]; then
            a=2
        fi
    done
    sed -i "s/PASSWORDGOESHERE/$firstpw/g" pp*.php
    whatuse
}

## Main function ##
if [ -e ./.progress ]; then
    cont=$(cat .progress)
    $cont
else
    setpassword
fi

echo "Complete!"
echo -e "You can now access the control page by going to \"http://$ip/\" on your phone/laptop/tablet etc.\n"
##
