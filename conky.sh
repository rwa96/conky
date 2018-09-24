#!/usr/bin/env bash

conky -c ~/.conky/conkyrc_clock.lua --pause 5
conky -c ~/.conky/conkyrc_calendar.lua
conky -c ~/.conky/conkyrc_cpu.lua
conky -c ~/.conky/conkyrc_mem.lua
