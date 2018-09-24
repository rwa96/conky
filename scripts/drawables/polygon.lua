require 'cairo'
local Drawable = require 'scripts/drawables/drawable'


-- A polygon consisting of lines and bezier curves
-- @note every specified line and curve uses relative coordinates to pos
return Drawable{
    
    -- Style of outline endings (if not closed)
    -- @see https://www.cairographics.org/samples/set_line_cap/
    line_cap = CAIRO_LINE_CAP_BUTT,
    -- Style of line joins
    line_join = CAIRO_LINE_JOIN_MITER,
    -- Width of outline
    line_width = 1,
    -- Array of multiline (multiple lines joined) and multicurve (multiple curves joined)
    -- objects that are drawn in order
    -- @note x and y coordinates are always relative to pos
    --   {t="multiline", {x,y},{x,y}...}
    --   {t="multicurve", {x1,y1,x2,y2,x3,y3}...}
    components = {},
    -- Outline is joined to a closed shape
    close_path = true,

    draw = function (self, cr)
        local x = self.pos[1]
        local y = self.pos[2]

        cairo_set_line_width(cr, self.line_width)
        cairo_set_line_cap(cr, self.line_cap)
        cairo_move_to(cr, x, y)

        for i, comp in ipairs(self.components) do
            if comp.t == "multiline" then
                for i, v in ipairs(comp) do
                    cairo_line_to(cr, x+v[1], y+v[2])
                end
            elseif comp.t == "multicurve" then
                for i, v in ipairs(comp) do
                    cairo_curve_to(cr, x+v[1], y+v[2], x+v[3], y+v[4], x+v[5], y+v[6])
                end
            else
                print("error: unknown polygon component type: " .. comp.t)
            end
        end

        cairo_set_line_join(cr, self.line_join)
        if self.close_path then cairo_close_path(cr) end
        self:paint(cr)
    end
}
