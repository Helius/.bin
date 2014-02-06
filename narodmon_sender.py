#! /usr/bin/python
import glob
import sys
import getopt
import os
import socket
import fnmatch

def listdirs(folder):
	return [d for d in os.listdir(folder) if os.path.isdir(os.path.join(folder, d))]

def delete_values(folder):
	print "delete values:"
	path_f = []
	for d, dirs, files in os.walk(folder):
		for f in fnmatch.filter(files, 'value'):
			path = os.path.join(d,f)
			print "delete " + path
			os.remove(path)
							 

	

narodmon_fs = sys.argv[1]
print "data dir:" + narodmon_fs


server_string=""

devices = listdirs(narodmon_fs)

for i in range(len(devices)):
	d_string=""
	try:
		f = open(narodmon_fs +"/" + devices[i] + "/mac","r")
		dev_mac = f.readline().rstrip();
		d_string = dev_mac
		print "device " + devices[i] + " mac: " + dev_mac
	except Exception, e:
		print "devices " + devices[i] + ": %s" % e
		continue

	s_string=""
	sensors = listdirs(narodmon_fs + "/" + devices[i])
	print "sensors [" + narodmon_fs + "/" + devices[i] + "] :", sensors
	for j in range (len(sensors)):
		try:
			#print "try open: " + narodmon_fs + "/" + devices[i] +"/" + sensors[j] + "/mac"
			fmac = open(narodmon_fs + "/" + devices[i] +"/" + sensors[j] + "/mac","r")
			s_mac=fmac.readline().rstrip()
			v = open(narodmon_fs + "/" + devices[i] +"/" + sensors[j] + "/value","r")
			s_value=v.readline().rstrip()
			s_string+="#"+s_mac+"#"+s_value+"\n"
			print "\tsensor [",j,"]", sensors[j], "mac: " + s_mac + " value: " + s_value
		except Exception, e:
			print "sensor "+ sensors[j] +": %s" % e
			continue
	if len(s_string) != 0:
		server_string += "#" + d_string + "\n" + s_string
if len(server_string) != 0:
	server_string += "##"

print "\nrequest: \n" + server_string
sock = socket.socket()
try:
	sock.connect(('narodmon.ru', 8283))
	sock.send(server_string);
	data = sock.recv(1024)
	sock.close()
	print data
	delete_values(narodmon_fs)
except socket.error, e:
	    print('ERROR! ExcePtion {}'.format(e))

