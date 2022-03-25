import "textUtil"
import "chars"

Score = {}
Score.points = 0
Score.name = ""

scores = []

addScore = function(points, name)
	sc = new Score
	sc.points = points
	sc.name = name
	scores.push sc
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
	top = 20
	//	text.color = color.yellow
	//	textUtil.printCenteredAt 34, top, "TOP 10 HIGH SCORES"
	s = "TOP 10 HIGH SCORES"
	gfx.print s, 480 - s.len*10, top*24+10, color.yellow, "large"
	
	text.color = "#880000"
	textUtil.printCenteredAt 34, top-2, " RANK     SCORE           NAME"
	gfx.print " ____     _____           ____", 19*14-2, (top-2)*24-3, text.color
	gfx.print " ____     _____           ____", 19*14+5, (top-2)*24-3, text.color
	
	text.color = color.aqua
	for i in scores.indexes
		text.color = colorForRow(i)
		textUtil.printCenteredAt 34, top-4-i, textForRow(i)
	end for
end function

highlight = function(row)
	gfx.fillRect 0, 0, 960, 17.5*24, color.clear
	gfx.color = colorForRow(row)
	y = 20 - 4 - row
	s = textForRow(row)
	x = 34 - floor(s.len/2)
	// gfx.print s, x*14+4, y*24+6
	gfx.print s, x*14+2, y*24+6
end function

postNewScoreDialog = function
	display(2).mode = displayMode.sprite
	dlogSprite = new Sprite
	dlogSprite.image = file.loadImage("pics/newHighScore.png")
	dlogSprite.x = 480
	dlogSprite.y = 400
	dlogSprite.tint = "#88FFFF"
	dlogSprite.scale = 0.1
	display(2).sprites = [dlogSprite]
	while dlogSprite.scale < 1.1
		yield
		dlogSprite.scale = dlogSprite.scale + 0.1
	end while
	dlogSprite.scale = 1
	
	display(1).mode = displayMode.pixel
	gfx = display(1)
	gfx.clear color.clear
	drawChar = function(c, pos, charColor="#FFFF00")
		x = dlogSprite.x - 48 + 36*pos
		gfx.fillRect x, dlogSprite.y-72, 24, 32, color.clear
		gfx.print c, x, dlogSprite.y-72, charColor, "large"
	end function
	drawInitials = function(cursor=null)
		for pos in [0,1,2]
			if pos == initials.len then
				if cursor == null then cursor = chars.figureStanding
				drawChar cursor, pos, color.silver
			else if pos < initials.len then
				drawChar initials[pos], pos
			else
				drawChar " ", pos
			end if
		end for
	end function
	initials = ""
	while true
		drawInitials
		waitFrames = 0
		while not key.available
			yield
			waitFrames = waitFrames + 1
			if waitFrames < 200 then continue
			if waitFrames % 800 >= 600 then
				if waitFrames % 800 == 600 then drawInitials chars.figureAkimbo
			else if waitFrames % 40 == 20 then
				drawInitials chars.figureWaitingToeUp
			else if waitFrames % 40 == 0 then
				drawInitials chars.figureWaitingToeDown
			end if
		end while
		k = key.get
		if k.code == 8 or k.code == 127 then
			if initials.len then initials = initials[:-1]
		else if k.code == 10 or k.code == 3 then
			initials = (initials + "   ")[:3]
			drawInitials
			break
		else if k.code > 31 and initials.len < 3 then
			initials = initials + k.upper
		end if
	end while
	return initials
end function

mainLoop = function
	curRow = -1
	nextTime = 0
	while true
		if time > nextTime then
			curRow = (curRow + 1) % 10
			highlight curRow
			nextTime = time + 0.2 + 1.8*(curRow==9)
		end if
		yield
	end while
end function

if locals == globals then
	clear
	showScores
	mainLoop
end if