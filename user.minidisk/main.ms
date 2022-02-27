// Main program for the Retro Robots game.


import "mathUtil"
import "listUtil"
import "displays"; displays.init
import "constants"
import "images"
import "updatable"
import "robotController"
import "roomManager"
import "playerController"
import "shotController"
import "evilBottoController"
import "powerups"
import "inputs"
import "gameUI"
import "sounds"

sounds.loadAll

curLevel = 5
bottoAppearTime = 0
movingToNextRoom = false

botto = evilBottoController.Botto

curRoom = new roomManager.Room
curRoom.createWalls

player = new playerController.Player
player.init 0
player.inputs = inputs.inputsForPlayer(0)
displays.action.sprites.push player

if globals.hasIndex("numPlayers") and numPlayers == 2 then
	player2 = new playerController.Player
	player2.init 1
	player2.inputs = inputs.inputsForPlayer(1)
	displays.action.sprites.push player2
else
	player2 = null
end if

players = playerController.Player.instances

for p in players; p.reset; end for

totalLivesLeft = function
	result = player.livesLeft
	if player2 then result = result + player2.livesLeft
	return result
end function

deductLife = function
	if player2 then
		if player.livesLeft > player2.livesLeft then
			player.livesLeft = player.livesLeft - 1
		else
			player2.livesLeft = player2.livesLeft - 1
		end if
	else
		player.livesLeft = player.livesLeft - 1
	end if
	gameUI.update
end function

curLevel = function
	score = player.score
	if player2 and player2.score > player.score then score = player2.score
	if score > 10000 then return 4
	if score > 7000 then return 3
	if score > 3000 then return 2
	if score > 800 then return 1
	return 0
end function

gameUI.init
gameUI.update

moveToNextRoom = function(playerPos, otherPlayer)
	if curRoom.robots then curRoom.playChickenTaunt
	globals.movingToNextRoom = true
	dirX = 0; dirY = 0	// direction we are shifting
	if playerPos.x < curRoom.x + 10 then
		dirX = 1
	else if playerPos.x > curRoom.x + roomManager.kWidth - 10 then
		dirX = -1
	else if playerPos.y < curRoom.y + 10 then
		dirY = 1
	else
		dirY = -1
	end if

	if otherPlayer then
		if otherPlayer.dying or otherPlayer.dead then
			if totalLivesLeft < 1 then
				// other player remains dead!
				otherPlayer.dead = true
				otherPlayer.image = null
			else
				// respawn other player, taking one extra life
				deductLife
				otherPlayer.reset
			end if
		end if
		if dirX then
			otherPlayer.x = playerPos.x - 40 * dirX
			if playerPos.y > curRoom.y + roomManager.kHeight/2 then
				otherPlayer.y = playerPos.y - 40
			else
				otherPlayer.y = playerPos.y + 40
			end if
		else
			otherPlayer.y = playerPos.y - 60 * dirY
			if playerPos.x > curRoom.x + roomManager.kWidth/2 then
				otherPlayer.x = playerPos.x - 40
			else
				otherPlayer.x = playerPos.x + 40
			end if
		end if
	end if
	gameUI.update

	targetX = curRoom.x + roomManager.kWidth * dirX
	targetY = curRoom.y + roomManager.kHeight * dirY
	oldRoom = curRoom
	nextRoom = new roomManager.Room
	nextRoom.x = curRoom.x - roomManager.kWidth * dirX
	nextRoom.y = curRoom.y - roomManager.kHeight * dirY
	nextRoom.createWalls
	nextRoom.createRobots curLevel
	nextRoom.clearRobotsNearPlayer
	nextRoom.createPowerup
	nextRoom.prepareDoors playerPos
	while oldRoom.x != targetX or oldRoom.y != targetY
		delta = oldRoom.moveTowards(targetX, targetY)
		nextRoom.shift delta.x, delta.y
		for p in players
			// Applying slighly less delta to the player shifts them
			// fully into the room, so they don't get hit by the door.
			p.x = p.x + delta.x * 0.98
			p.y = p.y + delta.y * 0.95
		end for
		displays.shiftFloor delta.x, delta.y
		botto.shift delta.x, delta.y
		yield
	end while
	outer.curRoom = nextRoom
	oldRoom.close
	playerPos.disabled = false
	if otherPlayer and not otherPlayer.dead then otherPlayer.disabled = false
	botto.deactivate
	botto.jumpTo playerPos.x + dirX*20, playerPos.y + dirY*100
	outer.bottoAppearTime = time + 20 / (curLevel + 1)
	globals.movingToNextRoom = false
	curRoom.playIntroSounds 0, 3 * roomManager.Room.chicken
end function

startNewLevel = function
	curRoom.close
	botto.deactivate
	botto.jumpTo -100, 320
	outer.curRoom = new roomManager.Room
	curRoom.createWalls
	curRoom.createRobots curLevel
	// Note: when we get down to 1 life, this always gives it to player 1.
	// Maybe we should instead give it to whichever player died last?
	for p in players
		if totalLivesLeft then
			deductLife
			p.dead = false
		end if 
	end for
	for p in players; if not p.dead then p.reset; end for
	gameUI.update
	curRoom.clearRobotsNearPlayer
	outer.bottoAppearTime = time + 20 / (curLevel + 1) + 4
end function

endGame = function
	outer.gameOver = true
end function

checkRoomExit = function
	if players.len == 1 then
		// single player, simple case: shift when out of bounds
		if curRoom.isOutOfBounds(player) and not player.dead then
			moveToNextRoom player
		end if
	else
		// 2-player co-op, a bit harder: disable the first
		// player when they move out of bounds, and then 
		// shift when the second player exits
		for i in [0,1]
			if players[i].disabled then continue
			otherDisabled = players[i-1].disabled
			if curRoom.isOutOfBounds(players[i], not otherDisabled) then
				if otherDisabled then
					moveToNextRoom players[i], players[i-1]
				else
					players[i].disabled = true
				end if
			end if
		end for
	end if
end function

checkGameOver = function
	allDead = true
	for p in players
		if not p.dead then allDead = false
	end for
	if not allDead then return
	
	// OK, players are all currently dead.  Game over if
	// no lives left; otherwise, start a new level and 
	// spawn in one or both.
	if totalLivesLeft then
		startNewLevel
	else
		endGame
	end if
end function

gameOver = false
gameLoop = function
	fpsStartTime = time
	fpsFrameCount = 0
	while not gameOver
		fpsFrameCount = fpsFrameCount + 1
		if time > fpsStartTime + 1 then
			//text.row=1; text.column=60; print fpsFrameCount+"   "
			fpsFrameCount = 0
			fpsStartTime = time
		end if
		yield
		updatable.update
		if botto.active then
			botto.update
		else if bottoAppearTime and time > bottoAppearTime then
			botto.activate		
		end if
		checkRoomExit
		checkGameOver
		if key.available and key.get == char(27) then break
	end while
end function

gameLoop

