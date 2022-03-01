#! /bin/bash

apt update
apt install wireguard

cd /etc/wireguard
umask 077

CONFIG_NAME=$1
SUBNET=$2
PORT=$3

SERVER_PRIVKEY=$( wg genkey )
SERVER_PUBKEY=$( echo $SERVER_PRIVKEY | wg pubkey )

echo $SERVER_PUBKEY > ./server_public.key
echo $SERVER_PRIVKEY > ./server_private.key


CLIENT_PRIVKEY=$( wg genkey )
CLIENT_PUBKEY=$( echo $CLIENT_PRIVKEY | wg pubkey )

echo $CLIENT_PUBKEY > ./client_public.key
echo $CLIENT_PRIVKEY > ./client_private.key

echo "[Interface]" > ./$CONFIG_NAME.conf
echo "Address = 10.253.$SUBNET.1/24" >> ./$CONFIG_NAME.conf
echo "" >> ./$CONFIG_NAME.conf
echo "SaveConfig = true" >> ./$CONFIG_NAME.conf
echo "PrivateKey = $SERVER_PRIVKEY" >> ./$CONFIG_NAME.conf
echo "ListenPort = $PORT" >> ./$CONFIG_NAME.conf
echo "" >> ./$CONFIG_NAME.conf
echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> ./$CONFIG_NAME.conf
echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" >> ./$CONFIG_NAME.conf
echo "" >> ./$CONFIG_NAME.conf
echo "[Peer]" >> ./$CONFIG_NAME.conf
echo "PublicKey = $CLIENT_PUBKEY" >> ./$CONFIG_NAME.conf
echo "AllowedIPs = 10.253.$SUBNET.2/32" >> ./$CONFIG_NAME.conf


systemctl enable wg-quick@$CONFIG_NAME
chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*
wg-quick up $CONFIG_NAME

echo $CLIENT_PRIVKEY
echo $SERVER_PUBKEY
