#iptables script for a bastion samba server in a DMZ with IP 172.16.1.5 


#!/bin/bash
#welcome to iptable configuration for samba server

#set default policies for iptables to prevent firewall lockout after flush
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

#flush iptable rules
iptables -F

#iptables -N UDP
#iptables -N TCP
#iptables -N ICMP

#allow ssh, https
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

#allow port 137-139 to allow Samba functionality for 172.16.0.0/12 LAN
iptables -A INPUT -s 172.16.0.0/12 -m state --state NEW -p tcp --dport 137 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12 -m state --state NEW -p tcp --dport 138 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/12 -m state --state NEW -p tcp --dport 139 -j ACCEPT

#allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT

#deny invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

#direct INPUT traffic to correct protocol
iptables -A INPUT -p udp -m conntrack --ctstate NEW  
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW  
iptables -A INPUT -p icmp -m conntrack --ctstate NEW 

#reject all other traffic
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

iptables -P INPUT DROP
iptables -P FORWARD DROP

#rules will be persistent even after restarting
#service iptables-persistent save
