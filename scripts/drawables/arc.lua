require 'cairo'
local Drawable = require 'scripts/drawables/drawable'


-- Circle that can be drawn completely or partly (hence arc)
return Drawable{
    -- Circle radius
    radius = 0,
    -- segment of circle:
    --   segment.dir (direction: "clock" or "anticlock")
    --   segment[1] (starting angle [0..360] starting from top center)
    --   segment[2] (end angle [0..360] starting form to center)
    segment = {dir="clock", 0, 360},
    -- Width of circle outline
    line_width = 1,
    -- Style of outline endings (if drawn partly and not closed)
    -- @see https://www.cairographics.org/samples/set_line_cap/
    line_cap = CAIRO_LINE_CAP_BUTT,
    -- Style of line joins (if drawn partly and closed)
    line_join = CAIRO_LINE_JOIN_MITER,
    -- Outline is joined to a closed shape
    close_path = true,

    draw = function (self, cr)
        local deg2rad = math.pi/180
        local c_start = (self.segment[1]-90)*deg2rad
        local c_end = (self.segment[2]-90)*deg2rad
        cairo_set_line_width(cr, self.line_width)
        cairo_set_line_cap(cr, self.line_cap)

        if self.segment.dir == "clock" then
            cairo_arc(cr, self.pos[1], self.pos[2], self.radius, c_start, c_end)
        elseif self.segment.dir == "anticlock" then
            cairo_arc_negative(cr, self.pos[1], self.pos[2], self.radius, c_start, c_end)
        else
            print("error: unknown circle segment type: " .. self.segment.dir)
        end

        cairo_set_line_join(cr, self.line_join)
        if self.fill_type == "fill" or self.fill_type == "preserve" or self.close_path then
            cairo_close_path(cr)
        end

        self:paint(cr)
    end
}
