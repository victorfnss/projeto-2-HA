#!/bin/bash
# Habilita o encaminhamento de IP no kernel
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Instala o iptables
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables

# Pega o nome da interface de rede principal dinamicamente
PRIMARY_INTERFACE=$(ip route get 8.8.8.8 | grep -oP 'dev \K\S+')

# Configura o NAT (Masquerade)
iptables -t nat -A POSTROUTING -o $PRIMARY_INTERFACE -j MASQUERADE
service iptables save