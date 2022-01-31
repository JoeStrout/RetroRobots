// This module defines the display types and numbers.

floorLayer = 6
actionLayer = 5
wallLayer = 4
overlayGfxLayer = 2

init = function()
	clear
	
	display(floorLayer).mode = displayMode.tile
	outer.floor = display(floorLayer)
	floor.tileSet = file.loadImage("pics/floorGrid.png")
	floor.tileSetTileSize = floor.tileSet.width
	floor.cellSize = 128
	floor.extent = [10, 6]
	floor.clear 0
	floor.scrollX = 0; floor.scrollY = 0
	
	display(actionLayer).mode = displayMode.sprite
	outer.action = display(actionLayer)
	action.clear
	
	display(wallLayer).mode = displayMode.sprite
	outer.wall = display(wallLayer)
	wall.clear
	
	display(overlayGfxLayer).mode = displayMode.pixel
	outer.overlayGfx = display(overlayGfxLayer)
	overlayGfx.clear color.clear, 1000,650
	overlayGfx.scrollX = 20
	overlayGfx.fillRect 0, 610, 1000, 40, color.gray
	overlayGfx.line 0, 610, 1000, 610, "#444444"
	
end function

shiftFloor = function(dx, dy)
	floor.scrollX = (floor.scrollX - dx + 512) % 128
	floor.scrollY = (floor.scrollY - dy + 512) % 128
end function

if locals == globals then init

	