local Text = require 'scripts/drawables/text'
local Line = require 'scripts/drawables/line'
local Polygon = require 'scripts/drawables/polygon'
local Utils = require 'scripts/utils'

-- Creates a zylinder filled by a specified percentage
--
-- @param pos table (top left {x,y})
-- @param width number
-- @þaram height number
-- @param percentage number (percentage between 0 and 1)
-- @param color string (hex color of outline)
-- @param fill_color string (hex color of inner volume)
-- @param font_size number
-- @param title string (displayed above graph)
-- @param font string (font family)
-- @returns ... (drawable objects)
return function (params)
    local text_h = params.font_size / 2
    local text_w = params.font_size * 3
    local box_w = params.width - 2 - text_h - text_w
    local elipse_w = box_w / 2 - 2
    local elipse_h = elipse_w / 4
    local y_top = params.pos[2] + 3*text_h + elipse_h
    local y_bot = params.pos[2] + params.height - 2 - elipse_h
    local y_mid = y_top + ((y_bot - y_top) * (1 - params.percentage))
    local bar_h = y_bot - y_mid
    local x_center = 2 + elipse_w + params.pos[1]
    local x_left = params.pos[1] + 2
    local bezier_w = 4 * elipse_w / 3
    local tmp = {Utils.hex2rgb(params.color)}
    local frame_rgba = Utils.create_rgba(tmp[1],tmp[2],tmp[3],1)
    tmp = nil
    local fill_rgb = {Utils.hex2rgb(params.fill_color)}

    -- bottom elipse
    return Polygon:new{
        pos={x_center, y_bot-elipse_h},
        line_width=2,
        color={frame_rgba},
        components={
            {t="multicurve",
            {bezier_w,0,bezier_w,2*elipse_h,0,2*elipse_h},
            {-bezier_w,2*elipse_h,-bezier_w,0,0,0}}
        }
    },

    -- fill color/shape
    Polygon:new{
        pos={x_center, y_mid-elipse_h},
        color={Utils.create_linear(
            {elipse_w,0}, {elipse_w, bar_h+2*elipse_h},
            {0,fill_rgb[1],fill_rgb[2],fill_rgb[3],.8},
            {1,fill_rgb[1],fill_rgb[2],fill_rgb[3],.1}
        )},
        fill_type="fill",
        components={
            {t="multicurve",
                {bezier_w,0,bezier_w,2*elipse_h,0,2*elipse_h},
                {-bezier_w,2*elipse_h,-bezier_w,0,0,0}},
            {t="multiline", {elipse_w,elipse_h}, {elipse_w,bar_h+elipse_h},{0,bar_h}},
            {t="multicurve",
                {bezier_w,bar_h,bezier_w,bar_h+2*elipse_h,0,bar_h+2*elipse_h},
                {-bezier_w,bar_h+2*elipse_h,-bezier_w,bar_h,0,bar_h}},
            {t="multiline", {-elipse_w,bar_h+elipse_h},{-elipse_w,elipse_h}}
        }
    },


    -- left vertical line
    Line:new{
        pos={x_left, y_top},
        line_cap=CAIRO_LINE_CAP_ROUND,
        end_pos={0, y_bot-y_top},
        line_width=2,
        color={frame_rgba},
    },

    -- right vertical line
    Line:new{
        pos={x_center+elipse_w, y_top},
        line_cap=CAIRO_LINE_CAP_ROUND,
        end_pos={0, y_bot-y_top},
        line_width=2,
        color={frame_rgba},
    },

    -- middle elipse
    Polygon:new{
        pos={x_center, y_mid-elipse_h},
        line_width=2,
        color={frame_rgba},
        components={
            {t="multicurve",
            {bezier_w,0,bezier_w,2*elipse_h,0,2*elipse_h},
            {-bezier_w,2*elipse_h,-bezier_w,0,0,0}}
        }
    },

    -- top elipse
    Polygon:new{
        pos={x_center, y_top-elipse_h},
        line_width=2,
        color={frame_rgba},
        components={
            {t="multicurve",
            {bezier_w,0,bezier_w,2*elipse_h,0,2*elipse_h},
            {-bezier_w,2*elipse_h,-bezier_w,0,0,0}}
        }
    },

    -- percentage position indicator
    Polygon:new{
        pos={params.pos[1]+box_w+2+text_h, y_mid-text_h},
        line_width=2,
        color={frame_rgba},
        components={{t="multiline", {-text_h,text_h}, {0,2*text_h}}},
        close_path=false
    },

    -- percentage
    Text:new{
        pos={params.pos[1]+box_w+4+text_h, y_mid},
        text = string.format("%3d%%", params.percentage * 100),
        font = params.font,
        color = {frame_rgba},
        font_size = params.font_size,
        hoz = "left",
        vert = true,
    },

    -- title
    Text:new{
        pos={x_center, 2*text_h},
        text = params.title,
        font = params.font,
        color = {frame_rgba},
        font_size = params.font_size,
        hoz = "center",
        vert = false,
    }
end
