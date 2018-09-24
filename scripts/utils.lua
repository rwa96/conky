return {

    -- Converts color strings like #FFF or FFFFFF to
    -- rgb values ranging from 0 to 1
    --
    -- @param   hex string
    -- @returns number,number,number
    hex2rgb = function (hex)
        local r = 0
        local g = 0
        local b = 0
        local tmp = string.gsub(hex, "#", "")

        if  string.len(tmp) == 3 or string.len(tmp) == 6 then
            if string.len(tmp) == 3 then
                tmp = string.gsub(tmp, "([a-fA-F0-9])", "%1%1")
            end

            r = tonumber(string.sub(tmp,1,2), 16) / 255
            g = tonumber(string.sub(tmp,3,4), 16) / 255
            b = tonumber(string.sub(tmp,5,6), 16) / 255
        else
            print("error: unknown color format: " .. hex)
        end

        return r, g, b
    end,

    -- Creates a class to derive other classes/instances from
    --
    -- @param parent table (representation of the class)
    -- @returns function (creates a derived instance of that class)
    class = function (parent)
        return function (obj)
            setmetatable(obj, {__index=parent})
            return obj
        end
    end,

    -- Creates an rgba value used by drawables
    --
    -- @param r number (red value between 0 and 1)
    -- @param gnumber (green value between 0 and 1)
    -- @param b number (blue value between 0 and 1)
    -- @param a number (alpha value between 0 and 1)
    -- @returns table (rgba object)
    create_rgba = function (r, g, b, a)
        if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(a) ~= "number" then
            print("error: invalid color: (" .. r .. "," .. g .. "," .. b .. "," .. a ..")")
        end
        return {t="rgba", r, g, b, a}
    end,

    -- Creates a linear gradient between two specified positions
    --
    -- @param s_pos table (starting position {x,y})
    -- @param e_pos table (end position {x,y})
    -- @param ... (gradient steps defined by 5 values: percentage, r, g, b, a)
    -- @returns table (linear gradient object)
    create_linear = function (s_pos, e_pos, ...)
        if type(s_pos[1]) ~= "number" or type(s_pos[2]) ~= "number" or type(e_pos[1]) ~= "number" or type(e_pos[2]) ~= "number" then
            print("error: invalid gradient positions")
        end

        for i, step in ipairs({...}) do
            for j = 1,5 do
                if type(step[j]) ~= "number" then print("error: invalid linear gradient step") end
            end
        end

        return {t="linear", s=s_pos, e=e_pos, ...}
    end,

    -- Creates a radial gradient between two specified circles
    --
    -- @param c1 table (center of first circle {x,y})
    -- @param r2 number (radius of first circle)
    -- @param c2 table (center of second circle {x,y})
    -- @param r2 number (radius of second circle)
    -- @param ... (gradient steps defined by 5 values: percentage, r, g, b, a)
    create_radial = function (c1, r1, c2, r2, ...)
        if type(c1[1]) ~= "number" or type(c1[2]) ~= "number" or type(c2[1]) ~= "number" or type(c2[2]) ~= "number" then
            print("error: invalid gradient positions")
        end
        if type(r1) ~= "number" or type(r2) ~= "number" then
            print("error: invalid gradient radii")
        end

        for i, step in ipairs({...}) do
            for j = 1,5 do
                if type(step[j]) ~= "number" then print("error: invalid radial gradient step") end
            end
        end

        return {t="radial", c1=c1, r1=r1, c2=c2, r2=r2, ...}
    end
}
