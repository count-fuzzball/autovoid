#!/bin/bash

#Update the install
sudo xbps-install -Su

#Install the packages
sudo xbps-install $(cat ./packages_list)

#Add user to the bluetooth group
sudo usermod -a -G bluetooth $USER

#Start services
sudo rm /var/service/sshd
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/bluetoothd /var/service/

#Stop the console terminal from appearing when xdm is started
cat <<EOF > ./Xsetup_0tmp
#!/bin/bash
dmesg | xrootconsole -fg orange --wrap -geometry 450x28+0+320 &
thingmenu -x Shutdown /sbin/shutdown Reboot /sbin/reboot &
EOF
sudo mv ./Xsetup_0tmp /usr/lib/X11/xdm/Xsetup_0

cat <<EOF > ./GiveConsoletmp
#!/bin/bash
killall xrootconsole
killall thingmenu
chown $USER /dev/console
EOF
sudo mv ./GiveConsoletmp /usr/lib/X11/xdm/GiveConsole


#Create the script to switch the bluetooth adapter on when we boot up and set it to just run once.
sudo mkdir /etc/sv/BTpwr
cat <<EOF > ./pwrrun 
#!/bin/bash
sv check dbus || exit 1
sv check bluetoothd || exit 1
sv o BTpwr
exec /sbin/bluetoothctl -- power on
EOF

sudo mv ./pwrrun /etc/sv/BTpwr/run
sleep 2
sudo ln -s /etc/sv/BTpwr /var/service/

#Copy our finely crafted (i.e hacked together!) configuration files to /home
cp -r home/conkyconfigs /home/$USER
mkdir /home/$USER/.config
cp -r home/dotfiles/config/* /home/$USER/.config/
mkdir /home/$USER/.fluxbox
cp -r home/dotfiles/fluxbox/* /home/$USER/.fluxbox/
mkdir /home/$USER/.fonts
cp -r home/dotfiles/fonts/* /home/$USER/.fonts/

#Do the same for bash profile, etc
cp home/dotfiles/bash_profile /home/$USER/.bash_profile
cp home/dotfiles/bashrc /home/$USER/.bashrc
cp home/dotfiles/gtkrc-2.0 /home/$USER/.gtkrc-2.0
cp home/dotfiles/xsession /home/$USER/.xsession
sudo cp xdm/Xresources /etc/X11/xdm/

#Start xdm
sudo ln -s /etc/sv/xdm /var/service/

#Done. Do one final reboot.
echo Rebooting now
sleep 5
sudo reboot
