#  This is a modification from:
https://github.com/burkeazbill/docker-coredns to suit my purpose.

Modifications made:
- changed docker-compse and Dockerfile a bit
- added a block in Corefile so other domains get resolved by 8.8.8.8 and 9.9.9.9
- also changed domain from example.com to osp.com.  
- db.osp.com has A Name, C Name and A Name entries with multiple IP examples

# Some additional notes:
UDP 53  is used by resolv.comf, so docker container won't be able to map 53:53/udp on base system.

reference: https://medium.com/@niktrix/getting-rid-of-systemd-resolved-consuming-port-53-605f0234f32f

on the base ubuntu system do the following:
- sudo systemctl stop systemd-resolved
```bash
sudo systemctl stop systemd-resolved
```

- sudo systemctl disable systemd-resolved
```bash
sudo systemctl disable systemd-resolved
```
- vi /etc/systemd/resolved.conf and make it look like below (commet all lines except for the last 2):

```bash
vi /etc/systemd/resolved.conf
```
       This file is part of systemd.
     
       systemd is free software; you can redistribute it and/or modify it
       under the terms of the GNU Lesser General Public License as published by
       the Free Software Foundation; either version 2.1 of the License, or
       (at your option) any later version.
     
      Entries in this file show the compile time defaults.
      You can change settings by editing this file.
      Defaults can be restored by simply deleting this file.
     
      See resolved.conf(5) for details
     ```plain
     [Resolve]
     #DNS=
     #FallbackDNS=
     #Domains=
     #LLMNR=no
     #MulticastDNS=no
     #DNSSEC=no
     #DNSOverTLS=no
     #Cache=no-negative
     #DNSStubListener=yes
     #ReadEtcHosts=yes
     DNS=8.8.8.8
     DNSStubListener=no
    ```
- sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf       # make a linked file       -sf is symbolic and force
```bash
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf 
```
#  another good reference: 
   https://dev.to/robbmanes/running-coredns-as-a-dns-server-in-a-container-1d0
   
# After making changes to the db file:
please increment serial number for it to take effect.  Alternatively do a "docker-compose restart"   


#  Original Readme file below:

[![Docker Hub Build Status](https://img.shields.io/docker/build/burkeazbill/docker-coredns)](https://hub.docker.com/r/burkeazbill/docker-coredns) [![Build Status](https://travis-ci.org/burkeazbill/docker-coredns.svg?branch=master)](https://travis-ci.org/burkeazbill/docker-coredns)[![](https://images.microbadger.com/badges/image/burkeazbill/docker-coredns.svg)](https://microbadger.com/images/burkeazbill/docker-coredns "Get your own image badge on microbadger.com")

# Docker CoreDNS

## Overview

Need a lightweight, simple, container-based DNS server for your home or lab environment? Here it is! [CoreDNS](http://www.coredns.io). This docker based container image weighs in at a whopping 32.9MB ! That's it!

## Instructions

Choose which format file you wish to use:

- hosts file
- DNS Zone file

I've provided an example of each in the config folder.

Edit the config/Corefile as follows:

- Rename the file it is referencing to match your domain (change the example.com part of the filename to yourdomain.whatever)
- Uncomment the file type you wish to use (hosts/file)

Next, edit the zone file (db.example.com) or hosts file (example.com.hosts), adding entries for eacy of your hosts in the respective format.

Once you're done, simply type the following command to run the container in daemon mode (requires docker-compose):

```plain
docker-compose up -d

or 

docker compose build
docker-compose up -d
```

Prefer to simply run docker from the command line? Example shows call for latest image. 

```plain
docker run -m 128m --expose=53 --expose=53/udp -p 53:53 -p 53:53/udp -v "$PWD"/config:/etc/coredns --name coredns burkeazbill/docker-coredns -conf /etc/coredns/Corefile
```

## Test the DNS

You can confirm the dns is working with dig as follows, from the host running the container. Assuming you simply run the command line above without any modifications, you can use this:

```plain
dig @localhost gateway.example.com
```

This should result in the output including an ANSWER SECTION that shows gateway.example.com resolves to 192.168.1.1 as follows:

```plain
$ dig @localhost gateway.example.com


; <<>> DiG 9.10.6 <<>> @localhost gateway.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47780
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;gateway.example.com.		IN	A

;; ANSWER SECTION:
gateway.example.com.	3600	IN	A	192.168.1.1

;; AUTHORITY SECTION:
example.com.		3600	IN	NS	a.iana-servers.net.
example.com.		3600	IN	NS	b.iana-servers.net.

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Jul 05 23:24:04 EDT 2018
;; MSG SIZE  rcvd: 169
```


## Learn more

- [Corefile explained](https://coredns.io/2017/07/23/corefile-explained/)
- [Quickstart Guide](https://coredns.io/2017/07/24/quick-start/)
- [Configuration CoreDNS](https://www.alibabacloud.com/help/en/container-service-for-kubernetes/latest/configure-coredns)

```
Quick steps to install docker & docker-compose on Ubuntu:
---------------------------------------------------------

sudo -i
apt-get update && apt-get upgrade -y
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p
sudo sysctl --system
exit
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker
sudo usermod -aG docker $USER
exit # and ssh back in for this to work
docker --version
sudo apt install docker-compose -y
```
# Next Steps
once cloned change directory to "coredns_docker-compose" Here you will see the following.

   - docker-compose.yml
   - Dockerfile
   - config directory

Change directory to the config directory. 
  - vi "Corefile" and change the line  "file /etc/coredns/db.osp.com osp.com" to "file /etc/coredns/db.onprem.com onprem.com"  Here onprem.com is your domain
  - now rename db.osp.com to db.onprem.com and vi db.onprem.com to put in your DNS records 

📙 Corefile has a line that forwards to /etc/resolv.conf    This is used if there is no entry in db.onprem.com

![image](https://github.com/soumukhe/coredns_docker-compose/assets/13289754/fbe210d5-b254-4926-b334-aaaab2d83a44)

The final files in that directory should be like shown in the figure below.
![image](https://github.com/soumukhe/coredns_docker-compose/assets/13289754/cf3c4569-f3ad-4cef-89cf-a55c55b157ac)

now build and bring up the container with the command
```
docker-compose up -d
```

# Example Configs:

1. MTU if using vxlan:
- The figure below shows the configuration for the network interfaces for the Ubuntu VM. Note that ens192 is connected to our EPG and it’s mtu has been set to 1350 (1500 – 100 for IPSec – 50 for VXLan)
![image](https://github.com/user-attachments/assets/bccf9717-bad2-4c71-9593-fff67e9830ca)

2. db config
![image](https://github.com/user-attachments/assets/df40ec7b-b723-41a0-ba82-b28f1ba10f0a)

3. Corefile
![image](https://github.com/user-attachments/assets/653dc98d-3a1b-4279-9abf-b2563612e14f)

4. Example resolv.conf
![image](https://github.com/user-attachments/assets/9f3ff517-7944-4991-a04b-ab2bb6a608a0)



