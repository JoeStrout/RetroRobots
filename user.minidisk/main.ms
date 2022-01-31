// Main program for the Retro Robots game.


import "displays"; displays.init
import "images"
import "updatable"
import "roomManager"
import "playerController"
import "shotController"
import "inputs"
import "mathUtil"


curRoom = new roomManager.Room
curRoom.createWalls

player = new playerController.Player
player.init 0
player.x = 480 - 40
player.y = 320
player.inputs = inputs.inputsForPlayer(0)
displays.action.sprites.push player

player2 = new playerController.Player
player2.init 1
player2.x = 480 + 40
player2.y = 320
player2.inputs = inputs.inputsForPlayer(1)
displays.action.sprites.push player2

players = playerController.Player.instances

moveToNextRoom = function(playerPos, otherPlayer)
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

	targetX = curRoom.x + roomManager.kWidth * dirX
	targetY = curRoom.y + roomManager.kHeight * dirY
	nextRoom = new roomManager.Room
	nextRoom.x = curRoom.x - roomManager.kWidth * dirX
	nextRoom.y = curRoom.y - roomManager.kHeight * dirY
	nextRoom.createWalls
	nextRoom.createRobots 1
	while curRoom.x != targetX or curRoom.y != targetY
		delta = curRoom.moveTowards(targetX, targetY)
		nextRoom.shift delta.x, delta.y
		for p in players
			p.x = p.x + delta.x
			p.y = p.y + delta.y
		end for
		displays.shiftFloor delta.x, delta.y
		yield
	end while
	curRoom.close
	outer.curRoom = nextRoom
	playerPos.disabled = false
	if otherPlayer then otherPlayer.disabled = false
end function

while true
	yield
	updatable.update
	if players.len == 1 then
		// single player, simple case: shift when out of bounds
		if curRoom.isOutOfBounds(player) then
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
	if key.available and key.get == char(27) then break
end while

