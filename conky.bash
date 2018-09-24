#!/usr/bin/env bash

sleep 5
conky -c ~/.conky/conkyrc_clock.lua --daemonize
conky -c ~/.conky/conkyrc_calendar.lua --daemonize
conky -c ~/.conky/conkyrc_cpu.lua --daemonize
conky -c ~/.conky/conkyrc_mem.lua --daemonize
sleep 1
