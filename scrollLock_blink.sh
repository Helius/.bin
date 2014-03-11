#!/bin/bash
trap 'xset -led named "Scroll Lock"; exit ' SIGINT

while(true); do
    xset led named "Scroll Lock" ; 
    sleep 0.25 ; 
    xset -led named "Scroll Lock"; 
    sleep 1; 
done
