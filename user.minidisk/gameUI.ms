// This module is responsible for drawing the UI at the top of
// the screen during a game, showing score(s) and lives left.

if globals == locals then
	import "displays"
	import "images"
	displays.init
end if

barColor = color.gray

init = function
	g = displays.overlayGfx
	g.clear color.clear, 1000,650
	g.scrollX = 20
	g.fillRect 0, 610, 1000, 40, barColor
	g.line 0, 610, 1000, 610, "#444444"
end function

// Update the display.  Call this only when something changes.
update = function
	g = displays.overlayGfx
	
	// draw lives
	totalLives = totalLivesLeft
	x = g.scrollX + 480 - 6*16
	g.fillRect x, 611, 6*32, 40, barColor
	if totalLives then
		x = g.scrollX + 480 - totalLives*16
		for i in range(0, totalLives-1)
			g.drawImage images.playerLifeIcon, x+32*i, 611, 32, 32,
			  0, 0, 32, 32, color.silver
		end for
	end if
	
	// draw player 1 score and powerups
	x = g.scrollX + 150
	g.fillRect x, 611, 20*6, 40, barColor
	s = "000000" + player.score
	g.print s[-6:], x, 610, player.tint, "large"
	for i in range(3)
		x = g.scrollX + 110 - 32*i
		g.fillRect x, 611, 36, 32, barColor
		if i < player.powerups.len then
			g.drawImage player.powerups[i].icon, x, 611, 36, 32
		end if
	end for
	
	// draw player 2 score
	if player2 then
		x = g.scrollX + 810 - 20*6
		g.fillRect x, 611, 20*6, 40, barColor
		s = "000000" + player2.score
		g.print s[-6:], x, 610, player2.tint, "large"
		for i in range(3)
			x = g.scrollX + 818 + 32*i
			g.fillRect x, 611, 36, 32, barColor
			if i < player2.powerups.len then
				g.drawImage player2.powerups[i].icon, x, 611, 36, 32
			end if
		end for
	end if
	
end function


if globals == locals then
	player = {}
	player.livesLeft = 2
	player.score = 12345
	player.tint = "#FFFFCC"
	
	player2 = {}
	player2.livesLeft = 1
	player2.score = 2468
	player2.tint = "#CCCCFF"
	
	totalLivesLeft = 3
	
	init
	update
end if
