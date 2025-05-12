-- settings.lua
-- by @wim66
-- v5 May 6, 2025

-- Set the path to the scripts folder
package.path = "./scripts/?.lua"

function conky_vars()
  
    -- border_COLOR: Defines the gradient border for the Conky widget.
    -- Format: "start_angle,color1,opacity1,midpoint,color2,opacity2,steps,color3,opacity3"
    -- Example: "0,0x390056,1.00,0.5,0xff007f,1.00,1,0x390056,1.00" creates a purple-pink gradient.
    border_COLOR = "0,0x55007f,1.00,0.5,0xff69ff,1.00,1,0x55007f,1.00"

    -- bg_COLOR: Background color and opacity for the widget.
    -- Format: "color,opacity"
    -- Example: "0x1d1e28,0.75" sets a dark purple background with 75% opacity.
    bg_COLOR = "0x1d1d2e,1"
    
    -- layer_2: Defines the gradient for the second layer of the Conky widget.
    -- Format: "start_angle,color1,opacity1,midpoint,color2,opacity2,steps,color3,opacity3"
    -- Example: "0,0x00007f,0.50,0.5,0x00aaff,0.50,1,0x00007f,0.50" creates a blue gradient with 50% opacity.
    layer_2 = "0,0x55007f,0.50,0.5,0xff69ff,0.50,1,0x55007f,0.50"
end