#!/bin/bash
echo "--------------------------------"
echo "WiFi Access Point crating script"
echo "--------------------------------"

echo "Your syetem need internet"
echo "Is internet connection OK: y/n"

echo "Installing hostapd and dnsmansq"
	sudo apt-get install hostapd dnsmasq


echo "Creating hostapd config file"
	sudo cp hostapd.conf /etc/hostapd/hostapd.conf


echo "Creating dnsmansq config file"
	sudo cp dnsmansq.conf /etc/dnsmasq.conf
	
	
echo "Creating intetface"
	sudo echo "" >> /etc/network/interfaces
	sudo echo "allow-hotplug wlan0" >> /etc/network/interfaces
	sudo echo "iface  wlan0 inet manual"  >> /etc/network/interfaces

echo "Configuring dhcpcd"
	sudo echo "" >> /etc/dhcpcd.conf
	sudo echo "interface wlan0" >> /etc/dhcpcd.conf
	sudo echo "static ip_address=192.168.0.10/24" >> /etc/dhcpcd.conf
	sudo echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf
	
echo "Creating path to hostapd config"
	#sudo echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd
	sudo sed -i "/DAEMON_CONF/c\ DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""  /etc/default/hostapd


echo "Writing udev rules....."
	#echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="rtl8192cu", ATTR{type}=="1", NAME="wlan0"' >> /lib/udev/rules.d/70-persistent-network.rules
	sudo sed -i "/rtl8192cu/c\ \"SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"rtl8192cu\", ATTR{type}==\"1\", NAME=\"wlan0\""  /lib/udev/rules.d/70-persistent-network.rules
	if [ $? == 0 ];
	then
		echo "Dev Rule exist"
	else
		sudo echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="rtl8192cu", ATTR{type}=="1", NAME="wlan0"' >> /lib/udev/rules.d/70-persistent-network.rules
	fi
	sudo modprob rtl8192cu


echo "Allow hostapd in ufw rules"	
	sudo ufw allow to any port 53
	sudo ufw allow to any port 67 proto udp
	sudo ufw allow to any port 68 proto udp

echo "Creating iptabele rules"
	sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
	sudo iptables -A FORWARD -i ppp0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i wlan0 -o ppp0 -j ACCEPT
	sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
	sudo iptables-restore < /etc/iptables.ipv4.nat


echo "WiFi AP creation done"
echo "Now connect your device and enjoy browing...."
echo "***********    	End		***************"
echo "Rebooting Now"
sudo reboot


#rtl8192cu
#rt2800usb