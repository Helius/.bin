#!/bin/bash

prev_total=`cat ~/.cpu_prev_total`
prev_idle=`cat ~/.cpu_prev_idle`

	cpu=`cat /proc/stat | head -n1 | sed 's/cpu //'`
	user=`echo $cpu | awk '{print $1}'`
	system=`echo $cpu | awk '{print $2}'`
	nice=`echo $cpu | awk '{print $3}'`
	idle=`echo $cpu | awk '{print $4}'`
	wait=`echo $cpu | awk '{print $5}'`
	irq=`echo $cpu | awk '{print $6}'`
	srq=`echo $cpu | awk '{print $7}'`
	zero=`echo $cpu | awk '{print $8}'`
	total=$(($user+$system+$nice+$idle+$wait+$irq+$srq+$zero))
	diff_idle=$(($idle-$prev_idle))
	diff_total=$(($total-$prev_total))
	usage=$(($((1000*$(($diff_total-$diff_idle))/$diff_total+5))/10))
	echo "$usage"
	prev_total=$total
	prev_idle=$idle
	
echo $prev_total > ~/.cpu_prev_total
echo $prev_idle > ~/.cpu_prev_idle

