#!/usr/bin/python

import serial
import subprocess
import json
import time
import calendar
from subprocess import call

# STUFF: FRITE STRING TO THE FILE like 'echo "some" > file'

def echo_file (name, line):
	f = open(name,'w+')
	f.write(str(line)) # python will convert \n to os.linesep
	f.close() # you can omit in most cases as the destructor will call if


# DHT22 handler

def dht22_handler(Uid, value):
	Humidity = (value[0]*255 + value[1])*0.1
	if (value[2]&0x80):
		Temperature = (value[2]&0x7F)*255 + value[3]
	else:
		Temperature = (value[2]*255 + value[3])*0.1
	print "Climat is ", Temperature, "C, ", Humidity, "%"
	# save to DB
	call(["rrdtool", "update", "/home/eugene/db/climat.rrd", str(calendar.timegm(time.gmtime())) + ":" + str(Temperature) + ":U:" + str(Humidity) + ":U" ])
	# send to narodmon.ru
	echo_file('/home/eugene/.narodmon.data/atom/indoor_humidity/value', Humidity)
	echo_file('/home/eugene/.narodmon.data/atom/indoor_tempr/value',Temperature)
	# update pid value
	echo_file('/home/eugene/.window_climat_control_pid/real_tempr',Temperature)


# PARSE MESSAGE from devices

def parse_message (line):
	print "\n\n"
	print(line)
	data=json.loads(line)
	for key, value in data.items():
	#	print ">", key, value
		if (key == "type"):
	#		print "type matched: ", value
			Type = value
		elif (key == "uid"):
			Uid = value
	#		print "it's climan sensor: ", value
		if (key == "data"):
			Data = value
	#		print "data: ", value 
	print "parce message from ", Type, ", uid ", Uid, ", data: ", Data
	
	if (Type == 1):                 # DHT22 devices
		dht22_handler(Uid, Data)
	else:                           # Unknown sensor
		print "Unknown sensor type"
		


# READ MESSAGES FROM THE PORT

ser = serial.Serial('/dev/ttyACM0', 38400, timeout=1)
print("connected to: " + ser.portstr)
while True:
	# Read a line and convert it from b'xxx\r\n' to xxx
	line = ser.readline()
	if line:  # If it isn't a blank line
		parse_message(line)
ser.close()



