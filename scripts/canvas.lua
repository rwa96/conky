require 'cairo'


-- Representation of a canvas containing drawable
-- objects and displayable on screen
return {

    -- Create new canvas instance
    --
    -- @param w table (conky_window)
    -- @returns table
    new = function (self, w)
        local obj = {}
        setmetatable(obj, {__index=self})

        obj.cs = cairo_xlib_surface_create(w.display,w.drawable,w.visual,w.width,w.height)
        obj.cr = cairo_create(obj.cs)

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
        for i, v in ipairs(arg) do
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
