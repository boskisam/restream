#!/bin/bash
envsubst < /etc/nginx/nginx.conf.temp > /etc/nginx/nginx.conf
service stunnel4 stop 
service stunnel4 start 
nginx -g 'daemon off;'
