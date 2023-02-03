#!/bin/bash
xinit firefox $* -- :0 vt$XDG_VTNR -height 1080 -width 1920 localhost:9090
