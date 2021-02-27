#!/bin/sh
service antmedia start && bash
tail -fn100 /usr/local/antmedia/log/ant-media-server.log