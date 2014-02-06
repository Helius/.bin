#!/bin/bash

START=`date +"%s"`

rrdtool create climatc.rrd \
  --start $START \
  --step 300 \
  DS:tempr:GAUGE:700:1000:3500 \
  DS:sp:GAUGE:700:1000:3500 \
  DS:hole:GAUGE:700:0:100 \
  DS:p:GAUGE:700:0:100 \
  DS:i:GAUGE:700:0:100 \
  DS:d:GAUGE:700:0:100 \
	RRA:AVERAGE:0.5:1:400 \
	RRA:AVERAGE:0.5:10:900 \
	RRA:AVERAGE:0.5:6:1000 
