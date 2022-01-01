// This module defines the Inputs class, which collects
// keyboard/gamepad inputs for one player.


Inputs = {}
Inputs.playerNum = 0		// 1 (left), 2 (right), or 0 (both)

Inputs.horizontal = function
	if self.playerNum == 0 then return key.axis("Horizontal")		
	h = key.axis("Joy" + self.playerNum + "Axis1")
	if abs(h) > 0.2 then return h
	h = key.pressed("d") - key.pressed("a")
	return h
end function

Inputs.vertical = function
	if self.playerNum == 0 then return key.axis("Vertical")		
	v = key.axis("Joy" + self.playerNum + "Axis2")
	if abs(v) > 0.2 then return h
	v = key.pressed("w") - key.pressed("s")
	return v
end function

Inputs.fire = function
	if self.playerNum == 0 then
		return key.pressed("left shift") or
		  key.pressed("right shift") or
		  key.pressed("joystick button 0") or
		  key.pressed("joystick button 1")
	end if
	if self.playerNum == 1 then
		return key.pressed("left shift") or
		  key.pressed("joystick 1 button 0") or
		  key.pressed("joystick 1 button 1")
	else
		return key.pressed("right shift") or
		  key.pressed("joystick 2 button 0") or
		  key.pressed("joystick 2 button 1")
	end if
end function

inputsForPlayer = function(playerNum)
	result = new Inputs
	result.playerNum = playerNum
	return result
end function