#!/bin/bash

source /etc/.maAsiss/.Shellbtsss
get_Token=$(sed -n '1 p' /root/ResBotAuth | cut -d' ' -f2)
get_AdminID=$(sed -n '2 p' /root/ResBotAuth | cut -d' ' -f2)
get_botName=$(sed -n '1 p' /root/multi/bot.conf | cut -d' ' -f2)
get_limituser=$(sed -n '2 p' /root/multi/bot.conf | cut -d' ' -f2)
res_price=5

ShellBot.init --token $get_Token --monitor --return map --flush --log_file /root/log_bot

msg_welcome() {
    oribal=$(grep ${message_from_id} /root/multi/reseller | awk '{print $2}')
    if [ "${message_from_id[$id]}" == "$get_AdminID" ]; then
        local msg
        msg="Welcome MASTER\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard1" \
            --parse_mode html
    elif [ "$(grep -wc ${message_from_id} /root/multi/reseller)" != '0' ]; then
        local msg
        msg="Welcome Reseller\n\n"
        msg+="Your Id : <code>${message_from_id}</code>\n"
        msg+="Your Balance Is $oribal"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard5" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "❌Access Deny❌\n\nThis Is Your Id: <code>${message_from_id}</code>\n" \
            --parse_mode html
    fi
}

backReq() {
    oribal=$(grep ${callback_query_from_id} /root/multi/reseller | awk '{print $2}')
    if [ "${callback_query_from_id[$id]}" == "$get_AdminID" ]; then
        local msg
        msg="Welcome MASTER\n"
        ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
            --message_id ${callback_query_message_message_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard1" \
            --parse_mode html
    elif [ "$(grep -wc ${callback_query_from_id} /root/multi/reseller)" != '0' ]; then
        local msg
        msg="Welcome Reseller\n\n"
        msg+="Your Id : <code>${callback_query_from_id}</code>\n"
        msg+="Your Balance Is $oribal"
        ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
            --message_id ${callback_query_message_message_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard5" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${callback_query_message_message_id[$id]} \
            --text "❌Access Deny❌\n\nThis Is Your Id: <code>${callback_query_from_id}</code>\n" \
            --parse_mode html
    fi
}

freeReq() {
    if [ "$(cat /root/multi/public)" == "on" ]; then
        local msg
        msg="Welcome ${message_from_first_name}\n"
        msg+="Please Select Free Config Below\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard3" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Free Function Is Close\n" \
            --parse_mode html
    fi
}

claimVoucher() {
    msg="Hi ${message_from_first_name}\n"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard7" \
        --parse_mode html
}

menuSsh() {
    local msg
    msg="Welcome ${callback_query_from_first_name}\n"
    msg+="Menu SSH\n"
    ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard4" \
        --parse_mode html
}

menuXray() {
    local msg
    msg="Welcome ${callback_query_from_first_name}\n"
    msg+="Menu SSH\n"
    ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard2" \
        --parse_mode html
}

menuRes() {
    local msg
    msg="Welcome ${callback_query_from_first_name}\n"
    msg+="Menu Reseller\n"
    ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard6" \
        --parse_mode html
}

publicReq() {
    limituser=$(sed -n '2 p' /root/multi/bot.conf | cut -d' ' -f2)
    if [ "$(cat /root/multi/public)" == "off" ]; then
        echo "on" >/root/multi/public
        echo "" >/root/multi/claimed
        ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} \
            --text "✅ Public Mode Is On, Limit Is $limituser ✅"
    else
        echo "off" >/root/multi/public
        ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} \
            --text "❌ Public Mode Is OFf,Limit Is $limituser ❌"
    fi
}

