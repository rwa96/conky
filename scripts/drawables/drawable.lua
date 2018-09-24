require 'cairo'
local Utils = require "scripts/utils"


-- Interface every drawable object should implement
return Utils.class{

    -- List of color objects (second color object is outline if fill_type is "both")
    -- @note check utils for more info on color objects (rgba, linear and radial)
    color = {Utils.create_rgba(1, 1, 1, 1)},

    -- Position of the drawable object (exact meaning is implementation specific)
    -- @note usually (top, left) or (center, center)
    pos = {0, 0},

    -- Specifies how to paint the object
    -- @note This property is ignored for drawables without outlines
    --   "stroke" := only draw outline (one color object needed)
    --   "fill" := only fill the shape (one color object needed)
    --   "both" := draw outline and fill shape (two color objects needed)
    fill_type = "stroke",

    -- Create new drawable instance
    --
    -- @param params table (members to override)
    -- @returns table
    new = function (self, params)
        local obj = {}
        for k, v in pairs(params) do
            if self[k] ~= nil then
                obj[k] = v
            else
                print("error: parameter <" .. k .. "> is not valid")
            end
        end
        setmetatable(obj, {__index=self})
        return obj
    end,

    -- Set cairo color as specified the color object
    --
    -- @param cr userdata (cairo instance)
    -- @param cl table (color object)
    set_color = function (self, cr, cl)
        local x = self.pos[1]
        local y = self.pos[2]

        if cl.t == "rgba" then
            cairo_set_source_rgba(cr, cl[1], cl[2], cl[3], cl[4])
        elseif cl.t == "linear" then
            local pat = cairo_pattern_create_linear(
                x+cl.s[1], y+cl.s[2],
                x+cl.e[1], y+cl.e[2])
            for i, step in ipairs(cl) do
                cairo_pattern_add_color_stop_rgba(pat, step[1], step[2], step[3], step[4], step[5])
            end
            cairo_set_source(cr, pat)
            cairo_pattern_destroy(pat)
        elseif cl.t == "radial" then
            local pat = cairo_pattern_create_radial(
                x+cl.c1[1], y+cl.c1[2], cl.r1,
                x+cl.c2[1], y+cl.c2[2], cl.r2)
            for i, step in ipairs(cl) do
                cairo_pattern_add_color_stop_rgba(pat, step[1], step[2], step[3], step[4], step[5])
            end
            cairo_set_source(cr, pat)
            cairo_pattern_destroy(pat)
        else
            print("error: unknown color type: " .. cl.t)
        end
    end,

    -- Paint the drawable object with specified colors
    --
    -- @param cr userdata (cairo instance)
    paint = function (self, cr)
        self:set_color(cr, self.color[1])
        if self.fill_type == "both" then
            cairo_fill_preserve(cr)
            if self.color[2] then
                self:set_color(cr, self.color[2])
                cairo_stroke(cr)
            else
                print("error: no second color specified")
            end
        elseif self.fill_type == "fill" then
            cairo_fill(cr)
        elseif self.fill_type == "stroke" then
            cairo_stroke(cr)
        else
            print("error: unknown fill_type: " .. self.fill_type)
        end
    end,

    -- Display the drawable object on canvas
    -- @note Should only be called by a canvas object internally
    --
    -- @param cr userdata (cairo instance)
    draw = function (self, cr)
        print("error: drawable has no implementation of method 'draw(...)'")
    end
}
