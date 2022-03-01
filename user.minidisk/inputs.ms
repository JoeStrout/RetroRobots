// This module defines the Inputs class, which collects
// keyboard/gamepad inputs for one player.


if globals.hasIndex("dvorak") and dvorak then
	dpadKeys = [",aoe", "chtn"]
else
	dpadKeys = ["wasd", "ijkl"]
end if

Inputs = {}
Inputs.playerNum = 0		// 1 (left), 2 (right), or 0 (both)
Inputs.dpadKeys = dpadKeys[0]

Inputs.horizontal = function
	h = 0
	if self.playerNum == 0 then h = key.axis("Horizontal")
	if h == 0 then h = key.axis("Joy" + self.playerNum + "Axis1")
	if abs(h) < 0.1 then h = 0
	if h then return h
	h = key.pressed(self.dpadKeys[3]) - key.pressed(self.dpadKeys[1])
	return h
end function

Inputs.vertical = function
	v = 0
	if self.playerNum == 0 then v = key.axis("Vertical")		
	if v == 0 then v = key.axis("Joy" + self.playerNum + "Axis2")
	if abs(v) < 0.1 then v = 0
	if v then return v
	v = key.pressed(self.dpadKeys[0]) - key.pressed(self.dpadKeys[2])
	return v
end function

Inputs.fire = function
	if self.playerNum <= 1 then
		if key.pressed("left shift") or
		  key.pressed("joystick 1 button 0") or
		  key.pressed("joystick 1 button 1") then return true
		if playerController.Player.instances.len == 1 then
			return key.pressed("right shift")
		end if
		return false
	else  // (player 2)
		return key.pressed("right shift") or
		  key.pressed("joystick 2 button 0") or
		  key.pressed("joystick 2 button 1")
	end if
end function

inputsForPlayer = function(playerNum)
	result = new Inputs
	result.playerNum = playerNum
	result.dpadKeys = dpadKeys[playerNum]
	return result
end function