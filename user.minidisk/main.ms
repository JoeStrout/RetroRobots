// Main program for the Retro Robots game.

clear

import "images"
import "roomManager"
import "playerController"
import "shotController"
import "inputs"
import "mathUtil"

curRoom = new roomManager.Room
curRoom.createWalls

player = new playerController.Player
player.x = 480
player.y = 320
player.inputs = inputs.inputsForPlayer(0)
display(4).sprites.push player

moveToNextRoom = function(playerPos)
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
	targetX = curRoom.x + roomManager.kWidth * dirX
	targetY = curRoom.y + roomManager.kHeight * dirY
	nextRoom = new roomManager.Room
	nextRoom.x = curRoom.x - roomManager.kWidth * dirX
	nextRoom.y = curRoom.y - roomManager.kHeight * dirY
	nextRoom.createWalls
	while curRoom.x != targetX or curRoom.y != targetY
		delta = curRoom.moveTowards(targetX, targetY)
		nextRoom.shift delta.x, delta.y
		player.x = player.x + delta.x
		player.y = player.y + delta.y
		yield
	end while
	curRoom.close
	outer.curRoom = nextRoom
end function

while true
	yield
	for sp in display(4).sprites
		if sp == player or sp isa shotController.Shot then
			// ToDo: make a common base class or list of updateable sprites
			sp.update
		end if
	end for
	if curRoom.isOutOfBounds(player) then
		moveToNextRoom player
	end if
	if key.available and key.get == char(27) then break
end while

