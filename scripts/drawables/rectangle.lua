require 'cairo'
local Drawable = require 'scripts/drawables/drawable'


-- Rectable with specified width and height
return Drawable{
    -- Width (x direction)
    width = 0,
    -- Height (y direction)
    height = 0,
    -- Width of outline
    line_width = 1,
    -- Style of line joins
    line_join = CAIRO_LINE_JOIN_MITER,

    draw = function (self, cr)
        cairo_set_line_width(cr, self.line_width)
        cairo_rectangle(cr, self.pos[1], self.pos[2], self.width, self.height)
        cairo_set_line_join(cr, self.line_join)
        self:paint(cr)
    end
}
