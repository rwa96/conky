-- params for circular cpu bars
params = {
    -- center center {x,y}
    pos={200,200},
    -- width and height
    size=400,
    -- hex color
    color="#FFF",
    -- hex color of the loading bars
    bar_color="#FFF",
    -- font family
    font="mono",
    -- angle [0..360] of the top left cut out corner
    angle=110,
    -- text displayed in center
    title="CPU",
    -- font size of small text
    font_size_small=12,
    -- font size of large text
    font_size_large=16,
    -- Number of cores
    nproc=12
}

function conky_main ()
    if conky_window == nil then
        return
    end

    local text_h = params.font_size_small / 2
    local x_center = params.pos[1]
    local y_center = params.pos[2]
    local min_r = params.size / 6
    local n_rings = params.nproc
    local bar_w = 9 * (params.size/2 - min_r) / (n_rings*10+3)
    local pad = math.max(bar_w/2, text_h)
    local max_r = (params.size/2 - pad)
    local offset = (max_r - min_r) / (n_rings - 1)
    local text_w = params.size/2 - pad
    local fill_rgb = {Utils.hex2rgb(params.color)}
    local bar_rgb = {Utils.hex2rgb(params.bar_color)}
    local bar_angle = 360-params.angle

    local drv = {}
    for i = 1,params.nproc do
        local workload = tonumber(conky_parse("${cpu cpu".. i .."}")) / 100
        local current_radius = min_r + (i-1) * offset
        -- background of loading bar
        table.insert(drv, Arc:new{
            pos={x_center, y_center},
            radius=current_radius,
            line_cap=CAIRO_LINE_CAP_ROUND,
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], .1)},
            segment = {dir="clock", workload*bar_angle, bar_angle},
            line_width = bar_w,
            close_path = false,
        })
        -- loading bar
        table.insert(drv, Arc:new{
            pos={x_center, y_center},
            radius=current_radius,
            line_cap=CAIRO_LINE_CAP_ROUND,
            color={Utils.create_rgba(bar_rgb[1], bar_rgb[2], bar_rgb[3], 1)},
            segment = {dir="clock", 0, workload*bar_angle},
            line_width = bar_w,
            close_path = false,
        })

        -- loading bar label
        table.insert(drv, Text:new{
            pos={x_center-offset, y_center-current_radius},
            text = string.format("CPU%d %3d%%", i, workload*100),
            color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
            font = params.font,
            font_size = math.min(params.font_size_small, bar_w),
            hoz = "right",
            vert = true,
        })
    end

    -- center (title background)
    table.insert(drv, Arc:new{
        pos={x_center, y_center},
        radius=min_r - 7*bar_w/8,
        fill_type="fill",
        color={Utils.create_radial(
            {0,0}, min_r - 7*bar_w/8, {0,0}, (min_r - 7*bar_w/8)/2,
            {0, fill_rgb[1], fill_rgb[2], fill_rgb[3], .2},
            {1, fill_rgb[1], fill_rgb[2], fill_rgb[3], 0}
        )},
    })

    -- title text
    table.insert(drv, Text:new{
        pos={x_center, y_center},
        text = params.title,
        font = params.font,
        color={Utils.create_rgba(fill_rgb[1], fill_rgb[2], fill_rgb[3], 1)},
        font_size = params.font_size_large,
        hoz = "center",
        vert = true,
    })

    local cnv = Canvas:new(conky_window, drv)
    cnv:display()
    cnv:destroy()
end
