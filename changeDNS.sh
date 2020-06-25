#!/bin/sh

# Parts of this script depends on:
#     ripgrep (rg): https://github.com/BurntSushi/ripgrep 
	# rg can probably be substituted easily with GNU grep.
# AdguardHome: https://github.com/AdguardTeam/AdGuardHome
#     nextdns: https://github.com/nextdns/nextdns
#         dig: https://man.openbsd.org/dig (available in package dnsutils on debian linux)


RED='\033[91m'
GREEN='\033[92m'
GREEN_solid='\033[42m'
CYAN='\033[96m'
NC='\033[0m'

# Define NextDNS config here:
nextdns_config=''

DNScheck()
{
  echo "${CYAN}[!]${NC}Checking DNS resolution:"
  dig google.com +noall +answer +stats | awk '$3 == "IN" && $4 == "A"{ip=$5}/Query time:/{t=$4 " " $5}/SERVER:/{serv=$3} END{print "\nIP (Google):"ip, "\nTime: "t, "\nDNS server: "serv}'
}

echo "${CYAN}Checking if ADG or NextDNS is running...${NC}"
ps -ax | rg "[A]dGuardHome|[n]extdns"

echo "${GREEN_solid}\nChoose an option to change your DNS server:${NC}\c"

printf '
1. PiHole             2. Adguard
3. NextDNS            4. UncensoredDNS
5. Custom DNS         6. Reset DNS
7. Show current DNS   8. Test DNS 
Enter: ';

read var;

if [ "$var" -eq "1" ]; then
	networksetup -setdnsservers Wi-Fi 192.168.100.27 fd5c:c307:7993:db00:2e0:4cff:fe6b:1f4
	echo "[✓]${GREEN}PiHole set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	DNScheck
fi

if [ "$var" -eq "2" ]; then
	echo ""
	echo "${CYAN}Check Adguard Status below:${NC}"
	ps -ax | rg "[A]dGuardHome"
	if [ $? -ne 0 ]; then
		echo "   [✓]${GREEN}Adguard isn't running.${NC}"
	fi
	echo ""
	printf '1. Adguard WORLD
2. Adguard UTU
3. Turn OFF
4. Exit
Enter: ';
	read inp;
	echo ""
	if [ "$inp" -eq "1" ]; then
		tmux kill-session -t Adguard
		ps -ax | rg "[A]dGuardHome"
		if [ $? -eq 0 ]; then
			echo "${RED}[x]${NC}AdguardHome wasn't terminated properly.[${RED}↑${NC}]"
			echo "${CYAN}[✼]${NC}Requires root access."
			sudo killall AdGuardHome
			sudo -k # signs out of root
			if [ $? -eq 0 ]; then
				echo "[✓]Previously running ${GREEN}AdGuardHome${NC} instance(s) were ${RED}terminated${NC}."
			fi
			if [ $? -ne 0 ]; then
				echo "[x]${RED}Could not terminate${NC} previous ADG instances."
			fi
		fi
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		cp ~/AdGuardHome_MacOS/AdGuardHome-WORLD.yaml ~/AdGuardHome_MacOS/AdGuardHome.yaml
		echo "${GREEN}[⥉]${NC}Starting ADG"
		cd ~/AdGuardHome_MacOS
		networksetup -setdnsservers Wi-Fi empty
		chksum_web=$(curl -s https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/MyBlocklist.checksum)
		chksum_local=$(md5 -q MyBlocklist.txt)
		if [ -f MyBlocklist.txt ] && [ "$chksum_web" == "$chksum_local" ]; then
				echo "${GREEN}MyBlocklist Unchanged. Skipping download.${NC}"
		else
			echo "${CYAN}Getting Myblocklist${NC}"
			curl -OJL 'https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/MyBlocklist.txt.xz'
			xz -fd MyBlocklist.txt.xz
		fi
		chksum_web=$(curl -s https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/facebook_block.checksum)
		chksum_local=$(md5 -q facebook_block.txt)
		if [ "$chksum_web" == "$chksum_local" ] && [ -f facebook_block.txt ]; then
			echo "${GREEN}Facebook blocklist Unchanged. Skipping download.${NC}"
		else
			echo "${CYAN}Getting Facebook blocklist${NC}"
			curl -OJL 'https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/facebook_block.txt.xz'
			xz -fd facebook_block.txt.xz
		fi
		tmux new-session -s Adguard "sudo ~/AdGuardHome_MacOS/AdGuardHome"
		networksetup -setdnsservers Wi-Fi 127.0.0.1
		echo "[✓]${GREEN}Adguard set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		DNScheck
	fi
	if [ "$inp" -eq "2" ]; then
		tmux kill-session -t Adguard
		ps -ax | rg "[A]dGuardHome"
		if [ $? -eq 0 ]; then
			echo "${RED}[x]${NC}AdguardHome wasn't terminated properly.[${RED}↑${NC}]"
			echo "${CYAN}[✼]${NC}Requires root access."
			sudo killall AdGuardHome
			sudo -k # signs out of root
			if [ $? -eq 0 ]; then
				echo "[✓]Previously running ${GREEN}AdGuardHome${NC} instance(s) were ${RED}terminated${NC}."
			fi
			if [ $? -ne 0 ]; then
				echo "[x]${RED}Could not terminate${NC} previous ADG instances."
			fi
		fi
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		cp ~/AdGuardHome_MacOS/AdGuardHome-Work.yaml ~/AdGuardHome_MacOS/AdGuardHome.yaml
		echo "${GREEN}[⥉]${NC}Starting ADG"
		networksetup -setdnsservers Wi-Fi  empty
		cd ~/AdGuardHome_MacOS
		chksum_web=$(curl -s https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/MyBlocklist.checksum)
		chksum_local=$(md5 -q MyBlocklist.txt)
		if [ -f MyBlocklist.txt ] && [ "$chksum_web" == "$chksum_local" ]; then
				echo "${GREEN}MyBlocklist Unchanged. Skipping download.${NC}"
		else
			echo "${CYAN}Getting Myblocklist${NC}"
			curl -OJL 'https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/MyBlocklist.txt.xz'
			xz -fd MyBlocklist.txt.xz
		fi
		chksum_web=$(curl -s https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/facebook_block.checksum)
		chksum_local=$(md5 -q facebook_block.txt)
		if [ "$chksum_web" == "$chksum_local" ] && [ -f facebook_block.txt ]; then
			echo "${GREEN}Facebook blocklist Unchanged. Skipping download.${NC}"
		else
			echo "${CYAN}Getting Facebook blocklist${NC}"
			curl -OJL 'https://gitlab.com/robocopAlpha/pihole_lists/-/raw/master/facebook_block.txt.xz'
			xz -fd facebook_block.txt.xz
		fi
		tmux new-session -s Adguard "sudo ~/AdGuardHome_MacOS/AdGuardHome"
		networksetup -setdnsservers Wi-Fi 127.0.0.1
		echo "[✓]${GREEN}Adguard set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		DNScheck
	fi
	if [ "$inp" -eq "3" ]; then
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		tmux kill-session -t Adguard
		ps -ax | rg "[A]dGuardHome"
		if [ $? -eq 0 ]; then
			echo "${RED}[x]${NC}AdguardHome wasn't terminated properly.[${RED}↑${NC}]"
			echo "${CYAN}[✼]${NC}Requires root access."
			sudo killall AdGuardHome
			sudo -k # signs out of root
			if [ $? -eq 0 ]; then
				echo "[✓]Previously running ${GREEN}AdGuardHome${NC} instance(s) were ${RED}terminated${NC}."
			fi
			if [ $? -ne 0 ]; then
				echo "[x]${RED}Could not terminate${NC} previous ADG instances."
			fi
		fi
		echo "${RED}[!]${NC}DNS servers are reset to your DHCP."
		networksetup -setdnsservers Wi-Fi empty
		DNScheck
	fi
	if [ "$inp" -eq "4" ]; then
		echo "Bye"
	fi
