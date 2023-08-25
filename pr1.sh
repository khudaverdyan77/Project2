#!/bin/bash

logfile_path="/var/log/auth.log"
threshold=3
ban_duration="1m"

#popoxakan stexcelu hamar e (-A area, -g global)
declare -A ip_count
declare -A ip_banned

block_ip() {
    local ip="$1"
    if [ -z "${ip_banned[$ip]}" ]; then
        iptables -A INPUT -s "$ip" -j DROP
        echo "Blocked IP: $ip"
        ip_banned["$ip"]=true
    fi
}

parse_log() {
    local logline="$1"
    if [[ $logline =~ Failed\ password\ for.*from\ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        local ip="${BASH_REMATCH[1]}"
        if [ -n "${ip_count[$ip]}" ]; then
            ((ip_count["$ip"]++))
            if [ "${ip_count["$ip"]}" -ge "$threshold" ]; then
                block_ip "$ip"
            fi
        else
            ip_count["$ip"]=1
        fi
    fi
}

trap "echo 'Script terminated.'; exit" INT

#IFS = Internal Field Separator, C-i split funkciayi nman ban e (default bajanum e probelnerov) tvel enq datark arjeq vor vstah
#linenq vor read-y knduni amboxj toxy aranc skzbic ev verjic probelner jnjelu
#amverj ciklov vercnum e logfile-i meji verjin 10 toxi popoxutyunnery ev talis e read hramanin vory C lezvi scanf funkciayi nmanakn e
#ete tail hramany grver cikli mej, ajn kashxater cikli amen krugi jamanak, isk ayspes kashxati miayn ayn jamanak er faylum popoxutyun e texi unenum
#tail hramany nor toxer gtnelu hamar e
#(< <)-y (<<)heredoc-y che ayn procesi subsitition-i hamar e (ete jisht em haskacel zut vstah linelu hamar e vor read-in hasel e tail-i outputy)
#arajin <- jnjum e popoxakani meji exacy (qani vor uni datark argument(chuni yndhanrapes)) heto talis e tail-i outpoty
#-n0 verjic skselu hamar e, -F stugum e 10 tox (erevi)
while true; do
    while IFS= read -r line; do
        parse_log "$line"
    done < <(tail -n0 -F "$logfile_path")

    sleep 10
done

