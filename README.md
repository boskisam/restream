# Restreamer

A nginx rtmp stream duplicator for simultaneous streams to youtube and facebook.

## Usage

To start the container use 

`docker run -d -p 1935:1935 -e RTMP_STREAM=<yourcustomrtmpstream> -e YOUTUBE_KEY=<youryoutubekey> -e FACEBOOK_KEY="<yourfbkey>" boskisam/restreamer`

facebook stream keys needs to be in quotes.

## ENV
You need to set up the environment variables while launching the container. Do that with docker run -e

* YOUTUBE_KEY - Youtube stream key

* FACEBOOK_KEY - Facebook stream key

* RTMP_STREAM - custom rtmp stream, ie. `my.ip:21935/live`

## Ports
Nginx listens on port 1935. For increased security if used online, publish it to random high port. `-p 31231:1935`
