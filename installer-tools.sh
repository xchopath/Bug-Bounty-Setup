#!/usr/bin/env bash

if [[ $(whoami) != "root" ]]; then
	echo "ERROR: Must run as root"
	exit
fi

apt install jq tmux -y

## INSTALL GO
#GO_DEV_END=$(curl -s "https://go.dev/dl/" | grep -B4 $(uname -m | sed 's/_/-/g') | grep '/dl/' | grep $(uname | tr '[:upper:]' '[:lower:]') | grep -Po 'href="\K.*?(?=")' | head -1)
#wget "https://go.dev${GO_DEV_END}"
#GO_BIN_ZIP=$(echo "${GO_DEV_END}" | awk -F '/' '{print $3}')
#tar -xvf ${GO_BIN_ZIP}
#mv go /usr/local
#ln -sf /usr/local/go/bin/go /usr/bin/go


curl -s "https://api.github.com/repos/projectdiscovery/katana/releases/latest" | grep "katana_.*_linux_amd64.zip" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip -o $(ls | grep katana_ | grep zip$)
mv katana /usr/local/bin/

curl -s "https://api.github.com/repos/projectdiscovery/nuclei/releases/latest" | grep "nuclei_.*_linux_amd64.zip" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip -o $(ls | grep nuclei_ | grep zip$)
mv nuclei /usr/local/bin/

nuclei

curl -s "https://api.github.com/repos/projectdiscovery/subfinder/releases/latest" | grep "subfinder_.*_linux_amd64.zip" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip -o $(ls | grep subfinder_ | grep zip$)
mv subfinder /usr/local/bin/

curl -s "https://api.github.com/repos/lc/gau/releases/latest" | grep "gau_.*_linux_amd64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
tar -xvf $(ls | grep gau_ | grep \.tar\.gz$)
mv gau /usr/local/bin/
wget "https://raw.githubusercontent.com/lc/gau/master/.gau.toml" -O ~/.gau.toml

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
apt-get -f install
dpkg -i google-chrome-stable_current_amd64.deb

curl -s "https://api.github.com/repos/sensepost/gowitness/releases/latest" | grep "gowitness-.*-linux-amd64" | cut -d : -f 2,3 | tr -d \" | wget -qi -
mv $(ls | grep gowitness | grep "linux") gowitness
chmod +x gowitness
mv gowitness /usr/local/bin/

curl -s "https://api.github.com/repos/projectdiscovery/httpx/releases/latest" | grep "httpx_.*_linux_amd64.zip" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip -o $(ls | grep httpx_ | grep zip$)
mv httpx /usr/local/bin/

curl -s "https://api.github.com/repos/chaitin/xray/releases/latest" | grep "xray_linux_amd64.zip" | cut -d : -f 2,3 | tr -d \" | wget -qi -
unzip -o $(ls | grep xray_linux_amd64 | grep zip$)
chmod +x xray_linux_amd64
mv xray_linux_amd64 xray
./xray
