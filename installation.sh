#!/bin/bash -i

runinstall (){
#============================#
# Install Dependencies [APT] #
#============================#
sudo echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >> /etc/apt/sources.list
sudo wget -q https://kali.download/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2024.1_all.deb
sudo dpkg -i kali-archive-keyring_2024.1_all.deb
rm -rf kali-archive-keyring_2024.1_all.deb
sudo apt -y update
sudo apt -y install git make gcc dnsutils

#====================#
# API KEYS & Configs #
#====================#
echo -e "\nDon't forget to add extra API keys to /root/.config/subfinder/provider-config.yaml\n"
echo -e "\nAnd setup your notify config for notifcations here: /root/.config/notify/provider-config.yaml\n"

#================================#
# Install Golang & Google Chrome #
#================================#
DL_HOME=https://golang.org
echo -e "\n[+] Finding latest version of go\n"
DL_PATH_URL="$(wget --no-check-certificate -qO- https://golang.org/dl/ | grep -oP '\/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1)" 
latest="$(echo $DL_PATH_URL | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"
echo -e "\n[+] Downloading latest go version: ${latest}\n"
wget -q --no-check-certificate --continue "$DL_HOME$DL_PATH_URL"
sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go*.gz
sudo apt remove -y golang-go
sudo rm ./go*.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> /root/.profile
source /root/.profile
echo -e "\n[+] Finding latest version of Chrome\n"
wget --no-check-certificate -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -qq ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb

#===================#
# Golang Config & Tools #
#===================#
export GO111MODULE=on

echo -e "\n[+] Installing Nuclei by ProjectDiscovery\n"
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

echo -e "\n[+] Installing httpx by ProjectDiscovery\n"
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

echo -e "\n[+] Installing Notify by ProjectDiscovery\n"
go install github.com/projectdiscovery/notify/cmd/notify@latest

echo -e "\n[+] Installing subfinder by ProjectDiscovery\n"
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo -e "\n[+] Installing gowitness by sensepost\n"
go install github.com/sensepost/gowitness@latest

echo -e "\n[+] Installing dalfox by hahwul\n"
go install github.com/hahwul/dalfox/v2@latest

echo -e "\n[+] Installing gau by lc\n"
go install github.com/lc/gau/v2/cmd/gau@latest

echo -e "\n[+] Installing masscan by robertdavidgraham\n"
apt install -qq git gcc make libpcap-dev -y
git clone https://github.com/robertdavidgraham/masscan.git
(cd masscan && make && make install)
rm -rf masscan

}

#==================#
# Checking if root #
#==================#
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
  else runinstall
fi
