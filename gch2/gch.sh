#!/bin/bash
xinit /usr/bin/firefox -height 1080 -width 1920 localhost:9090 $* -- :0 vt$XDG_VTNR
