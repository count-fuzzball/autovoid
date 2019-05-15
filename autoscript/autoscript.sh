#!/bin/bash

sudo xbps-install -Su

sudo xbps-install $(cat ./packages_list)

sudo usermod -a -G bluetooth void

sudo rm /var/service/sshd
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/bluetoothd /var/service/
sudo ln -s /etc/sv/xdm /var/service/

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

cp -rv home/conkyconfigs /home/$USER
mkdir /home/$USER/.config
cp -rv home/dotfiles/config/* /home/$USER/.config/
mkdir /home/$USER/.fluxbox
cp -rv home/dotfiles/fluxbox/* /home/$USER/.fluxbox/
mkdir /home/$USER/.fonts
cp -rv home/dotfiles/fonts/* /home/$USER/.fonts/

cp -v home/dotfiles/bash_profile /home/$USER/.bash_profile
cp -v home/dotfiles/bashrc /home/$USER/.bashrc
cp -v home/dotfiles/gtkrc-2.0 /home/$USER/.gtkrc-2.0
cp -v home/dotfiles/xsession /home/$USER/.xsession
