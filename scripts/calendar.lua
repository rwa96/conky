-- params for alendar showing the current month
params = {
    -- top left {x,y}
    pos={0,0},
    -- width and height
    size=250,
    -- hex color
    color="#FFF",
    -- font family
    font="mono",
    -- font size of small text
    font_size_small=12,
    -- font size of large text
    font_size_large=18
}

function conky_main()
    if conky_window == nil then
        return
    end

    local title_h = 3*params.font_size_large/2
    local size = params.size-4
    local text_h = params.font_size_small
    local header_h = title_h + 2*text_h
    local body_h = size - header_h
    local day_size = 3*body_h / 24
    local v_offset = 1*body_h / 24
    local h_offset = (size - 7*day_size) / 6
    local y_start = params.pos[2] + header_h + v_offset + day_size/2
    local x_start = params.pos[1] + day_size/2 + 4
    local rgb = {Utils.hex2rgb(params.color)}

    local week_days = {"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"}
    local today = os.date("*t")
    local z_first_week_day = tonumber(os.date("%w", os.time{day=0,month=today.month,year=today.year}))
    local z_last_month_day = tonumber(os.date("%d", os.time{day=-1,month=today.month+1,year=today.year}))

    local drv = {}

    -- Gradient background of title
    table.insert(drv, Rectangle:new{
        pos={params.pos[1]+4, params.pos[2]},
        width=size,
        height=title_h,
        fill_type="fill",
        color={Utils.create_linear(
            {0,0}, {size,0},
            {0, rgb[1], rgb[2], rgb[3], 0},
            {.5, rgb[1], rgb[2], rgb[3], .2},
            {1, rgb[1], rgb[2], rgb[3], 0}
        )}
    })

    -- Position of top horizontal line (title)
    table.insert(drv, Line:new{
        pos={params.pos[1]+4, params.pos[2]+1},
        end_pos={size,0},
        color={Utils.create_linear(
            {0,0}, {size,0},
            {0, rgb[1], rgb[2], rgb[3], 0},
            {.25, rgb[1], rgb[2], rgb[3], 1},
            {.75, rgb[1], rgb[2], rgb[3], 1},
            {1, rgb[1], rgb[2], rgb[3], 0}
        )}
    })

    -- Position of bottom horizontal line (title)
    table.insert(drv, Line:new{
        pos={params.pos[1]+4, params.pos[2]+title_h},
        end_pos={size,0},
        color={Utils.create_linear(
            {0,0}, {size,0},
            {0, rgb[1], rgb[2], rgb[3], 0},
            {.25, rgb[1], rgb[2], rgb[3], 1},
            {.75, rgb[1], rgb[2], rgb[3], 1},
            {1, rgb[1], rgb[2], rgb[3], 0}
        )}
    })

    -- Title text <Month> <Year>
    table.insert(drv, Text:new{
        pos={params.pos[1]+4+size/2, params.pos[2]+title_h/2},
        text = os.date("%B %Y"),
        color={Utils.create_rgba(rgb[1], rgb[2], rgb[3], 1)},
        font = params.font,
        font_size = params.font_size_large,
        hoz = "center",
        vert = true,
    })

    -- Dividing line
    table.insert(drv, Line:new{
        pos={params.pos[1]+4, params.pos[2]+header_h},
        end_pos={size,0},
        color={Utils.create_linear(
            {0,0}, {size,0},
            {0, rgb[1], rgb[2], rgb[3], 0},
            {.25, rgb[1], rgb[2], rgb[3], 1},
            {.75, rgb[1], rgb[2], rgb[3], 1},
            {1, rgb[1], rgb[2], rgb[3], 0}
        )}
    })

    -- Week day abreviations
    for i, v in ipairs(week_days) do
        local start_p = (i-1) * (day_size + h_offset)
        table.insert(drv, Text:new{
            pos={params.pos[1]+start_p+day_size/2+4, params.pos[2]+header_h-text_h},
            text = week_days[i],
            color={Utils.create_rgba(rgb[1], rgb[2], rgb[3], 1)},
            font = params.font,
            font_size = params.font_size_small,
            hoz = "center",
            vert = true,
        })
    end

    -- Actual days Circle and Text
    for z_m_d = 0,z_last_month_day do
        local width = 1
        local m_color = {Utils.create_rgba(rgb[1], rgb[2], rgb[3], 1)}
        local m_fill_type = "stroke"
        local ind = z_m_d + z_first_week_day
        local z_x_ind = ind % 7
        local z_y_ind = math.floor(ind / 7)
        local x_pos = x_start + z_x_ind*(day_size+h_offset) +4
        local y_pos = y_start + z_y_ind*(day_size+v_offset) +4

        if z_m_d == today.day-1 then width = 4 end
        if z_x_ind == 6 then
            m_fill_type = "both"
            m_color = {
                Utils.create_rgba(rgb[1], rgb[2], rgb[3], .2),
                Utils.create_rgba(rgb[1], rgb[2], rgb[3], 1)
            }
        end

        table.insert(drv, Arc:new{
            pos={x_pos, y_pos},
            radius=day_size/2,
            fill_type=m_fill_type,
            line_width=width,
            color=m_color,
        })

        table.insert(drv, Text:new{
            pos={x_pos, y_pos},
            text = tostring(z_m_d+1),
            color={Utils.create_rgba(rgb[1], rgb[2], rgb[3], 1)},
            font = params.font,
            font_size = params.font_size_small,
            hoz = "center",
            vert = true,
        })
    end

    local cnv = Canvas:new(conky_window, drv)
    cnv:display()
    cnv:destroy()
end
