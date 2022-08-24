local monitor = assert(peripheral.find("monitor"))
local input = arg[1]

local image = assert(paintutils.loadImage(input))
term.redirect(monitor)
paintutils.drawImage(image, 0, 0)
term.setBackgroundColour(colours.black)
