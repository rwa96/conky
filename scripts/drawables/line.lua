require 'cairo'
local Drawable = require 'scripts/drawables/drawable'


-- Line between to specified points
return Drawable{
    -- Width of the line
    line_width = 1,
    -- Style of outline endings
    -- @see https://www.cairographics.org/samples/set_line_cap/
    line_cap = CAIRO_LINE_CAP_BUTT,
    -- End position of the line
    end_pos = {0, 0},

    draw = function (self, cr)
        cairo_set_line_width(cr, self.line_width)
        cairo_set_line_cap(cr, self.line_cap)
        cairo_move_to(cr,self.pos[1],self.pos[2])
        cairo_line_to(cr,self.pos[1]+self.end_pos[1],self.pos[2]+self.end_pos[2])
        self:set_color(cr, self.color[1])
        cairo_stroke(cr)
    end
}
