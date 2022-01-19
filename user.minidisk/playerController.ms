// playerController
//
//	Controls one player on the screen.

if locals == globals then
	import "images"
	import "inputs"
	import "shotController"
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
Player.aim = [1,0]			// dx,dy of aim direction
Player.aimOffset = [0,0]	// where bullets appear relative to our position
Player.tint = "#FFFFCC"	// (use #CCCCFF for player 2)
Player.idleSince = 0
Player.lastShotTime = 0

Player.update = function(dt=0.0167)
	h = self.inputs.horizontal
	v = self.inputs.vertical
	if self.inputs.fire then
		// shooting
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
			self.aimOffset = [17, 9]
		else if dy > 0 then
			if dx == 0 then
				self.image = images.playerAimN
				self.aimOffset = [11, 25]
			else
				self.image = images.playerAimNE
				self.aimOffset = [17, 20]
			end if
		else
			if dx == 0 then
				self.image = images.playerAimS
				self.aimOffset = [0, 0]
			else
				self.image = images.playerAimSE
				self.aimOffset = [14, -5]
			end if
		end if
		self.aimOffset[0] = self.aimOffset[0] * self.scale[0]
		self.idleSince = time
		self.fire
	else if h == 0 and v == 0 then
		// standing around (idle)
		idleTime = time - self.idleSince
		if idleTime < 10 then
			self.image = images.playerStanding
			self.frameNum = 0
		else if time > self.nextFrameTime then
			self.frameNum = (self.frameNum + 1) % images.playerTapping.len
			self.image = images.playerTapping[self.frameNum]
			self.nextFrameTime = time + 0.25
			if idleTime > 20 then
				self.image = images.playerStanding
				self.scale = [-self.scale[0], 1]
				self.idleSince = time - 5
			end if
		end if
	else
		// moving
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
		self.idleSince = time
	end if
end function

Player.fire = function
	// Make sure there's been enough time since the last shot
	if time < self.lastShotTime + 0.3 then return	// too soon!
	self.lastShotTime = time
	
	shot = new shotController.Shot
	shot.x = self.x + self.aimOffset[0]
	shot.y = self.y + self.aimOffset[1]
	shot.rotation = atan(self.aim[1], self.aim[0]) * 180/pi
	shot.tint = self.tint
	display(4).sprites.push shot
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
		for sp in display(4).sprites
			sp.update
		end for
	end while

end if