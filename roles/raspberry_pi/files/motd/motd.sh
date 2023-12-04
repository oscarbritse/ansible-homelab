#!/bin/bash

# 10-hostname-color.sh
/usr/bin/env figlet "$(hostname)" | /usr/bin/env lolcat -f

# 20-sysinfo.sh
# get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(cat /proc/loadavg | awk '{ print $1,$2,$3 }')
# get free memory
IFS=" " read USED AVAIL TOTAL <<<$(free -htm | grep "Mem" | awk {'print $3,$7,$2'})
# get processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
PROCESS_ALL=`echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
PROCESS_ROOT=`echo "$PROCESS"| grep root | awk {'print $2'}`
PROCESS_USER=`echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
# get processors
PROCESSOR_NAME=`grep "model name" /proc/cpuinfo | cut -d ' ' -f3- | awk {'print $0'} | head -1`
PROCESSOR_COUNT=`grep -ioP 'processor\t:' /proc/cpuinfo | wc -l`

CPU_TEMP_0=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP_1=$(($CPU_TEMP_0/1000))
CPU_TEMP_2=$(($CPU_TEMP_0/100))
CPU_TEMP_M=$(($CPU_TEMP_2 % $CPU_TEMP_1))

TIME_ZONE=`cat /etc/timezone | awk '{ print $1 }'`

LAST_LOGIN=`last --time-format iso -20 | grep -v "^reboot" | awk 'NR==2 { print $1" "$4" "$3 }'`
LAST_LOGIN_USER=`echo "$LAST_LOGIN" | awk '{print $1}'`
LAST_LOGIN_TIME=`echo "$LAST_LOGIN" | awk '{print $2}' | xargs -I{} date -d {} +'%Y-%m-%d %H:%M:%S %Z'`
LAST_LOGIN_IP_ADDRESS=`echo "$LAST_LOGIN" | awk '{print $3}'`

W="\e[0;39m"
G="\e[1;32m"
B="\e[1;39m"

echo -e "
${B}system:
$W  host........: $W`uname -n`
$W  model.......: $W`tr -d '\0' </proc/device-tree/model | awk '{print $0}'`
$W  distro......: $W`cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g'`
$W  kernel......: $W`uname -sr`
$W  arch........: $W`uname -m`

${B}status:
$W  ip lan......: $W`ifconfig wlan0 | sed -n "s/^ *inet [^0-9.]*\([0-9.]*\) .*$/\1/p"`
$W  last login..: $W$LAST_LOGIN_USER | $LAST_LOGIN_TIME | $LAST_LOGIN_IP_ADDRESS
$W  time........: $W`(date +"%Y-%m-%d %T %Z")`
$W  uptime......: $W`uptime -p`

${B}resources:
$W  cpu temp....: $G$CPU_TEMP_1.$CPU_TEMP_M$W°C
$W  gpu temp....: $G`(vcgencmd measure_temp | cut -c "6-9")`$WºC

$W  load........: $G$LOAD1$W (1m), $G$LOAD5$W (5m), $G$LOAD15$W (15m)
$W  processes...:$W $G$PROCESS_ROOT$W (root), $G$PROCESS_USER$W (user), $G$PROCESS_ALL$W (total)

$W  cpu.........: $G$PROCESSOR_COUNT$W CPU
$W  memory......: $G$USED$W used, $G$AVAIL$W available, $G$TOTAL$W total$W"

# 35-diskspace.sh
# config
max_usage=90
bar_width=50
# colors
white="\e[39m"
green="\e[1;32m"
red="\e[1;31m"
dim="\e[2m"
undim="\e[0m"

# disk usage: ignore zfs, squashfs & tmpfs
mapfile -t dfs < <(df -H -x zfs -x squashfs -x tmpfs -x devtmpfs -x overlay --output=target,pcent,size | tail -n+2)
printf "$B \ndisk: $W \n"

for line in "${dfs[@]}"; do
    # get disk usage
    usage=$(echo "$line" | awk '{print $2}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="="
    done
    # print dimmmed bar until end
    bar+="${white}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="="
    done
    bar+="${undim}]"
    # print usage line & bar
    echo "${line}" | awk '{ printf("%-31s%+3s used out of %+4s\n", $1, $2, $3); }' | sed -e 's/^/  /'
    echo -e "${bar}" | sed -e 's/^/  /'
done

# 40-services.sh
# set column width
COLUMNS=3
# colors
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

services=("")
# sort services
IFS=$'\n' services=($(sort <<<"${services[*]}"))
unset IFS

service_status=()
# get status of all services
for service in "${services[@]}"; do
    service_status+=($(systemctl is-active "$service"))
done

out=""
for i in ${!services[@]}; do
    # color green if service is active, else red
    if [[ "${service_status[$i]}" == "active" ]]; then
        out+="${services[$i]}:,${green}${service_status[$i]}${undim},"
    else
        out+="${services[$i]}:,${red}${service_status[$i]}${undim},"
    fi
    # insert \n every $COLUMNS column
    if [ $((($i+1) % $COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n"

printf "$B \nservices: $W \n"
printf "$out" | column -ts $',' | sed -e 's/^/  /'

# 60-docker.sh
# set column width
COLUMNS=2
# colors
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

mapfile -t containers < <(docker ps -a --format '{{.Names}}\t{{.Status}}' | sort -k1 | awk '{ print $1,$2 }')

out=""
for i in "${!containers[@]}"; do
    IFS=" " read name status <<< ${containers[i]}
    # color green if service is active, else red
    if [[ "${status}" == "Up" ]]; then
        out+="${name}:,${green}${status,,}${undim},"
    else
        out+="${name}:,${red}${status,,}${undim},"
    fi
    # insert \n every $COLUMNS column
    if [ $((($i+1) % $COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n"

printf "$B \ndocker: $W \n"
printf "$out" | column -ts $',' | sed -e 's/^/  /'