fi

if [ "$var" -eq "3" ]; then
	echo ""
	printf '1. Run NextDNS
2. Stop NextDNS
3. Exit script
Enter: ';
	read inp;
	echo ""
	if [ "$inp" -eq "1" ]; then
		echo "${CYAN}Checking nextdns instances:${NC}"
		ps -ax | rg "[n]extdns"
		if [ $? -eq 0 ]; then
			echo "   [✓]${Red}NextDNS is already running. Exiting.${NC}"
			echo ""
			exit
		fi
		echo "[⥉]${GREEN}Starting NextDNS${NC}"
		echo "${CYAN}[✼]${NC}Requires root access."
		sudo nextdns install -config $nextdns_config -cache-size=10MB
		sudo nextdns activate & sudo nextdns start
		echo "nextDNS: $(sudo nextdns status)"
		sudo -k # signs out of root
		sleep 0.5
		echo "[✓]${GREEN}NextDNS set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		DNScheck
	fi
	if [ "$inp" -eq "2" ]; then
		echo "${CYAN}Checking nextdns instances:${NC}"
		ps -ax | rg "[n]extdns"
		if [ $? -ne 0 ]; then
			echo "   [✓]${GREEN}NextDNS isn't running. Exiting script.${NC}"
			echo ""
			exit
		fi
		echo "${CYAN}[✼]${NC}Requires root access."
		sudo nextdns deactivate & sudo nextdns stop
		sudo nextdns uninstall
		echo "nextDNS: $(sudo nextdns status)"
		sudo -k # signs out of root
		sleep 0.5
		echo "${RED}[!]${NC}DNS servers are reset to your DHCP."
		networksetup -setdnsservers Wi-Fi empty
		DNScheck
	fi
	if [ "$inp" -eq "3" ]; then
		echo "Bye"
	fi
fi

if [ "$var" -eq "4" ]; then
	networksetup -setdnsservers Wi-Fi 91.239.100.100 89.233.43.71
	echo "[✓]${GREEN}UncensoredDNS set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	DNScheck
fi

if [ "$var" -eq "5" ]; then
	printf 'Enter a desired DNS server: '
	read DNS;
	networksetup -setdnsservers Wi-Fi $DNS
	echo "[✓]${GREEN}$DNS set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	DNScheck
fi

if [ "$var" -eq "6" ]; then
	echo "[✓]${RED}Removing${NC} these DNS servers:\n${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	sleep 0.5
	networksetup -setdnsservers Wi-Fi empty
	echo "${RED}[!]${NC}DNS servers are reset to your DHCP."
	DNScheck
fi


if [ "$var" -eq "7" ]; then
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	DNScheck
fi

if [ "$var" -eq "8" ]; then
	dig google.com
	ping 8.8.8.8 -c 4
fi

sudo -k # signs out of root