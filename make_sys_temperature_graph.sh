#!/bin/bash

DATE=`date +"%s"`
START=$(( DATE - 86400 ))

NOW_HOUR=`date +%H`
NOW_MIN=`date +%M`
NOW_SEC=`date +%S`

rrdtool graph /home/eugene/temp.png \
	--start $START --end $DATE --vertical-label C \
	-e now \
	-s 'end - 48 hours' \
	-S 300 \
	--title "Atom server system temperature (48h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 20 \
	--upper-limit 80 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:mb=/home/eugene/db/tmp.rrd:mb:AVERAGE LINE2:mb#0000FF:motherboard \
	DEF:core0=/home/eugene/db/tmp.rrd:core0:AVERAGE LINE2:core0#FFA600:core0 \
	DEF:core1=/home/eugene/db/tmp.rrd:core1:AVERAGE LINE2:core1#FF6A00:core1 \
	DEF:sda=/home/eugene/db/tmp.rrd:sda:AVERAGE LINE2:sda#00C8FF:sda \
	DEF:sdb=/home/eugene/db/tmp.rrd:sdb:AVERAGE LINE2:sdb#00FFA6:sdb \
	COMMENT:"TIME \: $NOW_HOUR\:$NOW_MIN\:$NOW_SEC"

rrdtool graph /home/eugene/temp_cpu.png \
	--start $START --end $DATE --vertical-label C \
	-e now \
	-s 'end - 48 hours' \
	-S 300 \
	--title "Atom server cpu load (48h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 0 \
	--upper-limit 100 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:cpuusage=/home/eugene/db/tmp.rrd:cpuusage:AVERAGE LINE2:cpuusage#FF0000:CPU \
	COMMENT:"TIME \: $NOW_HOUR\:$NOW_MIN\:$NOW_SEC"


rrdtool graph /home/eugene/temp1.png \
	--start $START --end $DATE --vertical-label C \
	-e now \
	-s 'end - 3 hours' \
	-S 1 \
	--title "Atom server system temperature (3h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 20 \
	--upper-limit 80 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:mb=/home/eugene/db/tmp.rrd:mb:AVERAGE LINE2:mb#0000FF:motherboard \
	DEF:core0=/home/eugene/db/tmp.rrd:core0:AVERAGE LINE2:core0#FFA600:core0 \
	DEF:core1=/home/eugene/db/tmp.rrd:core1:AVERAGE LINE2:core1#FF6A00:core1 \
	DEF:sda=/home/eugene/db/tmp.rrd:sda:AVERAGE LINE2:sda#00C8FF:sda \
	DEF:sdb=/home/eugene/db/tmp.rrd:sdb:AVERAGE LINE2:sdb#00FFA6:sdb \
	COMMENT:"TIME \: $NOW_HOUR\:$NOW_MIN\:$NOW_SEC"

rrdtool graph /home/eugene/temp_cpu1.png \
	--start $START --end $DATE  --vertical-label C \
	-e now \
	-s 'end - 3 hours' \
	-S 1 \
	--title "Atom server cpu load (3h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 0 \
	--upper-limit 100 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:cpuusage=/home/eugene/db/tmp.rrd:cpuusage:AVERAGE LINE2:cpuusage#FF0000:CPU \
	COMMENT:"TIME \: $NOW_HOUR\:$NOW_MIN\:$NOW_SEC"
	
	#GPRINT:mb:MIN:'MIN\:%2.lf' \
	#GPRINT:mb:MAX:'MAX\:%2.lf' \
	#GPRINT:mb:AVERAGE:'AVG\:%4.1lf' \
	#GPRINT:mb:LAST:'NOW\:%2.lf \n' \
rrdtool graph /home/eugene/year.png \
	--start $START --end $DATE --vertical-label C \
	-e now \
	-s 'end - 365 days' \
	-S 1 \
	--title "Atom server system temperature (year)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 20 \
	--upper-limit 80 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:mb=/home/eugene/db/tmp.rrd:mb:AVERAGE LINE2:mb#0000FF:motherboard \
	DEF:core0=/home/eugene/db/tmp.rrd:core0:AVERAGE LINE2:core0#FFA600:core0 \
	DEF:core1=/home/eugene/db/tmp.rrd:core1:AVERAGE LINE2:core1#FF6A00:core1 \
	DEF:sda=/home/eugene/db/tmp.rrd:sda:AVERAGE LINE2:sda#00C8FF:sda \
	DEF:sdb=/home/eugene/db/tmp.rrd:sdb:AVERAGE LINE2:sdb#00FFA6:sdb \
	COMMENT:"TIME \: $NOW_HOUR\:$NOW_MIN\:$NOW_SEC"

mv /home/eugene/temp.png /var/www/rrd_graph/
mv /home/eugene/temp1.png /var/www/rrd_graph/
mv /home/eugene/temp_cpu.png /var/www/rrd_graph/
mv /home/eugene/temp_cpu1.png /var/www/rrd_graph/
mv /home/eugene/year.png /var/www/rrd_graph/
