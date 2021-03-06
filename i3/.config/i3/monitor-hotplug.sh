#!/bin/bash

exec >>/tmp/hotplug.log 2>&1

export DISPLAY=":1"
export XAUTHORITY=$(ps -C Xorg -f --no-header | grep stan | sed -n 's/.*-auth //; s/ -[^ ].*//; p')

CONNECTED=`/usr/bin/xrandr --query | grep connected |grep -v disconnected | awk '{print $1}'`
DISCONNECTED=`/usr/bin/xrandr --query | grep disconnected | awk '{print $1}'`

CONNECTED_LENGTH=`wc -w <<< $CONNECTED`

query='/usr/bin/xrandr'

for monitor in $DISCONNECTED; do
    query="$query --output $monitor --off"
done

case $CONNECTED_LENGTH in
    4)
        query="$query --output eDP-1 --off"
        counter=0
        for monitor in $CONNECTED; do
            if [ $monitor == "eDP-1" ];then
                continue
            elif [ $counter -eq 0 ];then
                query="$query --output $monitor --auto"
            else
                query="$query --output $monitor --auto --left-of $old"
            fi 
            old=$monitor
            counter=$((counter + 1))
        done
        $query
        ;;
    *)
        counter=0
        for monitor in $CONNECTED; do
            if [ $counter -eq 0 ];then
                query="$query --output $monitor --auto"
            else
                query="$query --output $monitor --auto --left-of $old"
            fi
            old=$monitor
            counter=$((counter + 1))
        done
        $query
        ;;
esac

echo $query >> /tmp/hotplug
