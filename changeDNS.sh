#!/bin/sh
RED='\033[91m'
GREEN='\033[92m'
CYAN='\033[96m'
NC='\033[0m'

printf '
Set system DNS server
1. PiHole
2. Adguard
3. NextDNS
4. UncensoredDNS
5. Custom DNS
6. Reset DNS
7. Display current DNS
8. Test DNS 
Enter: ';

read var;

if [ "$var" -eq "1" ]; then
	networksetup -setdnsservers Wi-Fi 192.168.100.27 fd5c:c307:7993:db00:2e0:4cff:fe6b:1f4
	echo "${GREEN}PiHole set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	nslookup google.com 
fi

if [ "$var" -eq "2" ]; then
	echo ""
	echo "${CYAN}Check Adguard Status below:${NC}"
	tmux ls
	echo ""
	printf '1. Adguard WORLD
2. Adguard Work
3. Turn OFF
4. Exit
Enter: ';
	read inp;
	echo ""
	if [ "$inp" -eq "1" ]; then
		tmux kill-session -t Adguard
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		cp ~/AdGuardHome_MacOS/AdGuardHome-WORLD.yaml ~/AdGuardHome_MacOS/AdGuardHome.yaml
		tmux new-session -s Adguard "sudo ~/AdGuardHome_MacOS/AdGuardHome"
		networksetup -setdnsservers Wi-Fi 127.0.0.1
		echo "${GREEN}Adguard set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		nslookup google.com 
	fi
	if [ "$inp" -eq "2" ]; then
		tmux kill-session -t Adguard
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		cp ~/AdGuardHome_MacOS/AdGuardHome-Work.yaml ~/AdGuardHome_MacOS/AdGuardHome.yaml
		tmux new-session -s Adguard "sudo ~/AdGuardHome_MacOS/AdGuardHome"
		networksetup -setdnsservers Wi-Fi 127.0.0.1
		echo "${GREEN}Adguard set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		nslookup google.com 
	fi
	if [ "$inp" -eq "3" ]; then
		rm -f ~/AdGuardHome_MacOS/AdGuardHome.yaml
		tmux kill-session -t Adguard
		tmux ls
	fi
	if [ "$inp" -eq "4" ]; then
		echo "Bye"
	fi
fi

if [ "$var" -eq "3" ]; then
	echo ""
	printf '1. Run
2. Stop
3. Exit
Enter: ';
	read inp;
	echo ""
	if [ "$inp" -eq "1" ]; then
		sudo nextdns install -config <nextDNSconfigID> -auto-activate -cache-size=10MB
		sudo nextdns activate & sudo nextdns start
		echo "nextDNS: $(sudo nextdns status)"
		sleep 2
		echo "${GREEN}NextDNS set as DNS server.${NC} Checking..."
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		nslookup google.com
	fi
	if [ "$inp" -eq "2" ]; then
		sudo nextdns deactivate & sudo nextdns stop
		sudo nextdns uninstall
		echo "nextDNS: ${RED}$(sudo nextdns status)${NC}"
		sleep 2
		echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
		nslookup google.com
	fi
	if [ "$inp" -eq "3" ]; then
		echo "Bye"
	fi
fi

if [ "$var" -eq "4" ]; then
	networksetup -setdnsservers Wi-Fi 91.239.100.100 89.233.43.71
	echo "${GREEN}UncensoredDNS set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	nslookup google.com
fi

if [ "$var" -eq "5" ]; then
	printf 'Enter a desired DNS server: '
	read DNS;
	networksetup -setdnsservers Wi-Fi $DNS
	echo "${GREEN}$DNS set as DNS server.${NC} Checking..."
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	nslookup google.com
fi

if [ "$var" -eq "6" ]; then
	echo "${RED}Removing these DNS servers:\n${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	sleep 1
	networksetup -setdnsservers Wi-Fi empty
	nslookup google.com
fi


if [ "$var" -eq "7" ]; then
	echo "Current DNS server: ${CYAN}$(networksetup -getdnsservers Wi-Fi)${NC}"
	nslookup google.com
fi

if [ "$var" -eq "8" ]; then
	dig google.com
	ping 8.8.8.8 -c 4
fi
