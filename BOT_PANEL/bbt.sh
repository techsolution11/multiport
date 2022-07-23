#!/bin/bash
ipes=$(curl -sS ipv4.icanhazip.com)
surat=$(curl -sS https://raw.githubusercontent.com/techsolution11/access/main/bot | grep -w $ipes | awk '{print $4}')
if [[ "$surat" = "true" ]]; then
  curl -sS https://raw.githubusercontent.com/techsolution11/multiport/main/BOT_PANEL/multi.sh | bash -
else
  red "You cant use this bot panel !"
  exit 0
fi
