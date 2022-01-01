// playerController
//
//	Controls one player on the screen.

if locals == globals then
	import "images"
	import "inputs"
end if

Player = new Sprite
Player.livesLeft = 2
Player.powerShot = false
Player.tripleShot = false
Player.hasShield = false
Player.dying = false
Player.image = images.playerStanding
Player.inputs = null
Player.scale = [1,1]
Player.frameNum = 0
Player.nextFrameTime = 0
Player.aim = [1,0]		// dx,dy of aim direction
Player.tint = "#FFFFCC"	// (use #CCCCFF for player 2)

Player.update = function(dt=0.0167)
	h = self.inputs.horizontal
	v = self.inputs.vertical
	if self.inputs.fire then
		dx = self.aim[0]; dy = self.aim[1]
		if h or v then
			dx = (h > 0) - (h < 0)
			dy = (v > 0) - (v < 0)
		end if
		self.aim = [dx, dy]
		if dx > 0 then
			self.scale = [1,1]
		else if dx < 0 then
			self.scale = [-1,1]
		end if
		if dy == 0 then
			self.image = images.playerAimE
		else if dy > 0 then
			if dx == 0 then
				self.image = images.playerAimN
			else
				self.image = images.playerAimNE
			end if
		else
			if dx == 0 then
				self.image = images.playerAimS
			else
				self.image = images.playerAimSE
			end if
		end if
	else if h == 0 and v == 0 then
		self.image = images.playerStanding
	else
		if h > 0 then
			self.scale = [1,1]
		else if h < 0 then
			self.scale = [-1,1]
		end if
		if time > self.nextFrameTime then
			self.frameNum = (self.frameNum + 1) % images.playerRun.len
			self.image = images.playerRun[self.frameNum]
			self.nextFrameTime = time + 0.08
		end if
		self.x = self.x + h * 150 * dt
		self.y = self.y + v * 150 * dt
	end if
end function

if locals == globals then
	clear
	p = new Player
	p.x = 480
	p.y = 320
	p.inputs = inputs.inputsForPlayer(0)
	display(4).sprites.push p
	while true
		yield
		p.update
	end while

end if