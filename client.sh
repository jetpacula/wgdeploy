#! /bin/bash


apt update
apt install wireguard

cd /etc/wireguard

SUBNET=$1
PRIVKEY=$2
PUBKEY=$3
ENDPOINT=$4

echo "[Interface]" >> ./wg0.conf
echo "Address = 10.253.$SUBNET.2/32" >> ./wg0.conf
echo "PrivateKey = $PRIVKEY" >> ./wg0.conf
echo "DNS = 1.1.1.1" >> ./wg0.conf
echo "" >> ./wg0.conf
echo "[Peer]" >> ./wg0.conf
echo "PublicKey = $PUBKEY" >> ./wg0.conf
echo "Endpoint = $ENDPOINT" >> ./wg0.conf
echo "AllowedIPs = 0.0.0.0/0, ::/0" >> ./wg0.conf

sed -i -e 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
systemctl enable wg-quick@wg0
chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*
wg-quick up wg0
