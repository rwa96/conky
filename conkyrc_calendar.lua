conky.config = {
    -- General
    total_run_times=0,              -- Total number of times for Conky to update before quitting (0 makes Conky run forever)
    double_buffer=true,             -- Use the Xdbe extension? (eliminates flicker)
    no_buffers=true,                -- Subtract (file system) buffers from used memory
    out_to_console=false,           -- No console output
    update_interval=1800,           -- Refreshrate in seconds

    -- Positioning
    alignment='tr',                 -- Alignement
    minimum_width=250,              -- Minimum width in px
    minimum_height=250,             -- Minimum height in px
    maximum_width=250,              -- Maximum width in px
    gap_x=50,                       -- Gap, in pixels, between right or left border of screen
    gap_y=350,                      -- Gap, in pixels, between top or bottom border of screen

    -- Font
    use_xft=true,                   -- Use Xft (anti-aliased font and stuff)
    xftalpha=1,                     -- Alpha of Xft font. Must be a value at or between 1 and 0.
    override_utf8_locale=true,      -- Force UTF8? requires XFT

    -- Window manager
    own_window=true,                -- Create own window to draw
    own_window_type='override',     -- Override windows are not under the control of the window manager
    own_window_transparent=true,    -- Set transparency

    -- Custom script
    lua_load=                       -- Loads the Lua scripts separated by spaces.
        '~/.conky/scripts/utils.lua '
    ..  '~/.conky/scripts/cairo_wrapper.lua '
    ..  '~/.conky/scripts/calendar.lua',
    lua_draw_hook_pre='main',       -- Called each iteration before drawing to the window
}

conky.text = [[]]
