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
- vi etc/systemd/resolved.conf and make it look like below (commet all lines except for the last 2):
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
