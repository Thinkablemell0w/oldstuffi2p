#/bin/sh

if [ `id -u ` -ne 0 ]; then 

    echo "This script must be run as root" 

    exit 1 

fi

TORCONF="
'TransPort 127.0.0.1:9041'
'DnsPort 127.0.0.1:54'"
NEWBINDS="
binds+=( '/etc/i2p' )
binds+=( '/var/lib/i2p/i2p-config/' )"
OLDBINDS="
'/rw/srv/whonix/etc/i2p:/etc/i2p'
'/rw/srv/whonix/var/lib/i2p/i2p-config:/var/lib/i2p/i2p-config'
'/rw/srv/whonix/usr/share/i2p:/usr/share/i2p'"
FWCONFIG=NO_NAT_USERS+="
GATEWAY_TRANSPARENT_DNS=1
GATEWAY_TRANSPARENT_TCP=1
SOCKS_PORT_I2P_BOB=2827
SOCKS_PORT_I2P_TAHOE=3456
SOCKS_PORT_I2P_WWW=4444
SOCKS_PORT_I2P_WWW2=4445
SOCKS_PORT_I2P_IRC=6668
SOCKS_PORT_I2P_XMPP=7622
SOCKS_PORT_I2P_CONTROL=7650
SOCKS_PORT_I2P_SOCKSIRC=7651
SOCKS_PORT_I2P_SOCKS=7652
SOCKS_PORT_I2P_I2CP=7654
SOCKS_PORT_I2P_SAM=7656
SOCKS_PORT_I2P_EEP=7658
SOCKS_PORT_I2P_SMTP=7659
SOCKS_PORT_I2P_POP=7660
SOCKS_PORT_I2P_BOTESMTP=7661
SOCKS_PORT_I2P_BOTEIMAP=7662
SOCKS_PORT_I2P_MTN=8998"

FILES="
/usr/bin/i2p-launcher
/usr/share/icons/anon-icon-pack/i2p-con.png
/usr/share/icons/anon-icon-pack/i2p-ready.png
/usr/share/icons/anon-icon-pack/i2p-start.png
/etc/qubes/suspend-post.d/30_i2p_start.sh
/etc/qubes/suspend-pre.d/30_i2p_restart.sh
/usr/lib/i2p/i2p.sh"

disclaimer(){
echo "Disclaimer \n"
echo "This script will revert all changes regarding I2P"
echo -n "Are you sure you wish to continue? (y/n)  " 

read ans 
case $ans in 

    y*|Y*|j*|J*) 
        ;; 
    *) 
        exit 0 
        ;; 
esac 
}

remove_i2p_ws(){
apt-get remove xul-ext-foxyproxy-standard
rm /home/user/.tb/tor-browser/Browser/TorBrowser/Data/Browser/profile.default/extensions/foxyproxy@eric.h.jung

#remove socat forwarding

	
	}

remove_i2p_gw(){
echo "Removing I2P"
apt-get remove i2p
clear
echo "OK"

echo "Removing the I2P Repository from the Apt list"
if [ -e /etc/apt/sources.list.d/i2p.list ];then
    rm /etc/apt/sources.list.d/i2p.list
    echo "OK"
else 
    echo "i2p.list not found"
fi
echo "Removing I2P Key"
if apt-key fingerprint | fgrep -q "7840 E761 0F28 B904 7535  49D7 67EC E560 5BCF 1346" > /dev/null 2>&1; then
    apt-key del 0x67ECE5605BCF1346
    echo "OK"
else
    echo "I2P Keys not found"
fi   
echo "Removing all I2P scripts"
for file in $FILES; do
    if [ -e $file ];then
        rm $file
        echo "$file deleted"
    else
        echo "$file not found"
    fi
done
if [ -d /usr/lib/i2p/ ];then
	rmdir /usr/lib/i2p
	echo "/usr/lib/i2p/ deleted"
else
	echo "/usr/lib/i2p/ not found"
fi	
echo "OK"

#echo "Removing Tor Config changes"
#for config in $TORCONF; do
#    sed -i /$config/d /etc/tor/torrc
#done
#echo "OK"

echo "Removing I2P Path from Persistent dirs"
if [ -e /usr/lib/qubes/bind-dirs.sh ] && [ -e /usr/lib/qubes/init/bind-dirs.sh ] ; then
    for binds in $NEWBINDS; do
	    sed -i /$binds/d /usr/lib/qubes-bind-dirs.d/40_qubes-whonix.conf
    done	
	echo "OK"

else
    for binds in $OLDBINDS; do
        sed -i /$binds/d /usr/lib/qubes-whonix/bind-directories
    done
	echo "OK"

fi	
echo "Removing I2P Firewall Rules"
if [ -e /etc/whonix_firewall.d/50_user.conf ];then
    for conf in $FWCONFIG; do
	    sed -i /$conf/d /etc/whonix_firewall.d/50_user.conf
    done
else
    echo "Whonix Firewall User Config not found"
fi
}
echo "OK"
qubes_vm_type="$(qubesdb-read /qubes-vm-type)"


if [ "$qubes_vm_type" = "TemplateVM" ]; then
  
    if [ -e /usr/share/anon-gw-base-files/gateway ]; then
        disclaimer  
        remove_i2p_gw
    elif [-e /usr/share/anon-ws-base-files/worksation ]; then
        disclaimer
        remove_i2p_ws 
    fi
    
    
fi
