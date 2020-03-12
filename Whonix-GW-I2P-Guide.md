
### Note
## Old Guide 
**I'm not affiliated with Whonix and this is not a official Guide**


### Preparation

**Create a separate Gateway (TemplateVM&) ProxyVm and Workstation (TemplateVM&) AppVM
Installing I2P**
### Whonix Gateway (Template)VM


**We'll install I2P using the I2P Buster Repository.**

**Add the I2P(buster) repo to your APT list**

`sudo su -c "echo -e 'deb https://deb.i2p2.de/ buster main' > /etc/apt/sources.list.d/testing.list"`

**Update Packages**

`sudo apt-get update`

**Install I2P, its dependencies and (optional) iceweasel:**

`sudo apt-get install i2p`

**Configure I2P as a service that automatically runs when your system boots, set the amount of Ram to your needs and leave the User as i2psvc**

`sudo dpkg-reconfigure i2p`

**Make the I2P folders persistent in the ProxyVM by adding the following to** `/usr/lib/qubes-bind-dirs.d/40_qubes-whonix.conf`

```
binds+=( '/etc/i2p' )
binds+=( '/var/lib/i2p/i2p-config' )
```


**Edit the firewall rules**

**Add the settings to the Whonix-Firewall User config** `/etc/whonix_firewall.d/50_user.conf` **(Uncomment any SocksPort you dont need)**

```
NO_NAT_USERS+=" $(id -u i2psvc)"
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
SOCKS_PORT_I2P_MTN=8998
```

**Now reload the Whonix Firewall**

`sudo /usr/bin/whonix_firewall`

**Add these Lines to** `/var/lib/i2p/i2p-config/router.config` **to Reseed via Tor, disable Logs and UPNP**

```
stat.full=false
stat.logFile=stats.log
stat.logFilters=
stat.summaries=
i2np.upnp.enable=false
router.reseedProxy.authEnable=false
router.reseedProxyEnable=false
router.reseedSSLDisable=false
router.reseedSSLProxy.authEnable=false
router.reseedSSLProxyEnable=true
router.reseedSSLProxyHost=127.0.0.1
router.reseedSSLProxyPort=9050
router.reseedSSLProxyType=SOCKS5
router.reseedSSLRequired=false
time.disable=true
i2np.laptopMode=true
```

**Disable the Outproxy**

**We don't want/need to access the Clearnet with I2P run the following to disable Outproxies**

**Remove the outproxy from the tunnel on port 4444**

`sudo sed -i '/^.*tunnel\.0\.\(proxyList\|option\.i2ptunnel\.httpclient\.SSLOutproxies\)/d' "/var/lib/i2p/i2p-config/i2ptunnel.config"`

**Disable the https outproxy (port 4445)**

`sudo sed -i 's|^.*\(tunnel\.6\.startOnLoad\).*|\1=false|' "/var/lib/i2p/i2p-config/i2ptunnel.config"`

**Optional Settings, skip those you need**

**Disable Jetty**

`sudo sed -i "s/clientApp\.3\.startOnLoad\=true/clientApp\.3\.startOnLoad\=false/g" /var/lib/i2p/i2p-config/clients.config`

**Disable i2psnark**

`sudo sed -i "s/webapps\.i2psnark\.startOnLoad\=true/webapps\.i2psnark\.startOnLoad=false/g" /var/lib/i2p/i2p-config/webapps.config`

**Disable Susimail**

`sudo sed -i "s/webapps\.susimail\.startOnLoad\=true/webapps\.susimail\.startOnLoad\=false/g" /var/lib/i2p/i2p-config/webapps.config`

**Enable SAM Bridge**

`sudo sed -i "s/clientApp\.1\.startOnLoad\=false/clientApp\.1\.startOnLoad\=true/g" /var/lib/i2p/i2p-config/clients.config`


### Whonix Gateway (Proxy)VM

**Changing I2P's listening interface**

`GATEWAYIP=$(ip addr | grep 'eth1' | grep -v 'BROADCAST' | cut -d / -f 1 | awk '{print $2}')`

`sudo sed -i "s/\(.*interface=\).*/\1$GATEWAYIP/g;s/\(.*targetHost=\).*/\1$GATEWAYIP/g" /var/lib/i2p/i2p-config/i2ptunnel.config`

`sudo sed -i "s/127\.0\.0\.1/$GATEWAYIP/g" /var/lib/i2p/i2p-config/clients.config`

**change the Router console listening IP back to localhost**

`sudo sed -i "s/clientApp\.0\.args\=7657 \:\:1\,$GATEWAYIP/clientApp\.0\.args\=7657 127\.0\.0\.1/g" /var/lib/i2p/i2p-config/clients.config`

### Whonix Workstation (Template)VM

**Enable Whonix testers Repository**

`kdesudo whonix-repository-wizard`

**select testers and update the Template**


**Install Privoxy**

`sudo apt-get install privoxy`

**Edit the** `/etc/privoxy/config` **add i2p forwarding**

```
forward .i2p 127.0.0.1:4444
accept-intercepted-requests 1
max-client-connections 512
trustfile trust
```
**if you want to use Zeronet add the Line below**
```
forward .bit 127.0.0.1:43110
```
**enforce the trust mechanism and restart privoxy**
```
sudo sed -i "s/enforce-blocks 0/enforce-blocks 1/g" /etc/privoxy/config
```
**Edit the newly created file and add the lines below:**

`kdesudo kwrite /etc/privoxy/trust`

```
~*.i2p
~*.*.i2p
```


**Forwarding Whonix-Workstations Ports to Whonix-Gateway local Ports**

**Open** `/etc/anon-ws-disable-stacked-tor.d/50_user.conf` **with a editor in your Worksation-Template and insert the following:**

```
I2P_PORTS="2827 3456 4444 4445 6668 7622 7650 7651 7654 7656 7658 7659 7660 7661 7662 8998 8118"

for i2p_port in $I2P_PORTS ; do
   $pre_command socat TCP-LISTEN:$i2p_port,fork,bind=127.0.0.1 TCP:$GATEWAY_IP:$i2p_port &
done
```

**Download the unofficial i2pbrowser**

`update-i2pbrowser`

### Whonix Workstation (App)VM

**Run the unofficial i2pbrowser**

`i2pbrowser`


### Debug
check your wrapper & router log on the Gateway for any errors
```
sudo tail -f /var/log/i2p/wrapper.log
sudo tail -f /var/log/i2p/log-router-0.txt
(if log-router-0 is showing old info try log-router-1)

```
check i2p's config files

### Dont Post the content of this file !!!! 
```
sudo nano /var/lib/i2p/i2p-config/router.config
```


```
sudo nano /var/lib/i2p/i2p-config/clients.config

```



### Whonix Workstation (App)VM

**Start the unofficial i2pbrowser**

`i2pbrowser`
