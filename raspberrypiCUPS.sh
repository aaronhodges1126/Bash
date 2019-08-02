#!/bin/bash
# Request Raspberry Pi IP address
echo "Please enter server IP address:"
read serverip
echo "Please enter the new hostname for the Raspberry Pi:"
read new_hostname
scp gcp-cups-connector.config.json pi@$serverip:/home/pi/gcp-cups-connector.config.json
ssh pi@$serverip << EOF
  sudo hostname $new_hostname
  sudo apt-get update
  sudo apt-get dist-upgrade -y
  sudo apt-get install -y cups libcups2 libavahi-client3 avahi-daemon libsnmp30 google-cloud-print-connector hplip
  sudo usermod -a -G lpadmin pi
  sudo cupsctl --remote-admin --remote-any
  sudo useradd -s /usr/sbin/nologin -r -M cloud-print-connector
  sudo mkdir /opt/cloud-print-connector
  sudo ln -s /usr/bin/gcp-cups-connector /opt/cloud-print-connector/
  sudo /opt/cloud-print-connector/gcp-connector-util init -- NOT SURE IF NEEDED
  sudo mv gcp-cups-connector.config.json /opt/cloud-print-connector/
  sudo chmod 665 /opt/cloud-print-connector/gcp-cups-connector.config.json
  wget https://raw.githubusercontent.com/google/cloud-print-connector/master/systemd/cloud-print-connector.service
  sudo install -o root -m 0664 cloud-print-connector.service /etc/systemd/system
  sudo systemctl enable cloud-print-connector.service
  sudo systemctl start cloud-print-connector.service
  sudo systemctl status cloud-print-connector.service
  sudo systemctl stop cloud-print-connector.service
  sudo reboot
EOF
echo "Script finished, please verify configuration"
