require 'cairo'


-- Representation of a canvas containing drawable
-- objects and displayable on screen
Canvas = {

    -- Create new canvas instance
    --
    -- @param w table (conky_window)
    -- @param drawables table (drawable objects)
    -- @returns table
    new = function (self, w, drawables)
        local obj = {}
        setmetatable(obj, {__index=self})

        obj.cs = cairo_xlib_surface_create(w.display,w.drawable,w.visual,w.width,w.height)
        obj.cr = cairo_create(obj.cs)
        if drawables then obj.drawables = drawables end

        return obj
    end,

    -- Add new drawable objects to canvas
    -- @note variable number of objects
    --
    -- @params ... (drawables)
    add = function (self, ...)
        if not self.drawables then
            self.drawables = {}
        end
        for i, v in ipairs({...}) do
            if v.draw then
                table.insert(self.drawables, v)
            else
                print("error: object not of type drawable")
            end
        end
    end,

    -- Display canvas on screen
    display = function (self)
        if self.drawables then
            for i, v in ipairs(self.drawables) do
                v:draw(self.cr)
            end
        end
    end,

    -- Destroy underlying cairo structure
    -- @note Should always be called at program end
    destroy = function (self)
        cairo_destroy(self.cr)
        cairo_surface_destroy(self.cs)
    end
}

-- Interface every drawable object should implement
Drawable = Utils.class{

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

-- Line between to specified points
Line = Drawable{
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

-- A polygon consisting of lines and bezier curves
-- @note every specified line and curve uses relative coordinates to pos
Polygon = Drawable{

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

-- Circle that can be drawn completely or partly (hence arc)
Arc = Drawable{
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

-- Rectangle with specified width and height
Rectangle = Drawable{
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

-- Text displayed on canvas
Text = Drawable{

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
