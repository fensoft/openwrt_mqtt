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

    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/link -m "\$LINK"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/speed -m "\$SPEED"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/rx -m "\$RX"
    mosquitto_pub -h \$2 -t openwrt/$HOSTNAME/\$i/tx -m "\$TX"
  done
done
EOF
opkg install ethtool mosquitto-client-nossl coreutils-nohup
echo "nohup /root/openwrt_mqtt lan1,lan2,lan3,wan 10.68.69.5 2>&1 > /dev/null&" > /etc/init.d/openwrt_mqtt
chmod a+x /root/openwrt_mqtt /etc/init.d/openwrt_mqtt
ln -s /etc/init.d/openwrt_mqtt /etc/rc.d/K90openwrt_mqtt
