#!/bin/bash

sudo xbps-install -Su

sudo xbps-install $(cat ./packages_list)

sudo usermod -a -G bluetooth $USER

sudo rm /var/service/sshd
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/bluetoothd /var/service/


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

cp -r home/conkyconfigs /home/$USER
mkdir /home/$USER/.config
cp -r home/dotfiles/config/* /home/$USER/.config/
mkdir /home/$USER/.fluxbox
cp -r home/dotfiles/fluxbox/* /home/$USER/.fluxbox/
mkdir /home/$USER/.fonts
cp -r home/dotfiles/fonts/* /home/$USER/.fonts/

cp home/dotfiles/bash_profile /home/$USER/.bash_profile
cp home/dotfiles/bashrc /home/$USER/.bashrc
cp home/dotfiles/gtkrc-2.0 /home/$USER/.gtkrc-2.0
cp home/dotfiles/xsession /home/$USER/.xsession

sudo ln -s /etc/sv/xdm /var/service/

echo Rebooting now
sleep 5
sudo reboot
