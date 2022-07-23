#!/bin/bash
clear

apt-get update\
  && apt-get -y install vim dnsutils curl sudo\
  && curl -fsSL https://get.docker.com/ | sh || apt-get -y install docker.io\
  && mkdir -p ~/netflix-proxy\
  && cd ~/netflix-proxy\
  && curl -fsSL https://github.com/ab77/netflix-proxy/archive/latest.tar.gz | gunzip - | tar x --strip-components=1
rm -rf /root/netflix-proxy/proxy-domains.txt
"akadns.net" >/root/netflix-proxy/proxy-domains.txt
"akam.net" >/root/netflix-proxy/proxy-domains.txt
"akamai.com" >/root/netflix-proxy/proxy-domains.txt
"akamai.net" >/root/netflix-proxy/proxy-domains.txt
"akamaiedge.net" >/root/netflix-proxy/proxy-domains.txt
"akamaihd.net" >/root/netflix-proxy/proxy-domains.txt
"akamaistream.net" >/root/netflix-proxy/proxy-domains.txt
"akamaitech.net" >/root/netflix-proxy/proxy-domains.txt
"akamaitechnologies.com" >/root/netflix-proxy/proxy-domains.txt
"akamaized.net" >/root/netflix-proxy/proxy-domains.txt
"cloudfront.net" >/root/netflix-proxy/proxy-domains.txt
"netflix." >/root/netflix-proxy/proxy-domains.txt
"netflix.net" >/root/netflix-proxy/proxy-domains.txt
"nflximg.net" >/root/netflix-proxy/proxy-domains.txt
"nflxvideo.net" >/root/netflix-proxy/proxy-domains.txt
"nflxso.net" >/root/netflix-proxy/proxy-domains.txt
"nflxsearch.net" >/root/netflix-proxy/proxy-domains.txt
"nflxext.com" >/root/netflix-proxy/proxy-domains.txt
"ip2location.com" >/root/netflix-proxy/proxy-domains.txt
"playstation.net" >/root/netflix-proxy/proxy-domains.txt
"xboxlive.com" >/root/netflix-proxy/proxy-domains.txt
"ifconfig.co" >/root/netflix-proxy/proxy-domains.txt
"hotstar.com" >/root/netflix-proxy/proxy-domains.txt
"readwn.com" >/root/netflix-proxy/proxy-domains.txt
"hdo.app" >/root/netflix-proxy/proxy-domains.txt
./build.sh

cd
cd
clear

rm -rf netflix.sh