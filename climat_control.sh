#!/bin/bash
#set -x

Tsp=25

#PI coefficients
P_=20
I_=10
D_=20
OUT_MAX=100
P_=`cat /home/eugene/.climat_PI_P_coeff`
I_=`cat /home/eugene/.climat_PI_I_coeff`
D_=`cat /home/eugene/.climat_PI_D_coeff`
Intgr=`cat /home/eugene/.climat_integrator_saved`
OUT_MAX=`cat /home/eugene/.climat_OUT_max`
PrevValue=`cat /home/eugene/.climat_T_setpoint`
ITERATES=12 # number of received temperature points (about 5 minuts)
#ITERATES=1 # number of received temperature points (about 5 minuts)

echo "P=$P_, I=$I_, D=$D_, OutMax=$OUT_MAX"
CNT=0
PORT=/dev/ttyUSB0
Tpv_filter_summ=0
miniterm.py --lf -qp  /dev/ttyUSB0 -b 19200 | while read Tpv_raw; do
	Tpv_raw=$(echo $Tpv_raw | egrep -o '[0-9.]+') #avoid bad symbols
	echo "received: [$Tpv_raw]"
	Tpv_filter_summ=$(echo "$Tpv_filter_summ + $Tpv_raw" | bc -l)
	if (( CNT < $ITERATES )); then
		let CNT++
		continue
	fi
	Tpv=$(echo "$Tpv_filter_summ/($ITERATES+1)" | bc -l)
	CNT=0
	Tpv_filter_summ=0;
	echo "filter: $Tpv"
	Tsp=`cat /home/eugene/.climat_T_setpoint`

	Error=$(echo "($Tpv-$Tsp)" | bc -l)
	Diff=$(echo "($Tpv-$PrevValue)" | bc -l)
	PrevValue=$Tpv

#trancate old integrator history
#	echo "$Error" >> /home/eugene/.climat_integrator_saved
#	echo -e "$(tac .climat_integrator_saved | head -n$I_ | tac)" > .climat_integrator_saved

	echo "Tsp=$Tsp, Tpv=[31m$Tpv[0m, Err=$Error"

# calc intergation value
#	integrator_cnt=0
#	Intgr=0
#	while read _err 
#	do
	#	echo "error was: $_err"
#		Intgr=$(echo "($Intgr + ($_err))" | bc -l)
#		let integrator_cnt++
#		if ((integrator_cnt > I_ ))
#		then
#			break
#		fi
#	done < /home/eugene/.climat_integrator_saved
#	echo "Integrator value: $Intgr"
	
	Intgr=$(echo "$Intgr+($Error*$I_)" | bc -l)
	echo "calc new Intgr: $Intgr"

	tmpIntgr=$(echo "$Intgr" | egrep -o '^[-0-9]+')
	echo "prepared value: $tmpIntgr"

#	if [ -z "$tmpIntgr" ]; then
#		Intgr=0
#	fi

	if (( tmpIntgr > 100 )); then
		Intgr=100
	fi
	if (( tmpIntgr < 0 )); then
		Intgr=0
	fi
	
	
	echo "$Intgr" > /home/eugene/.climat_integrator_saved

	
	Iout="$Intgr"
	Pout=$(echo "$Error*$P_" | bc -l)
	Dout=0 #$(echo "$Diff*($D_)" | bc -l)
	

	ZeroSing=$(echo $Error | grep -o '[-]')
	OUT_RAW=$(echo "(($Iout)+($Pout)+($Dout))" | bc -l)
	OUT=$(echo "10+(($OUT_RAW)*$OUT_MAX)/100" | bc -l)
	echo "out: $OUT"
	OUT=$(echo "$OUT" | egrep -o '^[-0-9]+')

	if [ "$OUT" == "" ]; then
		OUT=0
	fi
	if [ "$OUT" == "-" ]; then
		OUT=0
	fi

	if (( OUT < 10 )); then
		OUT=10
		
	fi
	if (( OUT > 100 )); then
		OUT=100
	fi

	echo "P=$Pout, I=$Iout, D=$Dout(disable), OUT=$OUT_RAW [real=[32m$OUT[0m, max=$OUT_MAX]"

	echo "$OUT;">$PORT

	TpvFixPoint=$(echo "$Tpv*100" | bc -l | egrep -o '^[0-9]+') 
	TspFixPoint=$(echo "$Tsp*100" | bc -l | egrep -o '^[0-9]+') 
	echo "update db:$TpvFixPoint:$TspFixPoint:$OUT:$Pout:$Iout:$Dout"
	rrdtool update /home/eugene/db/climatc.rrd `date +"%s"`:$TpvFixPoint:$TspFixPoint:$OUT:$Pout:$Iout:$Dout
	echo "send $Tpv to narodmon"
	echo "$Tpv" > /home/eugene/.narodmon.data/atom/indoor_tempr/value

rrdtool graph /var/www/rrd_graph/climat_t.png \
	--vertical-label C \
	-e now \
	-s 'end - 12 hours' \
	-S 90 \
	--title "Room temperature (12h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 2000 \
	--upper-limit 3000 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:tempr=/home/eugene/db/climatc.rrd:tempr:AVERAGE LINE2:tempr#FF0000:Real_value \
	DEF:sp=/home/eugene/db/climatc.rrd:sp:AVERAGE LINE2:sp#0000FF:Set_Point 

rrdtool graph /var/www/rrd_graph/climat_w.png \
	--vertical-label C \
	-e now \
	-s 'end - 12 hours' \
	-S 90 \
	--title "Window gap (12h)" \
	--vertical-label "%" \
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
	DEF:hole=/home/eugene/db/climatc.rrd:hole:AVERAGE LINE2:hole#000000:Out \
	DEF:p=/home/eugene/db/climatc.rrd:p:AVERAGE LINE2:p#FF0000:P \
	DEF:i=/home/eugene/db/climatc.rrd:i:AVERAGE LINE2:i#00FF00:I \
	DEF:d=/home/eugene/db/climatc.rrd:d:AVERAGE LINE2:d#0000FF:D 

rrdtool graph /var/www/rrd_graph/climat_t_48.png \
	--vertical-label C \
	-e now \
	-s 'end - 48 hours' \
	-S 300 \
	--title "Room temperature (48h)" \
	--vertical-label "C" \
	--imgformat PNG \
	--slope-mode   \
	--lower-limit 2000 \
	--upper-limit 3000 \
	--rigid \
	-E \
	-i \
	--color SHADEA#FFFFFF \
	--color SHADEB#FFFFFF \
	--color BACK#CCCCCC \
	-w 800 \
	-h 200 \
	--interlaced \
	DEF:tempr=/home/eugene/db/climatc.rrd:tempr:AVERAGE LINE2:tempr#FF0000:Real_value \
	DEF:sp=/home/eugene/db/climatc.rrd:sp:AVERAGE LINE2:sp#0000FF:Set_Point

rrdtool graph /var/www/rrd_graph/climat_w_48.png \
	--vertical-label C \
	-e now \
	-s 'end - 48 hours' \
	-S 300 \
	--title "Window gap (48h)" \
	--vertical-label "%" \
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
	DEF:hole=/home/eugene/db/climatc.rrd:hole:AVERAGE LINE2:hole#000000:Out \
	DEF:p=/home/eugene/db/climatc.rrd:p:AVERAGE LINE2:p#FF0000:P \
	DEF:i=/home/eugene/db/climatc.rrd:i:AVERAGE LINE2:i#00FF00:I \
	DEF:d=/home/eugene/db/climatc.rrd:d:AVERAGE LINE2:d#0000FF:D 

done



