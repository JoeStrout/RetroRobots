// Main program for the Retro Robots game.

clear

import "images"
import "roomManager"
import "playerController"
import "inputs"

curRoom = new roomManager.Room
curRoom.createWalls

player = new playerController.Player
player.x = 480
player.y = 320
player.inputs = inputs.inputsForPlayer(0)
display(4).sprites.push player

while true
	yield
	player.update
	if key.available and key.get == char(27) then break
end while

