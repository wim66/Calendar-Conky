-- calendar.lua
-- Draws a monthly calendar with color settings for all elements
-- Version: 1.0 - May 1, 2025
-- Author: Wim66

require 'cairo'
-- Attempt to safely require the 'cairo_xlib' module
local status, cairo_xlib = pcall(require, 'cairo_xlib')

if not status then
    -- If not found, fall back to a dummy table
    -- Redirects unknown keys to the global namespace (_G)
    -- Allows use of global Cairo functions like cairo_xlib_surface_create
    cairo_xlib = setmetatable({}, {
        __index = function(_, key)
            return _G[key]
        end
    })
end

-- Helper function: hex to rgba
local function hex_to_rgba(hex)
    hex = hex:gsub("#","")
    local r = tonumber("0x"..hex:sub(1,2)) / 255
    local g = tonumber("0x"..hex:sub(3,4)) / 255
    local b = tonumber("0x"..hex:sub(5,6)) / 255
    return r, g, b, 1
end

-- Main function
function conky_draw_calendar()
    if not conky_window then return end

    local w = conky_window.width
    local h = conky_window.height
    local surface = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    local cr = cairo_create(surface)

    -- Settings (adjust to your preference)
    local font_name = "Ubuntu Mono"
    local font_size = 16
    local day_spacing = 22
    local start_x = 40
    local start_y = 40
    local show_weeknums = true

    -- Color settings
    local colour_month = "#44AAFF"
    local colour_weekdays = "#CCCCCC"
    local colour_days = "#FFFFFF"
    local colour_today = "#00FF00"
    local colour_outside = "#555555"
    local colour_weeknums = "#44AAFF"

    draw_calendar(cr, start_x, start_y, font_name, font_size, day_spacing, show_weeknums,
        colour_month, colour_weekdays, colour_days, colour_today, colour_outside, colour_weeknums)

    cairo_destroy(cr)
    cairo_surface_destroy(surface)
end

-- Draw the calendar
function draw_calendar(cr, x, y, font, size, spacing, weeknums,
    colour_month, colour_weekdays, colour_days, colour_today, colour_outside, colour_weeknums)
    -- Draw month name
    draw_month_name(cr, x, y, font, size, colour_month)

    -- Draw weekdays
    y = y + spacing
    draw_weekdays(cr, x, y, font, size, spacing, colour_weekdays)

    -- Draw days
    y = y + spacing
    draw_days(cr, x, y, font, size, spacing, weeknums,
        colour_days, colour_today, colour_outside)

    -- Draw week numbers
    if weeknums then
        draw_week_numbers(cr, x, y, font, size, spacing, colour_weeknums)
    end
end

function draw_month_name(cr, x, y, font, size, colour)
    local month_names = {}
    for i = 1, 12 do
        month_names[i] = os.date("%B", os.time{year = 2024, month = i, day = 1})
    end
    local now = os.date("*t")
    local month_text = month_names[now.month] .. " " .. now.year

    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, size + 4)
    cairo_set_source_rgba(cr, hex_to_rgba(colour))
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, month_text, extents)
    cairo_move_to(cr, x - extents.width / 2 + 60, y)
    cairo_show_text(cr, month_text)
end

function draw_weekdays(cr, x, y, font, size, spacing, colour)
    local weekday_names = {}
    local day = os.time{year = 2024, month = 1, day = 1} -- a Monday
    for i = 0, 6 do
        weekday_names[i + 1] = os.date("%a", os.time{year = 2024, month = 1, day = 1 + i})
    end

    cairo_set_font_size(cr, size)
    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    for i = 1, 7 do
        local label = weekday_names[i]
        cairo_set_source_rgba(cr, hex_to_rgba(colour))
        cairo_move_to(cr, x + (i-1)*spacing, y)
        cairo_show_text(cr, label)
    end
end

function draw_days(cr, x, y, font, size, spacing, weeknums,
    colour_days, colour_today, colour_outside)
    -- Calculate days and positions
    local now = os.date("*t")
    local year, month, day = now.year, now.month, now.day
    local first_day = os.time{year=year, month=month, day=1}
    local start_weekday = tonumber(os.date("%w", first_day)) -- 0=Sunday
    if start_weekday == 0 then start_weekday = 7 end

    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day

    -- Draw previous month's days
    local prev_month = month - 1
    local prev_year = year
    if prev_month < 1 then
        prev_month = 12
        prev_year = year - 1
    end
    local days_in_prev = os.date("*t", os.time{year=prev_year, month=prev_month+1, day=0}).day

    local line = 0
    local col = 1
    for i = 1, start_weekday - 1 do
        local d = days_in_prev - (start_weekday - 1) + i
        cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(d))
        col = col + 1
    end

    -- Draw current month's days
    for d = 1, days_in_month do
        if col > 7 then
            col = 1
            line = line + 1
        end
        if d == day then
            cairo_set_source_rgba(cr, hex_to_rgba(colour_today))
        else
            cairo_set_source_rgba(cr, hex_to_rgba(colour_days))
        end
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(d))
        col = col + 1
    end

    -- Draw next month's days
    local next_day = 1
    while col <= 7 do
        cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(next_day))
        col = col + 1
        next_day = next_day + 1
    end
end

function draw_week_numbers(cr, x, y, font, size, spacing, colour)
    local now = os.date("*t")
    local year, month = now.year, now.month
    local first_day = os.time{year=year, month=month, day=1}
    local start_weekday = tonumber(os.date("%w", first_day)) -- 0=Sunday
    if start_weekday == 0 then start_weekday = 7 end

    cairo_set_source_rgba(cr, hex_to_rgba(colour))
    local week_x = x - spacing

    -- Draw "wk" label
    cairo_set_font_size(cr, size)
    cairo_move_to(cr, week_x, y - spacing)
    cairo_show_text(cr, "wk")

    for l = 0, 4 do
        local d = l * 7 + 1 - (start_weekday - 1)
        local time = os.time{year=year, month=month, day=d}
        local wn = os.date("%V", time)
        cairo_move_to(cr, week_x, y + l*spacing)
        cairo_show_text(cr, wn)
    end
end