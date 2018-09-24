local Text = require 'scripts/drawables/text'
local Arc = require "scripts/drawables/arc"
local Utils = require 'scripts/utils'


-- @param pos table (center center {x,y})
-- @param size number (width and height)
-- @param color string (hex color)
-- @param font string (font family)
-- @param font_size_small number (font size of small text)
-- @param font_size_large number (font size of large text)
-- @param second_width number (line width of seconds circle)
-- @param minute_width number (line width of minutes circle)
-- @param hour_width number (line width of hours circle)
-- @param margin number (distance between circles)
-- @returns ... (drawable objects)
return function (params)
    local pad = params.second_width/2
    local second_r = params.size/2 - pad
    local minute_r = second_r - pad - params.minute_width/2 - params.margin
    local hour_r = minute_r - params.minute_width/2 -params.margin - params.hour_width/2
    local center_r = hour_r - params.hour_width/2 - params.margin
    local current_time = os.date("*t")
    local fill_rgb = {Utils.hex2rgb(params.color)}

    -- seconds circle
    return Arc:new{
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
end
