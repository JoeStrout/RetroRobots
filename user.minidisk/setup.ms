// This module presents a UI to let the user adjust game settings,
// especially input keys/buttons.

import "textUtil"
import "listUtil"
import "bmfFonts"
import "events"


clear

bmfFonts.Font.center = function(s, midX=480, y=320, scale=1, tint="#FFFFFF")
	x = midX - self.width(s, scale)/2
	self.print s, x, y, scale, tint
end function

bmfFonts.Font.rightAlign = function(s, rightX=480, y=320, scale=1)
	x = rightX - self.width(s, scale)
	self.print s, x, y, scale
end function

f = bmfFonts.Font.load("fonts/robocop.bmf")

// Function names: indexed by [functionNum]
functions = ["Up", "Down", "Left", "Right", "Fire"]

// Inputs: indexed by [functionNum][alternate]
p1Inputs = [
["w", "joystick 1 axis 1 -"],
["s", "joystick 1 axis 1 +"],
["a", "joystick 1 axis 0 -"],
["d", "joystick 1 axis 0 -"],
["space", "joystick 1 button 0"]]

p2Inputs = [
["up", "joystick 2 axis 1 -"],
["down", "joystick 2 axis 1 +"],
["left", "joystick 2 axis 0 -"],
["right", "joystick 2 axis 0 -"],
["right shift", "joystick 2 button 0"]]

allInputs = [p1Inputs, p2Inputs]

// Layout constants
p1Top = 600
p2Top = 300
rowHeight = 32; baseline = 8
left = 100
colWidth = [100, 300, 300]

colLeft = function(column)
	x = left
	i = 0
	while i < column; x = x + colWidth[i]; i = i + 1; end while
	return x
end function

colMidX = function(column)
	return colLeft(column) + colWidth[column]/2
end function

allTops = [p1Top, p2Top]

//======================================================================
// Button class
//======================================================================
kStateNormal = 0
kStateHover = 1
kStatePressed = 2
Button = new events.EventSprite
Button.state = kStateNormal
Button.normalTint = color.white
Button.pressedTint = "#AAAAAA"
Button.hoverTint = color.yellow
Button.action = null

Button.finishSetup = function
	self.localBounds = new Bounds
	self.localBounds.width = self.image.width
	self.localBounds.height = self.image.height
	events.spriteDisplay.sprites.push self
end function

Button.setState = function(newState)
	if newState == self.state then return
	self.state = newState
	if self.state == kStateNormal then
		self.tint = self.normalTint
	else if self.state == kStateHover then
		self.tint = self.hoverTint
	else if self.state == kStatePressed then
		self.tint = self.pressedTint
	end if
end function

Button.onClick = function
	self.setState kStatePressed
end function

Button.onDrag = function
	if self.contains(mouse) then self.setState kStatePressed else self.setState kStateNormal
end function

Button.onDragEnd = function
	if self.state == kStatePressed then
		self.setState kStateNormal
		self.action
	end if
end function

Button.update = function

end function



makeButton = function(caption, left, bottom, width, height, bgColor="#444444", rightAlign=false)
	gfx.fillRect 0, 0, width, height, bgColor
	y =  height/2 + f.sizeOver/2
	if rightAlign then
		f.rightAlign caption, width - 10, y
	else
		f.center caption, width/2, y
	end if
	btn = new Button
	btn.image = gfx.getImage(0, 0, width, height)
	gfx.fillRect 0, 0, left, width, color.black
	btn.x = left + width/2
	btn.y = bottom + height/2
	btn.finishSetup
	return btn
end function

for pnum in [0, 1]
	y = allTops[pnum]
	f.center "Player " + (pnum+1) + " Controls", 480, y, 2
	y = y - 40
	btn = makeButton("Primary Input", colLeft(1)+2, y+2, colWidth[1]-4, rowHeight-4, color.black)
	btn.normalTint = color.silver; btn.pressedTint = color.gray; btn.tint = btn.normalTint
	btn = makeButton("Alternate Input", colLeft(2)+2, y+2, colWidth[2]-4, rowHeight-4, color.black)
	btn.normalTint = color.silver; btn.pressedTint = color.gray; btn.tint = btn.normalTint
	y = y - rowHeight
	inputs = allInputs[pnum]
	for i in inputs.indexes
		for col in range(0,2)
			if col == 0 then
				btn = makeButton(functions[i], left, y+2, colWidth[0]-4, rowHeight-4, color.black, true)
			else
				x = colLeft(col)
				btn = makeButton(inputs[i][col-1], x+2, y+2, colWidth[col]-4, rowHeight-4)
			end if
		end for
		y = y - rowHeight
	end for
end for


events.eventLoop.run