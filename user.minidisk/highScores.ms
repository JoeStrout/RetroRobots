// This module manages high scores (saving and loading), the new-high-score
// dialog, and the display of all the high scores.

import "textUtil"
if not globals.hasIndex("displays") then
	import "displays"
	displays.init
end if
if not globals.hasIndex("chars") then
	import "chars"
	globals.chars = chars
end if

// We'll do our pixel drawing in display 1
_g = null
g = function
	if not _g then
		display(1).mode = displayMode.pixel
		outer._g = display(1)
		_g.clear color.clear
	end if
	return _g
end function

Score = {}
Score.points = 0
Score.name = ""

scores = []

isHighScore = function(newScore)
	if not scores then return true
	return (newScore > scores[-1].points)
end function

addScore = function(points, name)
	sc = new Score
	sc.points = points
	sc.name = name
	scores.push sc
	scores.sort "points", 0
	if scores.len > 10 then outer.scores = scores[:10]
end function

if not scores then
	addScore 10000, "BBJ"
	addScore 9500, "MOO"
	addScore 900, "LEE"
	addScore 850, "BO"
	addScore 800, "FPS"
	addScore 750, "BOT"
	addScore 700, "MOR"
	addScore 650, "WHO"
	addScore 600, "TRU"
	addScore 550, "WUT"
end if

textForRow = function(row)
	s = str(row+1)
	if row < 3 then
		s = s + ["ST", "ND", "RD"][row]
	else
		s = s + "TH"
	end if
	if row < 9 then s = " " + s
	s = s + "   "
	sc = scores[row]
	s = s + ("      " + sc.points)[-7:]
	s = s + " . . . . . " + (sc.name + "   ")[:3]
	return s
end function

colorForRow = function(row)
	if row < 3 then return color.aqua
	if row < 6 then return color.silver
	return color.green
end function

showScores = function
	displays.darken
	
	top = 20
	//	text.color = color.yellow
	//	textUtil.printCenteredAt 34, top, "TOP 10 HIGH SCORES"
	img = file.loadImage("pics/highScoresTitle.png")
//	s = "TOP 10 HIGH SCORES"
//	g.print s, 480 - s.len*10, top*24+10, color.yellow, "large"
	g.drawImage img, 480 - img.width/2, top*24 + img.height/2
	
	text.color = "#880000"
	textUtil.printCenteredAt 34, top-2, " RANK     SCORE           NAME"
	g.print " ____     _____           ____", 19*14-2, (top-2)*24-3, text.color
	g.print " ____     _____           ____", 19*14+5, (top-2)*24-3, text.color
	
	text.color = color.aqua
	for i in scores.indexes
		text.color = colorForRow(i)
		textUtil.printCenteredAt 34, top-4-i, textForRow(i)
	end for
end function

highlight = function(row)
	g.fillRect 0, 0, 960, 17.5*24, color.clear
	g.color = colorForRow(row)
	y = 20 - 4 - row
	s = textForRow(row)
	x = 34 - floor(s.len/2)
	// g.print s, x*14+4, y*24+6
	g.print s, x*14+2, y*24+6
end function

postNewScoreDialog = function(tint="#FFFFFF")
	// Post the "new high score" dialog.  We'll do all our drawing
	// in displays.overlayGfxLayer.

	dlogX = 480; dlogY = 400
	g.clear
	g.scale = 0.1
	g.scrollX = (dlogX*g.scale) - dlogX
	g.scrollY = (dlogY*g.scale) - dlogY
	img = file.loadImage("pics/newHighScore.png")
	g.drawImage img, dlogX - img.width/2, dlogY - img.height/2, img.width, img.height,
	 	0, 0, img.width, img.height, tint
	while g.scale < 1.1
		yield
		g.scale = g.scale + 0.1
		g.scrollX = (dlogX*g.scale) - dlogX
		g.scrollY = (dlogY*g.scale) - dlogY
	end while
	g.scale = 1
	g.scrollX = 0; g.scrollY = 0

	drawChar = function(g, c, pos, charColor="#FFFF00")
		x = dlogX - 48 + 36*pos
		g.fillRect x, dlogY-72, 24, 32, color.black
		g.print c, x, dlogY-72, charColor, "large"
	end function
	drawInitials = function(g, cursor=null)
		for pos in [0,1,2]
			if pos == initials.len then
				if cursor == null then cursor = chars.figureStanding
				drawChar g, cursor, pos, color.silver
			else if pos < initials.len then
				drawChar g, initials[pos], pos
			else
				drawChar g, " ", pos
			end if
		end for
	end function
	initials = ""
	while true
		drawInitials g
		waitFrames = 0
		while not key.available
			yield
			waitFrames = waitFrames + 1
			if waitFrames < 200 then continue
			if waitFrames % 800 >= 600 then
				if waitFrames % 800 == 600 then drawInitials g, chars.figureAkimbo
			else if waitFrames % 40 == 20 then
				drawInitials g, chars.figureWaitingToeUp
			else if waitFrames % 40 == 0 then
				drawInitials g, chars.figureWaitingToeDown
			end if
		end while
		k = key.get
		if k.code == 8 or k.code == 127 then
			if initials.len then initials = initials[:-1]
		else if k.code == 10 or k.code == 3 then
			initials = (initials + "   ")[:3]
			drawInitials g
			break
		else if k.code > 31 and initials.len < 3 then
			initials = initials + k.upper
		end if
	end while
	while g.scale > 0.1
		g.scale = g.scale - 0.1
		g.scrollX = (dlogX*g.scale) - dlogX
		g.scrollY = (dlogY*g.scale) - dlogY
		yield
	end while	
	g.clear
	g.scale = 1; g.scrollX = 0; g.scrollY = 0
	return initials
end function

update = function
	curRow = -1
	nextTime = 0
	while true
		if time > nextTime then
			curRow = (curRow + 1) % 10
			highlight curRow
			nextTime = time + 0.2 // + 1.8*(curRow==0)
		end if
		yield
	end while
end function

showScoresTillKeypress = function
	showScores
	while not key.available
		update
	end while
	key.clear
end function

if locals == globals then
	displays.init
	name = postNewScoreDialog
	addScore 12345, name
	showScores
	while true; update; end while
end if