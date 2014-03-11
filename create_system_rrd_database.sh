#!/bin/bash

START=`date +"%s"`

rrdtool create climat.rrd \
  --start $START \
  --step 60 \
  DS:tempr:GAUGE:120:0:35 \
  DS:tempr_sp:GAUGE:120:0:35 \
  DS:humid:GAUGE:120:0:100 \
  DS:humid_sp:GAUGE:120:0:100 \
	RRA:MAX:0.5:1:1500 \
	RRA:AVERAGE:0.5:10:900 \
	RRA:AVERAGE:0.5:10:1000 
