# Proot-distro debian

## Install Termux from F-droid (no need to install F-droid app) 
https://f-droid.org/packages/com.termux/

## Install Termux-x11 (need to log in to download)
https://github.com/termux/termux-x11/actions/workflows/debug_build.ym  

## Setup storage and update packages in Termux
```sh
termux-setup-storage
pkg update && pkg upgrade
```

## Install packages
```sh
pkg install x11-repo
pkg install termux-x11-nightly
pkg install tur-repo
pkg install pulseaudio
pkg install proot-distro
pkg install wget
pkg install git
```

## Install Debian (PRoot)
```sh
proot-distro install debian
proot-distro login debian
```

## In debian terminal
```sh
apt update -y
apt install nano adduser sudo
adduser {username}
nano /etc/sudoers
```
Duplicate line "root    ALL=(ALL:ALL) ALL"  but instead of root put your username. 

## Test if sudo privileges have been granted correctly (last command should output "root") 
```sh
su -- {username} 
whoami
sudo whoami
sudo apt install xfce4 -y
wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Uninstall/ubchromiumfix.sh && bash ubchromiumfix.sh
```

## Log out user
```sh
exit
```

## Log out root
```sh
exit
```

## In Termux (not in the Debian shell) 
```sh
wget https://raw.githubusercontent.com/LinuxDroidMaster/Termux-Desktops/main/scripts/proot_debian/startxfce4_debian.sh
nano startxfce4_debian.sh
```
Replace all occurrences of "droidmaster" with your username

## Make script executable
```sh
chmod +x startxfce4_debian.sh
```

## Login Debian with XFCE
```sh
. /startxfce4_debian.sh
```

## Alternatively, login Debian only with terminal
```sh
proot-distro login debian
```
