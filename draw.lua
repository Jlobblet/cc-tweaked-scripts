local monitor = assert(peripheral.find("monitor"))
local imagePath = arg[1]
local colourPath = arg[2]

local colourFile = assert(io.open(colourPath, "r"))
local colours = {
    colours.white,
    colours.orange,
    colours.magenta,
    colours.lightBlue,
    colours.yellow,
    colours.lime,
    colours.pink,
    colours.grey,
    colours.lightGrey,
    colours.cyan,
    colours.purple,
    colours.blue,
    colours.brown,
    colours.green,
    colours.red,
    colours.black,
}

for i = 1, #colours do
    local line = colourFile:read("l")
    local hex = tonumber(line, 16)
    monitor.setPaletteColour(colours[i], hex)
end

colourFile:close()

term.redirect(monitor)
local image = assert(paintutils.loadImage(imagePath))
paintutils.drawImage(image, 0, 0)
