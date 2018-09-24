require 'cairo'
local Drawable = require 'scripts/drawables/drawable'


-- Text displayed on canvas
return Drawable{

    -- String to display
    text = "",
    -- Text font
    font = "mono",
    -- Font size in pt
    font_size = 12,
    -- Horizontal alignment ("left", "right" or "center")
    hoz = "left",
    -- Vertical centering (if false, use bottom)
    vert = false,
    font_slant = CAIRO_FONT_SLANT_NORMAL,
    font_face = CAIRO_FONT_WEIGHT_NORMAL,

    draw = function (self, cr)
        cairo_select_font_face(cr, self.font, self.font_slant, self.font_face)
        cairo_set_font_size(cr, self.font_size)

        local dx = 0
        local dy = 0
        if self.vert or self.hoz ~= "left" then
            local te = cairo_text_extents_t:create()
            tolua.takeownership(te)
            cairo_text_extents(cr, self.text, te)

            if self.hoz == "center" then
                dx = -(te.width/2 + te.x_bearing)
            elseif self.hoz == "right" then
                dx = -(te.width + te.x_bearing)
            elseif self.hoz ~= "left" then
                print("error: unknown centering type: " .. self.hoz)
            end

            if self.vert then dy = -(te.height/2 + te.y_bearing) end
        end

        cairo_move_to(cr, self.pos[1]+dx, self.pos[2]+dy)
        self:set_color(cr, self.color[1])
        cairo_show_text(cr, self.text)
        cairo_stroke(cr)
    end
}
