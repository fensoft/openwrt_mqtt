#!/bin/sh
cat << EOF > /root/openwrt_mqtt
#!/bin/sh
while sleep 5; do
  IFS=,
  for i in \$1; do
    LINK=\`ethtool \$i | grep "Link detected: " | sed "s#.*: ##"\`
    SPEED=\`ethtool \$i | grep "Speed: " | sed "s#.*: ##" | sed "s#Unknown!#No Speed#" | sed "s#b/s##"\`
    RX=\`ifconfig \$i | grep "RX bytes:" | sed "s#.*RX bytes:\([0-9]*\) .*#\\1#"\`
    TX=\`ifconfig \$i | grep "TX bytes:" | sed "s#.*TX bytes:\([0-9]*\) .*#\\1#"\`
    eval "OLDRX=\\\$RX_\$i"
    if [ "\$OLDRX" ]; then
      eval "RXSPD=\\\$(((\$RX-\$OLDRX)/\$SLEEP))"
    fi
    eval "RX_\$i=\$RX"
    eval "OLDTX=\\\$TX_\$i"
    if [ "\$OLDTX" ]; then
      eval "TXSPD=\\\$(((\$TX-\$OLDTX)/\$SLEEP))"
    fi
    eval "TX_\$i=\$TX"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/link -m "\$LINK"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/speed -m "\$SPEED"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/rx -m "\$RX"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/tx -m "\$TX"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/rxspd -m "\$RXSPD"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/txspd -m "\$TXSPD"
  done
done
EOF
opkg install ethtool mosquitto-client-nossl coreutils-nohup
cat << EOF > /etc/init.d/openwrt_mqtt
#!/bin/sh
/usr/bin/nohup /root/openwrt_mqtt lan1,lan2,lan3,wan $2 2>&1 > /dev/null&
EOF
chmod a+x /root/openwrt_mqtt /etc/init.d/openwrt_mqtt
rm -f /etc/rc.d/*openwrt_mqtt
ln -fs ../init.d/openwrt_mqtt /etc/rc.d/S99openwrt_mqtt
