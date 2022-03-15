// This module presents a UI to let the user adjust game settings,
// especially input keys/buttons.

import "textUtil"
import "listUtil"
import "bmfFonts"
import "events"


clear
display(2).mode = displayMode.pixel
display(2).clear color.clear
display(6).mode = displayMode.solidColor
display(6).color = color.black
display(7).mode = displayMode.pixel
tempGfx = display(7)
tempGfx.clear

bmfFonts.Font.center = function(s, midX=480, y=320, scale=1, tint="#FFFFFF")
	x = midX - self.width(s, scale)/2
	self.print s, x, y, scale, tint
end function

bmfFonts.Font.rightAlign = function(s, rightX=480, y=320, scale=1)
	x = rightX - self.width(s, scale)
	self.print s, x, y, scale
end function

f = bmfFonts.Font.load("fonts/robocop+.bmf")

// Function names: indexed by [functionNum]
functions = ["Up", "Down", "Left", "Right", "Fire"]

// Inputs: indexed by [functionNum][alternate]
p1Inputs = [
["w", "Joy1Axis1 -"],
["s", "Joy1Axis1 +"],
["a", "Joy1Axis0 -"],
["d", "Joy1Axis0 -"],
["space", "joystick 1 button 0"]]

p2Inputs = [
["up", "Joy2Axis1 -"],
["down", "Joy2Axis1 +"],
["left", "Joy2Axis0 -"],
["right", "Joy2Axis0 -"],
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

allAxes = []
for stickNum in range(1,7)
	for axisNum in range(0,7)
		allAxes.push "Joy" + stickNum + "Axis" + axisNum
	end for
end for

anyPressed = function
	for k in key.keyNames
		if key.pressed(k) then return true
	end for
	for axis in allAxes
		if abs(key.axis(axis)) > 0.5 then return true
	end for
	return false
end function

waitForAny = function
	while true
		for k in key.keyNames
			if key.pressed(k) then return k
		end for
		for axis in allAxes
			if abs(key.axis(axis)) > 0.5 then
				if key.axis(axis) > 0 then return axis + " +"
				return axis + " -"
			end if
		end for
		yield
	end while
end function	

getInputForFunction = function(playerNum, functionNum, alternate)
	globals.gfx = display(2)
	gfx.fillRect 480-150, 350-100, 150*2, 100*2, "#003300"
	gfx.drawRect 480-150, 350-100, 150*2, 100*2, "#88FF88"
	
	f.center "Release all", 480, 360; f.center "buttons", 480, 340
	while anyPressed; yield; end while
	gfx.fillRect 480-140, 350-90, 140*2, 90*2, "#003300"
	
	x = 480; y = 350+60
	f.center "Push", x, y, 1, "#CCCCAA"
	y = y - 20
	
	prompt = "Player " + (playerNum+1) + " "
	prompt = prompt + "ALTERNATE" * alternate + "PRIMARY" * (not alternate)
	f.center prompt, x, y
	y = y - 20
	
	f.center "input for", x, y, 1, "#CCCCAA"
	y = y - 50
	
	f.center functions[functionNum], x, y, 3
	y = y - 60
	f.center "(Esc to clear)", x, y, 1, "#CCCCAA"

	newKey = waitForAny
	if newKey == "escape" then newKey = ""
	allInputs[playerNum][functionNum][alternate] = newKey
	
	gfx.clear color.clear
	globals.gfx = display(5)
end function


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
Button.playerNum = null
Button.funcs = null		// list of function numbers for this button
Button.alts = null		// list of alternate values (0 or 1) for this button

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
	if self.playerNum != null and gfx == display(5) and
	  self.funcs and self.alts and self.funcs.len==1 and self.alts.len==1 then
		curInp = allInputs[self.playerNum][self.funcs[0]][self.alts[0]]
		if curInp != self.caption then
			self.caption = curInp
			self.makeImage
		end if
	end if
end function

Button.action = function
	for func in self.funcs
		for alt in self.alts
			getInputForFunction self.playerNum, func, alt
			for sp in events.spriteDisplay.sprites; sp.update; end for
			while anyPressed; yield; end while
		end for
	end for
end function

Button.makeImage = function
	globals.gfx = tempGfx
	gfx.fillRect 0, 0, self.width, self.height, self.bgColor
	y = self.height/2 + f.sizeOver/2
	if self.rightAlign then
		f.rightAlign self.caption, self.width - 10, y
	else
		f.center self.caption, self.width/2, y
	end if
	self.image = gfx.getImage(0, 0, self.width, self.height)
	globals.gfx = display(5)
end function

makeButton = function(caption, left, bottom, width, height, bgColor="#444444", rightAlign=false)
	btn = new Button
	btn.caption = caption
	btn.width = width
	btn.height = height
	btn.bgColor = bgColor
	btn.rightAlign = rightAlign
	btn.makeImage
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
	btn.playerNum = pnum; btn.alts = [0]; btn.funcs = range(0,4)
	btn = makeButton("Alternate Input", colLeft(2)+2, y+2, colWidth[2]-4, rowHeight-4, color.black)
	btn.normalTint = color.silver; btn.pressedTint = color.gray; btn.tint = btn.normalTint
	btn.playerNum = pnum; btn.alts = [1]; btn.funcs = range(0,4)
	y = y - rowHeight
	inputs = allInputs[pnum]
	for i in inputs.indexes
		for col in range(0,2)
			if col == 0 then
				btn = makeButton(functions[i], left, y+2, colWidth[0]-4, rowHeight-4, color.black, true)
				btn.playerNum = pnum; btn.alts = [0, 1]; btn.funcs = [i]
			else
				x = colLeft(col)
				btn = makeButton(inputs[i][col-1], x+2, y+2, colWidth[col]-4, rowHeight-4)
				btn.playerNum = pnum; btn.alts = [col-1]; btn.funcs = [i]
			end if
		end for
		y = y - rowHeight
	end for
end for


events.eventLoop.run