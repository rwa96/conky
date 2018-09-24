local Canvas = require 'scripts/canvas'
local Zylinder = require 'scripts/complex/zylinder'
local CircleLoad = require 'scripts/complex/circle_load'
local Calendar = require 'scripts/complex/calendar'
local Clock = require 'scripts/complex/clock'


function conky_main ()
    if conky_window == nil then
        return
    else
        local cnv = Canvas:new(conky_window)

        cnv:add(Zylinder{
            pos={0,0},
            width=200,
            height=300,
            percentage=.5,
            color="#FFF",
            fill_color="#36F",
            font_size=12,
            title="Disk",
            font="mono"
        })

        cnv:add(CircleLoad{
            pos={350,150},
            size=300,
            progress={
                {"CPU0", 0},
                {"CPU1", .1},
                {"CPU2", .2},
                {"CPU3", .3},
                {"CPU4", .4},
                {"CPU5", .5}
            },
            color="#FFF",
            bar_color="#36F",
            font="mono",
            angle=110,
            title="CPU",
            font_size_small=12,
            font_size_large=16
        })

        cnv:add(Calendar{
            pos={500,0},
            size=250,
            color="#FFF",
            font="mono",
            font_size_small=12,
            font_size_large=18
        })

        cnv:add(Clock{
            pos={900,125},
            size=250,
            color="#FFF",
            font="mono",
            font_size_large=18,
            font_size_small=12,
            second_width=5,
            minute_width=20,
            hour_width=10,
            margin=5
        })

        cnv:display()
        cnv:destroy()
    end
end
