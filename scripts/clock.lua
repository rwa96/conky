-- params for clock displaying the current time
params = {
    -- center center {x,y}
    pos={125,125},
    -- width and height
    size=250,
    -- hex color
    color="#FFF",
    -- font family
    font="mono",
    -- font size of small text
    font_size_large=18,
    -- font size of large text
    font_size_small=12,
    -- line width of seconds circle
    second_width=5,
    -- line width of minutes circle
    minute_width=20,
    -- line width of hours circle
    hour_width=10,
    -- distance between circles
    margin=5
}

function conky_main()
    if conky_window == nil then
        return
    end

    local pad = params.second_width/2
    local second_r = params.size/2 - pad
    local minute_r = second_r - pad - params.minute_width/2 - params.margin
    local hour_r = minute_r - params.minute_width/2 -params.margin - params.hour_width/2
    local center_r = hour_r - params.hour_width/2 - params.margin
    local current_time = os.date("*t")
    local fill_rgb = {Utils.hex2rgb(params.color)}

    local cnv = Canvas:new(conky_window, {
        -- seconds circle
        Arc:new{
            pos=params.pos,
            line_width=params.second_width,
            radius=second_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            segment={dir="clock", 0, 360 * (current_time.sec/59)},
            close_path=false
        },
        Arc:new{
            pos=params.pos,
            line_width=params.second_width,
            radius=second_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], .2)}
        },

        -- minutes circle
        Arc:new{
            pos=params.pos,
            line_width=params.minute_width,
            radius=minute_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            segment={dir="clock", 0, 360 * (current_time.min/59)},
            close_path=false
        },
        Arc:new{
            pos=params.pos,
            line_width=params.minute_width,
            radius=minute_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], .2)},
        },

        -- hours circle
        Arc:new{
            pos=params.pos,
            line_width=params.hour_width,
            radius=hour_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            segment={dir="clock", 0, 360 * (current_time.hour/23)},
            close_path=false
        },
        Arc:new{
            pos=params.pos,
            line_width=params.hour_width,
            radius=hour_r,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], .2)},
        },

        -- inner gradient background
        Arc:new{
            pos=params.pos,
            radius=center_r,
            fill_type="fill",
            color={Utils.create_radial(
                {0,0}, .75*center_r, {0,0}, center_r,
                {0, fill_rgb[1], fill_rgb[2], fill_rgb[3], 0},
                {1, fill_rgb[1], fill_rgb[2], fill_rgb[3], .2}
            )},
        },

        -- HH:MM:SS
        Text:new{
            pos=params.pos,
            text = os.date("%X"),
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            font = params.font,
            font_size = params.font_size_large,
            hoz = "center",
            vert = false,
        },

        -- uptime
        Text:new{
            pos={params.pos[1], params.pos[2]+params.font_size_large/2+params.font_size_small/2+params.margin},
            text = conky_parse("$uptime"),
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            font = params.font,
            font_size = params.font_size_small,
            hoz = "center",
            vert = false,
        }
    })

    cnv:display()
    cnv:destroy()
end
