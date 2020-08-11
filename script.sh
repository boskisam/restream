#!/bin/bash
envsubst < /etc/nginx/nginx.conf.temp > /etc/nginx/nginx.conf
nginx -g 'daemon off;'