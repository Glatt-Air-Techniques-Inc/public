#!/bin/bash
if [ "$DISPLAY" ] || [ "$WAYLAND_DISPLAY" ] || [ "$MIR_SOCKET" ]; then
    firefox -height 1080 -width 1920 localhost:9090
else
	startx "$0" "$@"
    exit $?
fi