req_voucher() {
    file_user=$1
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    if [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        echo "voucher"
    elif [ "${coupon}" == "free" ]; then
        if [ "$(cat /root/multi/public)" != "on" ]; then
            ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                --text "Public Is Off\n" \
                --parse_mode html
            exit 1
        else
            echo "free"
        fi
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Already Claimed\n" \
            --parse_mode html
        exit 1
    fi
}

req_url() {
    ori=$(grep ${callback_query_from_id} /root/multi/reseller | awk '{print $2}')

    if [[ ${callback_query_data[$id]} == _addvmess ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Vmess (USER EXPIRED) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _addvless ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Vless (USER EXPIRED) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _addxtls ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Xtls (USER EXPIRED) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _addtrojan ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Trojan (USER EXPIRED) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _voucherOVPN ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "OVPN (USER EXPIRED) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    fi
}

link_voucher() {
    file_user=/tmp/cad.${callback_query_message_chat_id[$id]}
    vouch=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    exp=$(grep $vouch /root/multi/voucher | awk '{print $2}')
    user=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c4)

    if [[ ${callback_query_data[$id]} == _vouchervmess ]]; then
        local msg
        msg="User : $user\n"
        msg+="<code>Expired : $exp</code>\n\n"
        msg+="https://t.me/${get_botName}?start=vmess_${user}_${vouch}\n"
        msg+="Click Link To Confirm Vmess Acc\n"

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    elif [[ ${callback_query_data[$id]} == _vouchervless ]]; then
        local msg
        msg="User : $user\n"
        msg+="<code>Expired : $exp</code>\n\n"
        msg+="https://t.me/${get_botName}?start=vless_${user}_${vouch}\n"
        msg+="Click Link To Confirm Vless Acc\n"

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    elif [[ ${callback_query_data[$id]} == _voucherxtls ]]; then
        local msg
        msg="User : $user\n"
        msg+="<code>Expired : $exp</code>\n\n"
        msg+="https://t.me/${get_botName}?start=xtls_${user}_${vouch}\n"
        msg+="Click Link To Confirm Xtls Acc\n"

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    elif [[ ${callback_query_data[$id]} == _vouchertrojan ]]; then
        local msg
        msg="User : $user\n"
        msg+="<code>Expired : $exp</code>\n\n"
        msg+="https://t.me/${get_botName}?start=trojan_${user}_${vouch}\n"
        msg+="Click Link To Confirm Trojan Acc\n"

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    elif [[ ${callback_query_data[$id]} == _voucherovpn ]]; then
        local msg
        msg="User : $user\n"
        msg+="<code>Expired : $exp</code>\n\n"
        msg+="https://t.me/${get_botName}?start=ovpn_${user}_${vouch}\n"
        msg+="Click Link To Confirm Vmess Acc\n"

        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    fi
}

req_free() {
    if [[ ${callback_query_data[$id]} == _freevmess ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Vmess(free) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _freevless ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Vless(free) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _freextls ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Xtls(free) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    elif [[ ${callback_query_data[$id]} == _freetrojan ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
            --text "Trojan(free) :" \
            --reply_markup "$(ShellBot.ForceReply)"
    fi

}

req_del() {
    cat /etc/scvpn/xray/user.txt >/tmp/cad.${message_from_id[$id]}
    alluser=$(cat /etc/scvpn/xray/user.txt | awk '{print $1}' | sort | uniq)
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Del ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n$alluser\n\n━━━━━━━━━━━━━━━━━━━━━\n" \
        --parse_mode html
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Del User :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

req_ext() {
    cat /etc/scvpn/xray/user.txt >/tmp/cad.${message_from_id[$id]}
    alluser=$(cat /etc/scvpn/xray/user.txt | awk '{print $1}' | sort | uniq)
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Extend ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n$alluser\n\n━━━━━━━━━━━━━━━━━━━━━\n" \
        --parse_mode html
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Extend User :" \
        --reply_markup "$(ShellBot.ForceReply)"

}

req_limit() {
    limituser=$(sed -n '2 p' /root/multi/bot.conf | cut -d' ' -f2)
    total=$(wc -l /etc/scvpn/xray/user.txt | cut -d' ' -f1)
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    ori=$(grep ${message_from_id} multi/reseller | awk '{print $2}')
    if [ "${message_from_id[$id]}" == "$get_AdminID" ]; then
        echo ""
    elif [ "$(grep -wc ${message_from_id} /root/multi/reseller)" != '0' ]; then
        echo "reseller"
    elif [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        echo "voucher"
    elif [ "$(grep -wc ${message_from_id[$id]} /root/multi/claimed)" != '0' ]; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Already Redeem" \
            --parse_mode html
        exit 1
    elif (($total >= $limituser)); then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Fully Redeem" \
            --parse_mode html
        exit 1
    else
        echo "${message_from_id[$id]}" >>/root/multi/claimed
    fi
}

freelimitReq() {
    limituser=$(sed -n '2 p' /root/multi/bot.conf | cut -d' ' -f2)
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Your Current Free Limit Is $limituser" \
        --parse_mode html
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Change Limit:" \
        --reply_markup "$(ShellBot.ForceReply)"
}

generatorReq() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Voucher Validity:" \
        --reply_markup "$(ShellBot.ForceReply)"
}

voucher_req() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Input Your Voucher:" \
        --reply_markup "$(ShellBot.ForceReply)"
}

resellerReq() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Create Reseller :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

balRes() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Add Balance Reseller :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

allRes() {
    result=$(cat /root/multi/reseller)
    ShellBot.editMessageText --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]} \
        --text "━━━━━━━━━━━━━━━━━━━━━\n 🟢 Reseller 🟢 \n━━━━━━━━━━━━━━━━━━━━━\n\n$result\n\n━━━━━━━━━━━━━━━━━━━━━\n" \
        --reply_markup "$keyboard6" \
        --parse_mode html
}

delRes() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Delete Reseller :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

reseller_input() {
    file_user=$1
    User=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    Balance=$(sed -n '2 p' $file_user | cut -d' ' -f1)
    if [ "$(grep -wc ${User} /root/multi/reseller)" = '0' ]; then
        echo "$User $Balance" >>/root/multi/reseller
        local msg
        msg="Successful Register Reseller\n\n"
        msg+="$User Balance Is $Balance"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard1" \
            --parse_mode html
        ShellBot.sendMessage --chat_id ${User} \
            --text "$msg" \
            --reply_markup "$keyboard5" \
            --parse_mode html
    else
        local msg
        msg="Already Registered Reseller\n\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard1" \
            --parse_mode html
    fi
}

balance_reseller() {
    file_user=$1
    User=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    Balance=$(sed -n '2 p' $file_user | cut -d' ' -f1)
    ori=$(grep ${User} /root/multi/reseller | awk '{print $2}')
    topup=$(($ori + $Balance))
    sed -i "/${User}/d" /root/multi/reseller
    echo "${User} $topup" >>/root/multi/reseller
    if [ "$(grep -wc ${User} /root/multi/reseller)" != '0' ]; then
        local msg
        msg="$User New Balance Is $topup\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard6" \
            --parse_mode html
    else
        msg="$User Is Not Reseller\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard6" \
            --parse_mode html
    fi
}

delete_reseller() {
    file_user=$1
    User=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    if [ "$(grep -wc ${User} /root/multi/reseller)" != '0' ]; then
        sed -i "/${User}/d" /root/multi/reseller
        msg="$User Successful Deleted\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard6" \
            --parse_mode html
    else
        msg="$User Is Not Reseller\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --reply_markup "$keyboard6" \
            --parse_mode html
    fi
}

reseller_balance() {
    ori=$(grep ${message_from_id} /root/multi/reseller | awk '{print $2}')
    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" != '0' ]; then
        if (($ori < $res_price)); then
            ShellBot.sendMessage --chat_id ${message_from_id[$id]} \
                --text "BAKI TIDAK MENCUKUPI\n\nYOUR BALANCE : RM $ori\n" \
                --reply_markup "$keyboard5" \
                --parse_mode html
            exit 1
        elif (($ori >= $res_price)); then
            topup=$(($ori - $res_price))
            sed -i "/${message_from_id}/d" /root/multi/reseller
            echo "${message_from_id} $topup" >>/root/multi/reseller
        fi
    else
        echo "admin"
    fi
}

add_ssh() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Create User(ssh) :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

del_ssh() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Delete User(ssh) :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

ext_ssh() {
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Extend User(ssh) :" \
        --reply_markup "$(ShellBot.ForceReply)"
}

del_exp() {
    hariini=$(date +%d-%m-%Y)
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d >/tmp/expirelist.txt
    totalaccounts=$(cat /tmp/expirelist.txt | wc -l)
    for ((i = 1; i <= $totalaccounts; i++)); do
        tuserval=$(head -n $i /tmp/expirelist.txt | tail -n 1)
        username=$(echo $tuserval | cut -f1 -d:)
        userexp=$(echo $tuserval | cut -f2 -d:)
        userexpireinseconds=$(($userexp * 86400))
        tglexp=$(date -d @$userexpireinseconds)
        tgl=$(echo $tglexp | awk -F" " '{print $3}')
        while [ ${#tgl} -lt 2 ]; do
            tgl="0"$tgl
        done
        while [ ${#username} -lt 15 ]; do
            username=$username" "
        done
        bulantahun=$(echo $tglexp | awk -F" " '{print $2,$6}')
        echo "echo "Expired- User : $username Expire at : $tgl $bulantahun"" >>/usr/local/bin/alluser
        todaystime=$(date +%s)
        if [ $userexpireinseconds -ge $todaystime ]; then
            :
        else
            echo "echo "Expired- Username : $username are expired at: $tgl $bulantahun and removed : $hariini "" >>/usr/local/bin/deleteduser
            echo "Username $username that are expired at $tgl $bulantahun removed from the VPS $hariini"
            userdel $username
        fi
    done
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "Done Remove Expired User\n" \
        --parse_mode html

}

input_addssh() {
    file_user=$1
    req_limit
    Login=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    Pass=$(sed -n '2 p' $file_user | cut -d' ' -f1)
    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
        masaaktif=$(sed -n '3 p' $file_user | cut -d' ' -f1)
    else
        masaaktif=30
    fi
    masaaktif=$(sed -n '3 p' $file_user | cut -d' ' -f1)
    domain=$(cat /root/domain)
    IP=$(wget -qO- ipinfo.io/ip)
    ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2 | sed 's/ //g')"
    sqd="$(cat ~/log-install.txt | grep -w "Squid Proxy" | cut -d: -f2 | sed 's/ //g')"
    ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
    exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
    echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 OVPN ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n"
    msg+="Thank You For Using Our Services\n"
    msg+="SSH %26 OpenVPN Account Info\n"
    msg+="Username       : $Login\n"
    msg+="Password       : $Pass\n"
    msg+="Expired On     : $exp\n"
    msg+="Host           : ${domain}\n"
    msg+="\n"
    msg+="OpenVPN        : TCP $ovpn http://$IP:81/client-tcp-$ovpn.ovpn\n"
    msg+="OpenVPN        : UDP $ovpn2 http://$IP:81/client-udp-$ovpn2.ovpn\n"
    msg+="OpenVPN        : SSL 442 http://$IP:81/client-tcp-ssl.ovpn\n"
    msg+="━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
}

input_delssh() {
    file_user=$1
    Pengguna=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    if getent passwd $Pengguna >/dev/null 2>&1; then
        userdel $Pengguna
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$Pengguna Was Removed\n" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Failure: User $Pengguna Not Exist\n" \
            --parse_mode html
    fi
}

input_extssh() {
    file_user=$1
    User=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    Days=$(sed -n '2 p' $file_user | cut -d' ' -f1)
    egrep "^$User" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        Today=$(date +%s)
        Days_Detailed=$(($Days * 86400))
        Expire_On=$(($Today + $Days_Detailed))
        Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
        Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
        passwd -u $User
        usermod -e $Expiration $User
        egrep "^$User" /etc/passwd >/dev/null
        echo -e "$Pass\n$Pass\n" | passwd $User &>/dev/null

        local msg
        msg="Username :  $User\n"
        msg+="Days Added :  $Days Days\n"
        msg+="Expires on :  $Expiration_Display\n"

        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    else
        local msg
        msg="Username Doesnt Exist\n"

        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    fi
}

req_ovpn() {
    file_user=$1
    Login=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    Pass=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c3)
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    masaaktif=$(grep $coupon /root/multi/voucher | awk '{print $2}')
    req_voucher $file_user
    req_limit
    domain=$(cat /root/domain)
    IP=$(wget -qO- ipinfo.io/ip)
    ssl="$(cat ~/log-install.txt | grep -w "Stunnel4" | cut -d: -f2 | sed 's/ //g')"
    sqd="$(cat ~/log-install.txt | grep -w "Squid Proxy" | cut -d: -f2 | sed 's/ //g')"
    ovpn="$(netstat -nlpt | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    ovpn2="$(netstat -nlpu | grep -i openvpn | grep -i 0.0.0.0 | awk '{print $4}' | cut -d: -f2)"
    useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
    exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
    echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 OVPN ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n"
    msg+="Thank You For Using Our Services\n"
    msg+="SSH %26 OpenVPN Account Info\n"
    msg+="Username       : $Login\n"
    msg+="Password       : $Pass\n"
    msg+="Expired On     : $exp\n"
    msg+="Host           : ${domain}\n"
    msg+="\n"
    msg+="OpenVPN        : TCP $ovpn http://$IP:81/client-tcp-$ovpn.ovpn\n"
    msg+="OpenVPN        : UDP $ovpn2 http://$IP:81/client-udp-$ovpn2.ovpn\n"
    msg+="OpenVPN        : SSL 442 http://$IP:81/client-tcp-ssl.ovpn\n"
    msg+="━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html

    sed -i "/$coupon/d" /root/multi/voucher
}

create_vmess() {
    file_user=$1
    user=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    expadmin=$(grep $coupon /root/multi/voucher | awk '{print $2}')
    req_voucher $file_user
    req_limit

    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User Already Exist\n" \
            --parse_mode html
        exit 1
    fi
    if [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        duration=$expadmin
    else
        duration=3
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    none=80
    email=${user}
    cat >/etc/scvpn/xray/$user-tls.json <<EOF
      {
       "v": "2",
       "ps": "${user}",
       "add": "${domain}",
       "port": "${multi}",
       "id": "${uuid}",
       "aid": "0",
       "scy": "auto",
       "net": "ws",
       "type": "none",
       "host": "${BUG}",
       "path": "/xrayvws",
       "tls": "tls",
       "sni": "${BUG}"
}
EOF

    cat >/etc/scvpn/xray/$user-none.json <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${none}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/xrayws",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/scvpn/xray/user.txt
    cat /etc/scvpn/xray/conf/05_VMess_WS_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","alterId": 0,"add": "'${domain}'","email": "'${email}'"}]' >/etc/scvpn/xray/conf/05_VMess_WS_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/05_VMess_WS_inbounds_tmp.json /etc/scvpn/xray/conf/05_VMess_WS_inbounds.json
    sed -i '/#xray$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$email""'"' /etc/scvpn/xray/conf/vmess-nontls.json
    vmess_base641=$(base64 -w 0 <<<$vmess_json1)
    vmess_base642=$(base64 -w 0 <<<$vmess_json2)
    vmesslink1="vmess://$(base64 -w 0 /etc/scvpn/xray/$user-tls.json)"
    vmesslink2="vmess://$(base64 -w 0 /etc/scvpn/xray/$user-none.json)"
    cat <<EOF >>"/etc/scvpn/config-user/${user}"
${vmesslink1}
${vmesslink2}
EOF
    base64Result=$(base64 -w 0 /etc/scvpn/config-user/${user})
    echo ${base64Result} >"/etc/scvpn/config-url/${uuid}"
    systemctl restart xray.service

    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Vmess ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="User : $user\n"
    msg+="<code>Expired : $exp</code>\n"
    msg+="\n"
    msg+="Tls\n"
    msg+="<code>$vmesslink1</code>\n"
    msg+="\n"
    msg+="Ntls\n"
    msg+="<code>$vmesslink2</code>\n"
    msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
    sed -i "/$coupon/d" /root/multi/voucher
}

create_vless() {
    file_user=$1
    user=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    expadmin=$(grep $coupon /root/multi/voucher | awk '{print $2}')
    req_voucher $file_user
    req_limit
    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User Already Exist\n" \
            --parse_mode html
        exit 1
    fi
    if [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        duration=$expadmin
    else
        duration=3
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    none=8000
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/scvpn/xray/user.txt
    sed -i '/#xray$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$email""'"' /etc/scvpn/xray/vless-nontls.json
    cat /etc/scvpn/xray/conf/03_VLESS_WS_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","email": "'${email}'"}]' >/etc/scvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json /etc/scvpn/xray/conf/03_VLESS_WS_inbounds.json
    vlesslink1="vless://$uuid@$domain:$multi?encryption=none%26security=tls%26sni=%26type=ws%26host=%26path=/xrayws#$user"
    vlesslink2="vless://$uuid@$domain:$none?encryption=none%26security=none%26sni=%26type=ws%26host=%26path=/xrayws#$user"
    cat <<EOF >>"/etc/scvpn/config-user/${user}"
${vlesslink1}
${vlesslink2}
EOF
    echo ${base64Result} >"/etc/scvpn/config-url/${uuid}"
    systemctl restart xray.service
    systemctl restart xray@n

    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Vless ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="User : $user\n"
    msg+="<code>Expired : $exp</code>\n"
    msg+="\n"
    msg+="Tls\n"
    msg+="<code>$vlesslink1</code>\n"
    msg+="\n"
    msg+="Ntls\n"
    msg+="<code>$vlesslink2</code>\n"
    msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
    sed -i "/$coupon/d" /root/multi/voucher
}

create_xtls() {
    file_user=$1
    user=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    expadmin=$(grep $coupon /root/multi/voucher | awk '{print $2}')
    req_voucher $file_user
    req_limit
    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User Already Exist\n" \
            --parse_mode html
        exit 1
    fi
    if [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        duration=$expadmin
    else
        duration=3
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/scvpn/xray/user.txt
    cat /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds.json | jq '.inbounds[0].settings.clients += [{"id": "'${uuid}'","add": "'${domain}'","flow": "xtls-rprx-direct","email": "'${email}'"}]' >/etc/scvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds.json
    splice="vless://$uuid@$domain:$multi?flow=xtls-rprx-splice%26encryption=none%26security=xtls%26sni=%26type=tcp%26headerType=none%26host=#$user"
    direct="vless://$uuid@$domain:$multi?flow=xtls-rprx-direct%26encryption=none%26security=xtls%26sni=%26type=tcp%26headerType=none%26host=#$user"
    cat <<EOF >>"/etc/scvpn/config-user/${user}"
${splice}
${direct}
EOF
    systemctl restart xray

    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Xtls ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="User : $user\n"
    msg+="<code>Expired : $exp</code>\n"
    msg+="\n"
    msg+="Splice\n"
    msg+="<code>$splice</code>\n"
    msg+="\n"
    msg+="Direct\n"
    msg+="<code>$direct</code>\n"
    msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
    sed -i "/$coupon/d" /root/multi/voucher
}

create_trojan() {
    file_user=$1
    user=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    coupon=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    expadmin=$(grep $coupon /root/multi/voucher | awk '{print $2}')
    req_voucher $file_user
    req_limit
    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User Already Exist\n" \
            --parse_mode html
        exit 1
    fi
    if [ "$(grep -wc $coupon /root/multi/voucher)" != '0' ]; then
        duration=$expadmin
    else
        duration=3
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid)
    exp=$(date -d +${duration}days +%Y-%m-%d)
    domain=$(cat /root/domain)
    multi="$(cat ~/log-install.txt | grep -w "VLess TCP XTLS" | cut -d: -f2 | sed 's/ //g')"
    email=${user}
    echo -e "${user}\t${uuid}\t${exp}" >>/etc/scvpn/xray/user.txt
    cat /etc/scvpn/xray/conf/04_trojan_TCP_inbounds.json | jq '.inbounds[0].settings.clients += [{"password": "'${uuid}'","email": "'${email}'"}]' >/etc/scvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json /etc/scvpn/xray/conf/04_trojan_TCP_inbounds.json
    tro="trojan://$uuid@$domain:$multi?sni=#$user"
    cat <<EOF >>"/etc/scvpn/config-user/${user}"
${tro}
EOF
    systemctl restart xray
    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Trojan ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="User : $user\n"
    msg+="<code>Expired : $exp</code>\n"
    msg+="\n"
    msg+="Trojan\n"
    msg+="<code>$tro</code>\n"
    msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
    sed -i "/$coupon/d" /root/multi/voucher
}

del_conf() {
    file_user=$1
    user=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    if ! grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User does not exist\n" \
            --parse_mode html
        exit 1
    fi
    uuid="$(cat /etc/scvpn/xray/user.txt | grep -w "$user" | awk '{print $2}')"
    exp="$(cat /etc/scvpn/xray/user.txt | grep -w "$user" | awk '{print $3}')"
    cat /etc/scvpn/xray/conf/05_VMess_WS_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/scvpn/xray/conf/05_VMess_WS_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/05_VMess_WS_inbounds_tmp.json /etc/scvpn/xray/conf/05_VMess_WS_inbounds.json
    sed -i "/^### $user $exp/,/^},{/d" /etc/scvpn/xray/conf/vmess-nontls.json
    cat /etc/scvpn/xray/conf/03_VLESS_WS_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/scvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/03_VLESS_WS_inbounds_tmp.json /etc/scvpn/xray/conf/03_VLESS_WS_inbounds.json
    sed -i "/^### $user $exp/,/^},{/d" /etc/scvpn/xray/vless-nontls.json
    cat /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.id == "'${uuid}'"))' >/etc/scvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds_tmp.json /etc/scvpn/xray/conf/02_VLESS_TCP_inbounds.json
    cat /etc/scvpn/xray/conf/04_trojan_TCP_inbounds.json | jq 'del(.inbounds[0].settings.clients[] | select(.password == "'${uuid}'"))' >/etc/scvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json
    mv -f /etc/scvpn/xray/conf/04_trojan_TCP_inbounds_tmp.json /etc/scvpn/xray/conf/04_trojan_TCP_inbounds.json
    sed -i "/\b$user\b/d" /etc/scvpn/xray/user.txt
    rm /etc/scvpn/config-user/${user} >/dev/null 2>&1
    rm /etc/scvpn/config-url/${uuid} >/dev/null 2>&1
    systemctl restart xray.service
    systemctl restart xray@n
    systemctl restart xray.service

    local msg
    msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Delete ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
    msg+="User : $user\n"
    msg+="<code>Expired : $exp</code>\n"
    msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --parse_mode html
}

ext_conf() {
    file_user=$1
    user=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
        masaaktif=$(sed -n '2 p' $file_user | cut -d' ' -f1)
    else
        masaaktif=30
    fi
    if ! grep -qw "$user" /etc/scvpn/xray/user.txt; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "User does not exist\n" \
            --parse_mode html
        exit 1
    else
        uuid=$(grep -wE "$user" "/etc/scvpn/xray/user.txt" | awk '{print $2}')
        exp=$(grep -wE "$user" "/etc/scvpn/xray/user.txt" | awk '{print $3}')
        now=$(date +%Y-%m-%d)
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp2=$(((d1 - d2) / 86400))
        exp3=$(($exp2 + $masaaktif))
        exp4=$(date -d "$exp3 days" +"%Y-%m-%d")
        sed -i "/$user/d" /etc/scvpn/xray/user.txt
        echo -e "${user}\t${uuid}\t${exp4}" >>/etc/scvpn/xray/user.txt
        systemctl restart xray.service >/dev/null 2>&1
        systemctl restart xray@n >/dev/null 2>&1
        systemctl restart xray.service >/dev/null 2>&1

        local msg
        msg="━━━━━━━━━━━━━━━━━━━━━\n<b>🔸 Extend ACCOUNT 🔸 </b>\n━━━━━━━━━━━━━━━━━━━━━\n\n"
        msg+="User : $user\n"
        msg+="<code>Expired : $exp4</code>\n"
        msg+="\n━━━━━━━━━━━━━━━━━━━━━\n"

        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$msg" \
            --parse_mode html
    fi
}

start_req() {
    file_user=$1
    config=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '1p')
    user=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '2p')
    pass=$(grep 'start [^_]*' $file_user | grep -o '[^_]*' | cut -d' ' -f2 | sed -n '3p')
    if [ "${config}" == "vmess" ]; then
        create_vmess $file_user
    elif [ "${config}" == "vless" ]; then
        create_vless $file_user
    elif [ "${config}" == "xtls" ]; then
        create_xtls $file_user
    elif [ "${config}" == "trojan" ]; then
        create_trojan $file_user
    elif [ "${config}" == "ovpn" ]; then
        req_ovpn $file_user
    elif [ "${config}" == "free" ]; then
        freeReq $file_user
    elif [ "${config}" == "voucher" ]; then
        echo "$user" >$file_user
        input_voucher $file_user
    else
        msg_welcome
    fi
}

input_voucher() {
    file_user=$1
    voucher=$(sed -n '1 p' $file_user | cut -d' ' -f1)
    if [ "$(grep -wc $voucher /root/multi/voucher)" != '0' ]; then
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Valid Voucher\n" \
            --reply_markup "$keyboard8" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Not A Valid Voucher\n" \
            --parse_mode html
        exit 1
    fi
}

restartReq() {
    if [ "${message_from_id[$id]}" == "$get_AdminID" ]; then
        systemctl restart stunnel4
        systemctl restart xray.service
        systemctl restart xray@n
        systemctl restart xray.service
        systemctl restart dropbear
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "Done Restart All Service" \
            --parse_mode html
    else
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "❌Access Deny❌\n" \
            --parse_mode html
    fi
}

unset menu1
menu1=''
ShellBot.InlineKeyboardButton --button 'menu1' --line 1 --text '• Menu SSH •️' --callback_data '_menussh'
ShellBot.InlineKeyboardButton --button 'menu1' --line 1 --text '• Menu Xray •️' --callback_data '_menuxray'
ShellBot.InlineKeyboardButton --button 'menu1' --line 2 --text '• Reseller •️' --callback_data '_resellerMenu'
ShellBot.InlineKeyboardButton --button 'menu1' --line 2 --text '• Voucher Generator •️' --callback_data '_voucherGenerator'
ShellBot.InlineKeyboardButton --button 'menu1' --line 3 --text '• Public Mode •️' --callback_data '_publicMode'
ShellBot.InlineKeyboardButton --button 'menu1' --line 3 --text '• Limit Free •️' --callback_data '_freelimit'
ShellBot.regHandleFunction --function menuSsh --callback_data _menussh
ShellBot.regHandleFunction --function menuXray --callback_data _menuxray
ShellBot.regHandleFunction --function menuRes --callback_data _resellerMenu
ShellBot.regHandleFunction --function generatorReq --callback_data _voucherGenerator
ShellBot.regHandleFunction --function publicReq --callback_data _publicMode
ShellBot.regHandleFunction --function freelimitReq --callback_data _freelimit
unset keyboard1
keyboard1="$(ShellBot.InlineKeyboardMarkup -b 'menu1')"

unset menu2
menu2=''
ShellBot.InlineKeyboardButton --button 'menu2' --line 1 --text '• Vmess •️' --callback_data '_addvmess'
ShellBot.InlineKeyboardButton --button 'menu2' --line 1 --text '• Vless •️' --callback_data '_addvless'
ShellBot.InlineKeyboardButton --button 'menu2' --line 2 --text '• Xtls •️' --callback_data '_addxtls'
ShellBot.InlineKeyboardButton --button 'menu2' --line 2 --text '• Trojan •️' --callback_data '_addtrojan'
ShellBot.InlineKeyboardButton --button 'menu2' --line 3 --text '• Delete User •️' --callback_data '_delconf'
ShellBot.InlineKeyboardButton --button 'menu2' --line 3 --text '• Extend User •️' --callback_data '_extconf'
ShellBot.InlineKeyboardButton --button 'menu2' --line 4 --text '🔙 Back 🔙' --callback_data '_back2'
ShellBot.regHandleFunction --function req_url --callback_data _addvmess
ShellBot.regHandleFunction --function req_url --callback_data _addvless
ShellBot.regHandleFunction --function req_url --callback_data _addxtls
ShellBot.regHandleFunction --function req_url --callback_data _addtrojan
ShellBot.regHandleFunction --function req_del --callback_data _delconf
ShellBot.regHandleFunction --function req_ext --callback_data _extconf
ShellBot.regHandleFunction --function backReq --callback_data _back2
unset keyboard2
keyboard2="$(ShellBot.InlineKeyboardMarkup -b 'menu2')"

unset menu3
menu3=''
ShellBot.InlineKeyboardButton --button 'menu3' --line 1 --text '• Vmess •️' --callback_data '_freevmess'
ShellBot.InlineKeyboardButton --button 'menu3' --line 1 --text '• Vless •️' --callback_data '_freevless'
ShellBot.InlineKeyboardButton --button 'menu3' --line 2 --text '• Xtls •️' --callback_data '_freextls'
ShellBot.InlineKeyboardButton --button 'menu3' --line 2 --text '• Trojan •️' --callback_data '_freetrojan'
ShellBot.regHandleFunction --function req_free --callback_data _freevmess
ShellBot.regHandleFunction --function req_free --callback_data _freevless
ShellBot.regHandleFunction --function req_free --callback_data _freextls
ShellBot.regHandleFunction --function req_free --callback_data _freetrojan
unset keyboard3
keyboard3="$(ShellBot.InlineKeyboardMarkup -b 'menu3')"

unset menu4
menu4=''
ShellBot.InlineKeyboardButton --button 'menu4' --line 1 --text '• Create User •️' --callback_data '_addssh'
ShellBot.InlineKeyboardButton --button 'menu4' --line 1 --text '• Delete User •️' --callback_data '_delssh'
ShellBot.InlineKeyboardButton --button 'menu4' --line 2 --text '• Delete Expired •️' --callback_data '_delexp'
ShellBot.InlineKeyboardButton --button 'menu4' --line 2 --text '• Extend User •️' --callback_data '_extssh'
ShellBot.InlineKeyboardButton --button 'menu4' --line 3 --text '• Voucher OVPN •️' --callback_data '_voucherOVPN'
ShellBot.InlineKeyboardButton --button 'menu4' --line 4 --text '🔙 Back 🔙' --callback_data '_back4'
ShellBot.regHandleFunction --function add_ssh --callback_data _addssh
ShellBot.regHandleFunction --function del_ssh --callback_data _delssh
ShellBot.regHandleFunction --function del_exp --callback_data _delexp
ShellBot.regHandleFunction --function ext_ssh --callback_data _extssh
ShellBot.regHandleFunction --function req_url --callback_data _voucherOVPN
ShellBot.regHandleFunction --function backReq --callback_data _back4
unset keyboard4
keyboard4="$(ShellBot.InlineKeyboardMarkup -b 'menu4')"

unset menu5
menu5=''
ShellBot.InlineKeyboardButton --button 'menu5' --line 1 --text '• Menu SSH •️' --callback_data '_menussh5'
ShellBot.InlineKeyboardButton --button 'menu5' --line 1 --text '• Menu Xray •️' --callback_data '_menuxray5'
ShellBot.regHandleFunction --function menuSsh --callback_data _menussh5
ShellBot.regHandleFunction --function menuXray --callback_data _menuxray5
unset keyboard5
keyboard5="$(ShellBot.InlineKeyboardMarkup -b 'menu5')"

unset menu6
menu6=''
ShellBot.InlineKeyboardButton --button 'menu6' --line 1 --text '• Register Reseller •️' --callback_data '_resellerReq'
ShellBot.InlineKeyboardButton --button 'menu6' --line 1 --text '• Add Balance •️' --callback_data '_balRes'
ShellBot.InlineKeyboardButton --button 'menu6' --line 2 --text '• All Reseller •️' --callback_data '_allRes'
ShellBot.InlineKeyboardButton --button 'menu6' --line 2 --text '• Delete Reseller •️' --callback_data '_delRes'
ShellBot.InlineKeyboardButton --button 'menu6' --line 3 --text '🔙 Back 🔙' --callback_data '_back6'
ShellBot.regHandleFunction --function resellerReq --callback_data _resellerReq
ShellBot.regHandleFunction --function balRes --callback_data _balRes
ShellBot.regHandleFunction --function allRes --callback_data _allRes
ShellBot.regHandleFunction --function delRes --callback_data _delRes
ShellBot.regHandleFunction --function backReq --callback_data _back6
unset keyboard6
keyboard6="$(ShellBot.InlineKeyboardMarkup -b 'menu6')"

unset menu7
menu7=''
ShellBot.InlineKeyboardButton --button 'menu7' --line 1 --text '• Claim Voucher •️' --callback_data '_claimvoucher'
ShellBot.regHandleFunction --function voucher_req --callback_data _claimvoucher
unset keyboard7
keyboard7="$(ShellBot.InlineKeyboardMarkup -b 'menu7')"

unset menu8
menu8=''
ShellBot.InlineKeyboardButton --button 'menu8' --line 1 --text '• Vmess •️' --callback_data '_vouchervmess'
ShellBot.InlineKeyboardButton --button 'menu8' --line 1 --text '• Vless •️' --callback_data '_vouchervless'
ShellBot.InlineKeyboardButton --button 'menu8' --line 2 --text '• Xtls •️' --callback_data '_voucherxtls'
ShellBot.InlineKeyboardButton --button 'menu8' --line 2 --text '• Trojan •️' --callback_data '_vouchertrojan'
ShellBot.InlineKeyboardButton --button 'menu8' --line 3 --text '• Ovpn •️' --callback_data '_voucherovpn'
ShellBot.regHandleFunction --function link_voucher --callback_data _vouchervmess
ShellBot.regHandleFunction --function link_voucher --callback_data _vouchervless
ShellBot.regHandleFunction --function link_voucher --callback_data _voucherxtls
ShellBot.regHandleFunction --function link_voucher --callback_data _vouchertrojan
ShellBot.regHandleFunction --function link_voucher --callback_data _voucherovpn
unset keyboard8
keyboard8="$(ShellBot.InlineKeyboardMarkup -b 'menu8')"

while :; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 35
    for id in $(ShellBot.ListUpdates); do
        (
            ShellBot.watchHandle --callback_data ${callback_query_data[$id]}
            [[ ${message_chat_type[$id]} != 'private' ]] && {
                ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                    --text "$(echo -e "⛔ only run this command on private chat / pm on bot")" \
                    --parse_mode html
                >$CAD_ARQ
                break
                ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                    --text "Func Error Do Nothing" \
                    --reply_markup "$(ShellBot.ForceReply)"
            }
            CAD_ARQ=/tmp/cad.${message_from_id[$id]}
            if [[ ${message_entities_type[$id]} == bot_command ]]; then
                case ${message_text[$id]} in
                *)
                    :
                    comando=(${message_text[$id]})
                    [[ "${comando[0]}" = "/free" ]] && freeReq
                    [[ "${comando[0]}" = "/claim" ]] && claimVoucher
                    [[ "${comando[0]}" = "/restart" ]] && restartReq
                    ;;
                esac
            fi
            if [[ ${message_entities_type[$id]} == bot_command ]]; then
                echo "${message_text[$id]}" >$CAD_ARQ
                if [ "$(awk '{print $1}' $CAD_ARQ)" = '/start' ]; then
                    start_req $CAD_ARQ
                fi
            fi
            if [[ ${message_reply_to_message_message_id[$id]} ]]; then
                case ${message_reply_to_message_text[$id]} in
                'Create User(ssh) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Create Pass(ssh) :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Create Pass(ssh) :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Create Expired(ssh) :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Create Expired(ssh) :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    reseller_balance
                    input_addssh $CAD_ARQ
                    ;;
                'Delete User(ssh) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    input_delssh $CAD_ARQ
                    ;;
                'Extend User(ssh) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Extend Expired(ssh) :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Extend Expired(ssh) :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    reseller_balance
                    input_extssh $CAD_ARQ
                    ;;
                'OVPN (USER EXPIRED) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    reseller_balance
                    user=$(cut -d' ' -f1 $CAD_ARQ)
                    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
                        exp=$(cut -d' ' -f2 $CAD_ARQ)
                    else
                        exp=30
                    fi
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    echo "$vouch $exp" >>/root/multi/voucher
                    local msg
                    msg="User : $user\n"
                    msg+="<code>Expired : $exp</code>\n\n"
                    msg+="https://t.me/${get_botName}?start=ovpn_${user}_${vouch}\n"
                    msg+="Click Link To Confirm OVPN Acc\n"

                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "$msg" \
                        --parse_mode html
                    ;;
                'Vmess (USER EXPIRED) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    reseller_balance
                    user=$(cut -d' ' -f1 $CAD_ARQ)
                    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
                        exp=$(cut -d' ' -f2 $CAD_ARQ)
                    else
                        exp=30
                    fi
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "User Already Exist\n" \
                            --parse_mode html
                        exit 1
                    else
                        echo "$vouch $exp" >>/root/multi/voucher
                        local msg
                        msg="User : $user\n"
                        msg+="<code>Expired : $exp</code>\n\n"
                        msg+="https://t.me/${get_botName}?start=vmess_${user}_${vouch}\n"
                        msg+="Click Link To Confirm Vmess Acc\n"

                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$msg" \
                            --parse_mode html
                    fi
                    ;;
                'Vless (USER EXPIRED) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    reseller_balance
                    user=$(cut -d' ' -f1 $CAD_ARQ)
                    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
                        exp=$(cut -d' ' -f2 $CAD_ARQ)
                    else
                        exp=30
                    fi
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "User Already Exist\n" \
                            --parse_mode html
                        exit 1
                    else
                        echo "$vouch $exp" >>/root/multi/voucher
                        local msg
                        msg="User : $user\n"
                        msg+="<code>Expired : $exp</code>\n\n"
                        msg+="https://t.me/${get_botName}?start=vless_${user}_${vouch}\n"
                        msg+="Click Link To Confirm Vless Acc\n"

                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$msg" \
                            --parse_mode html
                    fi
                    ;;
                'Xtls (USER EXPIRED) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    reseller_balance
                    user=$(cut -d' ' -f1 $CAD_ARQ)
                    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
                        exp=$(cut -d' ' -f2 $CAD_ARQ)
                    else
                        exp=30
                    fi
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "User Already Exist\n" \
                            --parse_mode html
                        exit 1
                    else
                        echo "$vouch $exp" >>/root/multi/voucher
                        local msg
                        msg="User : $user\n"
                        msg+="<code>Expired : $exp</code>\n\n"
                        msg+="https://t.me/${get_botName}?start=xtls_${user}_${vouch}\n"
                        msg+="Click Link To Confirm Xtls Acc\n"

                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$msg" \
                            --parse_mode html
                    fi
                    ;;
                'Trojan (USER EXPIRED) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    reseller_balance
                    user=$(cut -d' ' -f1 $CAD_ARQ)
                    if [ "$(grep -wc ${message_from_id} /root/multi/reseller)" = '0' ]; then
                        exp=$(cut -d' ' -f2 $CAD_ARQ)
                    else
                        exp=30
                    fi
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    if grep -qw "$user" /etc/scvpn/xray/user.txt; then
                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "User Already Exist\n" \
                            --parse_mode html
                        exit 1
                    else
                        echo "$vouch $exp" >>/root/multi/voucher
                        local msg
                        msg="User : $user\n"
                        msg+="<code>Expired : $exp</code>\n\n"
                        msg+="https://t.me/${get_botName}?start=trojan_${user}_${vouch}\n"
                        msg+="Click Link To Confirm Trojan Acc\n"

                        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                            --text "$msg" \
                            --parse_mode html
                    fi
                    ;;
                'Vmess(free) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    userfree=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    echo "start vmess_public${userfree}_free" >$CAD_ARQ
                    create_vmess $CAD_ARQ
                    ;;
                'Vless(free) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    userfree=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    echo "start vmess_public${userfree}_free" >$CAD_ARQ
                    create_vless $CAD_ARQ
                    ;;
                'Xtls(free) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    userfree=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    echo "start vmess_public${userfree}_free" >$CAD_ARQ
                    create_xtls $CAD_ARQ
                    ;;
                'Trojan(free) :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    userfree=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    echo "start vmess_public${userfree}_free" >$CAD_ARQ
                    create_trojan $CAD_ARQ
                    ;;
                'Del User :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    del_conf $CAD_ARQ
                    ;;
                'Extend User :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Extend Day :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Extend Day :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    reseller_balance
                    ext_conf $CAD_ARQ
                    ;;
                'Create Reseller :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Reseller Balance :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Reseller Balance :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    reseller_input $CAD_ARQ
                    ;;
                'Add Balance Reseller :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "Add Balance :" \
                        --reply_markup "$(ShellBot.ForceReply)"
                    ;;
                'Add Balance :')
                    echo "${message_text[$id]}" >>$CAD_ARQ
                    balance_reseller $CAD_ARQ
                    ;;
                'Delete Reseller :')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    delete_reseller $CAD_ARQ
                    ;;
                'Input Your Voucher:')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    input_voucher $CAD_ARQ
                    ;;
                'Voucher Validity:')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    vouch=$(tr </dev/urandom -dc a-zA-Z0-9 | head -c8)
                    exp=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    echo "$vouch $exp" >>/root/multi/voucher
                    local msg
                    msg="<code>Expired : $exp</code>\n"
                    msg+="Voucher : <code>$vouch</code>\n"
                    msg+="<a href='https://t.me/${get_botName}?start=voucher_${vouch}'>Click Here To Claim</a>\n"

                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "$msg" \
                        --parse_mode html
                    ;;
                'Change Limit:')
                    echo "${message_text[$id]}" >$CAD_ARQ
                    freelim=$(sed -n '1 p' $CAD_ARQ | cut -d' ' -f1)
                    sed -i "/Limit/d" /root/multi/bot.conf
                    echo "Limit: $freelim" >>/root/multi/bot.conf
                    local msg
                    msg="Free Limit Successful Change To $freelim"
                    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                        --text "$msg" \
                        --parse_mode html
                    ;;
                esac
            fi
        ) &
    done
done
