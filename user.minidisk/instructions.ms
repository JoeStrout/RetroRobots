// This file displays the "How to Play" screen.

if not globals.hasIndex("stringUtil") then import "stringUtil"
if not globals.hasIndex("images") then import "images"
if not globals.hasIndex("robotController") then import "robotController"
if not globals.hasIndex("shotController") then import "shotController"
if not globals.hasIndex("evilBottoController") then import "evilBottoController"
if not globals.hasIndex("displays") then import "displays"

if not globals.hasIndex("robofont") then
	import "bmfFonts"
	robofont = bmfFonts.Font.load("fonts/robocop+.bmf")
end if

displays.init
display(2).mode = displayMode.pixel
globals.gfx = display(2)
display(1).mode = displayMode.pixel
xdisp = display(1)
xdisp.clear color.clear

updateables = []

delay = function(duration=1)
	endTime = time + duration
	while time < endTime
		yield
		for u in updateables; u.update; end for
	end while
end function

s = "HOW TO PLAY"
robofont.print s, 480 - robofont.width(s, 2)/2, 600, 2

typeCharSound = new Sound
typeCharSound.init 0.02, 220, [1,1,1,0]
typeLineSound = new Sound
typeLineSound.init 0.02, 164.8138, [1,1,1,0]

type = function(s, x, y, width=450)
	delay 1
	cw = robofont.width("m")
	cy = y + robofont.sizeOver
	for line in s.wrap(width / cw)
		cx = x - robofont.width(line)/2
		for c in line
			robofont.print c, cx, cy
			cx = cx + robofont.width(c)
			if key.available then continue
			if c != " " then typeCharSound.play 0.5
			delay 0.03
		end for
		typeLineSound.play 0.7
		cx = x
		cy = cy - robofont.lineHeight - 2
		delay 0.1
	end for
	key.clear
end function

playerTint = "#FFFFCC"
globals.curRoom = null
globals.movingToNextRoom = false
globals.players = []

x = 250
y = 550

drawX = function(x,y)
	xdisp.line x-50, y-30, x+50, y+30, "#FF000088", 10
	xdisp.line x-50, y+30, x+50, y-30, "#FF000088", 10
end function

type "Don't touch the walls.", x, y
gfx.drawImage images.playerStanding, x-16, y-100, -1, -1, 0, 0, -1, -1, playerTint
gfx.fillRect x+10, y-120, 16, 100
drawX x, y-70
y = y - 160

type "Don't touch the robots.", x, y
robot = robotController.Robot.make(1)
robot.x = x - 8; robot.y = y - 70
updateables.push robot
gfx.drawImage images.playerStanding, x+8, y-100, -1, -1, 0, 0, -1, -1, playerTint
drawX x, y-70
y = y - 160

type "Don't get shot.", x, y
robot = robotController.Robot.make(2)
robot.x = x - 50; robot.y = y - 70
updateables.push robot
gfx.drawImage images.playerStanding, x+38, y-100, -1, -1, 0, 0, -1, -1, playerTint
drawX x, y-70
y = y - 160
shot = new shotController.Shot
shot.startX = robot.x + 30
shot.endX = x + 30
shot.x = shot.startX
shot.y = robot.y
shot.tint = robot.tint
display(4).sprites.push shot
shot.update = function
	self.x = self.x + 5
	if self.x > self.endX then self.x = -1000
	if self.x < 0 and self.x > -900 then self.x = self.startX
end function
updateables.push shot

x = 960-250
y = 550

type "Watch out for Evil Botto.  He is invincible!", x, y
botto = evilBottoController.Botto
botto.jumpTo x, y - 170
botto.activate
botto.update
updateables.push botto
y = y - 266

type "Power-ups appear when you have cleared the previous room.  Collect them to make survival easier.", x, y
gfx.drawImage images.powerup[2], x-18, y-120

delay

s = "press any key to continue"
robofont.print s, 480 - robofont.width(s, 0.75)/2, 50, 0.75
while true
	yield
	for u in updateables; u.update; end for
	if key.available then break
end while
key.clear
clear

