import "textUtil"
if not globals.hasIndex("inputs") then import "inputs"

bigMapImg = file.loadImage("pics/Title.png")

clear

//======================================================================
// Rotating Title Globe
//======================================================================

sprites = display(4).sprites
globeSprites = []
sections = 12
secW = bigMapImg.width / sections
rings = 8
ringH = bigMapImg.height / rings
R = 200  // globe radius
for j in range(0, rings-1)
	for i in range(0, sections-1)
		sp = new Sprite
		sp.image = bigMapImg.getImage(i*secW, j*ringH, secW, ringH)
		yangBot = (10 + 160/rings * j) * pi/180
		yangTop = (10 + 160/rings * (j+1)) * pi/180
		sp.yBot = 440 - R * cos(yangBot)
		sp.yTop = 440 - R * cos(yangTop)
		sp.rBot = R * sin(yangBot) // radius at bottom
		sp.rTop = R * sin(yangTop) // radius at top
		sp.x = 480; sp.y = (sp.yBot + sp.yTop)/2
		sp.angLeft = i * 2*pi/sections
		sp.angRight = (i+1) * 2*pi/sections
		sprites.push sp
		globeSprites.push sp
	end for	
end for

positionSprites = function(rotDegrees)
	dang = rotDegrees * pi/180
	for sp in globeSprites
		corners = []
		corners.push [480+sp.rBot*cos(sp.angLeft+dang), sp.yBot]
		corners.push [480+sp.rBot*cos(sp.angRight+dang), sp.yBot]
		corners.push [480+sp.rTop*cos(sp.angRight+dang), sp.yTop]
		corners.push [480+sp.rTop*cos(sp.angLeft+dang), sp.yTop]
		sp.setCorners  corners
		sp.sortOrder = sin((sp.angLeft + sp.angRight)/2 + dang)
		if corners[1][0] > corners[0][0] then
			sp.tint = color.white
		else
			sp.tint = "#AAAAAA44"
		end if
	end for	
	sprites.sort "sortOrder", false
end function

//======================================================================
// Button class
//======================================================================

Button = new Sprite
Button.sortOrder = 0
Button.highlighted = false
Button.pressed = false
Button.instances = []
Button.shine = null // (list of shine frames)
Button.shineStep = 0
Button.tint = "#00BBB9"
Button.action = null
Button.keys = ""  // key(s) that can be pressed to activate this button
Button.loadShine = function(shineImg)
	self.shine= []
	h = shineImg.height/16
	for i in range(0, 15)
		self.shine.push shineImg.getImage(0, h*i, shineImg.width, h)
	end for
end function
Button.make = function(name, leftx, midy, keys)
	noob = new Button
	noob.keys = keys
	noob.stdImage = file.loadImage("pics/btn/" + name + ".png")
	noob.image = noob.stdImage
	noob.loadShine file.loadImage("pics/btn/" + name + "-shine.png")
	noob.x = leftx + noob.image.width/2
	noob.y = midy
	noob.localBounds = new Bounds
	noob.localBounds.width = noob.image.width
	noob.localBounds.height = noob.image.height
	sprites.push noob
	Button.instances.push noob
	return noob
end function
Button.highlight = function(hilightIt=true)
	self.highlighted = true
	self.tint = color.white
	for b in Button.instances
		if b.highlighted and b != self then
			b.highlighted = false
			b.image = b.stdImage
			b.tint = Button.tint
		end if
	end for
end function

Button.update = function
	if not self.highlighted then
		if self.contains(mouse) then self.highlight
	end if
	if self.contains(mouse) and mouse.button then
		self.image = self.stdImage
		while mouse.button
			yield
			if self.contains(mouse) then
				self.tint = color.white
			else
				self.tint = Button.tint
			end if
		end while
		if self.tint == color.white then
			self.action
		end if
		self.highlight false
	end if
	for k in self.keys
		if key.pressed(k) then
			self.image = self.stdImage
			self.tint = color.white
			wait 0.2
			self.action
			self.highlight false
		end if
	end for
	if self.highlighted then
		self.shineStep = (self.shineStep + 1) % (self.shine.len * 2 - 1)
		if self.shineStep < self.shine.len then
			self.image = self.shine[self.shineStep]
		else
			self.image = self.shine[self.shine.len - 2 - self.shineStep]
		end if
	end if
end function

//======================================================================
// Game Interface
//======================================================================

startGame = function(numPlayers=1)
	file.loadSound("sounds/VoiceIntruderAlert.wav").play
	display(1).mode = displayMode.solidColor
	for t in range(0, 1, 0.025)
		display(1).color = color.lerp(color.clear, color.black, t)
		yield
	end for
	for dispNum in range(2,7)
		if display(dispNum).mode > 1 then display(dispNum).clear
	end for	
	globals.numPlayers = numPlayers
	load "main"; run
end function

//======================================================================
// Button Setup
//======================================================================

btn1PStart = Button.make("1PStart", 80, 200, ["1", "return", "enter"])
btn1PStart.action = function
	startGame 1
end function


btn2PStart = Button.make("2PStart", 80, 100, "2")
btn2PStart.action = function
	startGame 2
end function

btnSettings = Button.make("Settings", 550, 200, "s")
btnSettings.action = function
	import "setup"
	setup.doSetup
	run
end function

btnHelp = Button.make("HowToPlay", 550, 100, ["h", "?", "/"])
btnHelp.action = function
	textUtil.printCenteredAt 34, 0, "Not implemented yet."
end function


//======================================================================
// Main Loop
//======================================================================

rot = 0
while true
	yield
	positionSprites rot
	rot = (rot + 358) % 360
	for b in Button.instances; b.update; end for
end while

