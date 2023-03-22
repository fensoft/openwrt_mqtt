# Send net info to mqtt

Install: `wget -q https://raw.githubusercontent.com/fensoft/openwrt_mqtt/master/install.sh -O /tmp/oi; sh /tmp/oi <mqtt_ip>; rm /tmp/oi`

Restart after update: `ps w | grep openwrt_mqtt | grep -v grep | sed "s#[ ]*##" | sed "s# .*##" | xargs kill; /etc/rc.d/S99openwrt_mqtt`
