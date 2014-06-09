#!/bin/bash
#set -x
PID_DIR="/home/eugene/.window_climat_control_pid"
PORT=/dev/ttyUSB0
#PI coefficients
P_=20
I_=10
D_=20
#Other saved value
OUT_MAX=100
P_=`cat "$PID_DIR"/climat_PI_P_coeff`
I_=`cat "$PID_DIR"/climat_PI_I_coeff`
D_=`cat "$PID_DIR"/climat_PI_D_coeff`
Intgr=`cat "$PID_DIR"/climat_integrator_saved`
OUT_MAX=`cat "$PID_DIR"/climat_OUT_max`
Tpv=`cat "$PID_DIR"/real_tempr`
Tsp=`cat "$PID_DIR"/climat_T_setpoint`
PrevValue=`cat "$PID_DIR"/climant_last_value`

echo "Real value:$Tpv, P=$P_, I=$I_, D=$D_, OutMax=$OUT_MAX"
Error=$(echo "($Tpv-$Tsp)" | bc -l)
Diff=$(echo "($Tpv-$PrevValue)" | bc -l)
echo "$Tpv" > "$PID_DIR"/climant_last_value

echo "Tsp=$Tsp, Tpv=[31m$Tpv[0m, Err=$Error"

	
Intgr=$(echo "$Intgr+($Error*$I_)" | bc -l)
echo "calc new Intgr: $Intgr"

tmpIntgr=$(echo "$Intgr" | egrep -o '^[-0-9]+')
echo "prepared value: $tmpIntgr"

if (( tmpIntgr > 100 )); then
	Intgr=100
fi
if (( tmpIntgr < 0 )); then
	Intgr=0
fi
		
echo "$Intgr" > "$PID_DIR"/climat_integrator_saved

	
Iout="$Intgr"
Pout=$(echo "$Error*$P_" | bc -l)
Dout=0 #$(echo "$Diff*($D_)" | bc -l)

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

rrdtool graph /var/www/rrd_graph/climat_t.png \
	--vertical-label C \
	-e now \
	-s 'end - 24 hours' \
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
	-s 'end - 24 hours' \
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
	-s 'end - 96 hours' \
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
	-s 'end - 96 hours' \
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




