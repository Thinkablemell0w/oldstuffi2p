#!/bin/sh
set -e

if [ `id -u ` -ne 0 ]; then 

    echo "This script must be run as root" 

    exit 1 

fi

qubes_vm_type="$(qubesdb-read /qubes-vm-type)"

#check in what kind of VM we're runnign
if [ "$qubes_vm_type" = "TemplateVM" ]; then
    if [ -e /usr/share/anon-gw-base-files/gateway ]; then
        echo "Running Gateway Template Config script..."
        ./anon-i2p-gw-template-config
    elif [ -e /usr/share/anon-ws-base-files/workstation ]; then
        echo "Running Workstation Template Config script..."
        ./anon-i2p-ws-template-config
    else 
        echo "ERROR, couldn't find Whonix files " 
    fi
elif [ "$qubes_vm_type" = "ProxyVM"];then
    if [ -e /usr/share/anon-gw-base-files/gateway ]; then
        ./anon-i2p-gw-proxyvm-config
    else    
        echo "ERROR, couldn't find Whonix files "     
elif [ "$qubes_vm_type" = "AppVM"; then
    if [ -e /usr/share/anon-ws-base-files/workstation ]; then
        echo "Running Workstation AppVM Config script..."
        ./anon-i2p-ws-appvm-config
    else    
        echo "ERROR, couldn't find Whonix files "         
else
    echo "Couldn't identify the VM type"    
fi
