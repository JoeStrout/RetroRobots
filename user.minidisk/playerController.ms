// playerController
//
//	Controls one player on the screen.

if locals == globals then
	import "listUtil"
	import "images"
	import "inputs"
	import "shotController"
	import "updatable"
end if

Sprite.hitByLineSegment = function(endA, endB)
	return self.worldBounds.overlapsLineSegment(endA, endB)
end function

Player = new UpdatableSprite
Player.playerNum = 0		// 0 or 1
Player.livesLeft = 2
Player.score = 0
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
Player.disabled = false	// (disabled when they leave the room)
Player.dying = false
Player.dead = false
Player.localBounds = new Bounds
Player.localBounds.width = 20
Player.localBounds.height = 40
Player.powerups = []
Player.shield = new Sprite
Player.shield.image = images.shield
Player.shield.visible = false

Player.instances = []

Player.init = function(playerTwo)
	super.init
	self.playerNum = playerTwo
	if playerTwo then self.tint = "#CCCCFF"
	Player.instances.push self
end function

Player.reset = function
	livePlayers = 0
	for p in players; if not p.dead then livePlayers = livePlayers + 1; end for
	if livePlayers > 1 then
		self.x = 480 - 40 * (self.playerNum==0) + 40 * (self.playerNum==1)
	else
		self.x = 480
	end if
	self.y = 320
	self.dead = false
	self.dying =  false
	self.disabled = false
	self.image = images.playerStanding
	self.powerups = []
end function

Player.hasPowerup = function(powerup)
	return self.powerups.indexOf(powerup) != null
end function

Player.awardPowerup = function(powerup)
	if powerup == powerups.OneUp then
		self.livesLeft = self.livesLeft + 1
		sounds.Pickup.playAt self // ToDo: play extra-life sound
	else
		if self.hasPowerup(powerup) then return
		self.powerups.push powerup
		self.powerups.sort "sortOrder"
		sounds.Pickup.playAt self
	end if
	gameUI.update
end function

Player.addToScore = function(points)
	if self.hasPowerup(powerups.DoubleScore) then points = points * 2
	if floor((self.score + points) / constants.bonusLifeEvery) >
	   floor(self.score / constants.bonusLifeEvery) then
		// bonus life!
		self.livesLeft = self.livesLeft + 1
		sounds.Pickup.playAt self // ToDo: play extra-life sound
	end if
	self.score = self.score + points
	//print "Added to score: " + points + " from " + stackTrace[1]
	gameUI.update
end function

lineNum = 22
log = function(s)
	text.row = lineNum; print s
	if lineNum > 0 then outer.lineNum = lineNum - 1
end function

Player.update = function(dt=0.0167)
	if self.dead then return
	if self.dying then self.doDeathAnimation dt
	if self.disabled then return
	h = self.inputs.horizontal
	v = self.inputs.vertical
	if self.inputs.fire then
		// shooting
		dx = self.aim[0]; dy = self.aim[1]
		if h or v then
			dx = sign(h)	//(h > 0) - (h < 0)
			dy = sign(v)	//(v > 0) - (v < 0)
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
				self.aimOffset = [9, 40]
			else
				self.image = images.playerAimNE
				self.aimOffset = [25, 30]
			end if
		else
			if dx == 0 then
				self.image = images.playerAimS
				self.aimOffset = [0, -10]
			else
				self.image = images.playerAimSE
				self.aimOffset = [14, -5]
			end if
		end if
		self.aimOffset[0] = self.aimOffset[0] * self.scale[0]
		self.idleSince = time
		if self.hasPowerup(powerups.Shield) then self.showShield
		if time >= self.lastShotTime + 0.3 then self.fire
	else if h == 0 and v == 0 then
		// standing around (idle)
		self.hideShield
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
		self.hideShield
		self.aim = [sign(h), sign(v)]
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
		self.checkCollisions
	end if
end function

Player.showShield = function
	if not self.shield.visible then
		displays.action.sprites.push self.shield
		self.shield.visible = true
		self.shield.startTime = time
	end if
	self.shield.x = self.x
	self.shield.y = self.y + 6 * self.aim[1]
	self.shield.rotation = atan(self.aim[1], self.aim[0]) * 180/pi
end function

Player.hideShield = function
	if self.shield.visible then
		displays.action.sprites.removeVal self.shield
		self.shield.visible = false
	end if
end function

Player.fire = function
	// Make sure there's been enough time since the last shot
	if time < self.lastShotTime + 0.3 then return	// too soon!
	self.lastShotTime = time
	
	angles = [0]
	if self.hasPowerup(powerups.TripleShot) then angles = [-15,0,15]
	for angle in angles
		shot = new shotController.Shot
		shot.init self
		shot.x = self.x + self.aimOffset[0]
		shot.y = self.y + self.aimOffset[1]
		shot.rotation = angle + atan(self.aim[1], self.aim[0]) * 180/pi
		displays.action.sprites.push shot
	end for
	sounds.PlayerShot.playAt self
end function

Player.checkCollisions = function
	for sp in curRoom.robots + curRoom.walls
		if sp.overlaps(self) then
			if sp isa robotController.Robot then
				if sp.isDead then continue
				sp.explode
				self.addToScore constants.pointsPerRobotDestroyed
			end if
			self.die
			return
		end if
	end for
end function

Player.handleHit = function(shot, newHead, oldTail)
	if self.shield.visible then
		// Determine whether the bot hits the shield.
		shotVec = [oldTail.x - newHead.x, oldTail.y - newHead.y]
		cosAngBetween = self.aim[0]*shotVec[0] + self.aim[1]*shotVec[1] / 
			(sqrt(self.aim[0]^2 + self.aim[1]^2) * mathUtil.distance(oldTail, newHead))
		if cosAngBetween < 0.8 then
			// blocked!
			shot.die
			return
		end if
	end if
	self.die
	if not shot.powershot then shot.die
end function

Player.die = function
	if self.dying then return // too late, already dying
	self.dying = true
	self.disabled = true
	self.powerShot = false
	self.tripleShot = false
	self.hasShield = false
	self.dieTimeLeft = 2
	self.deathPosition = [self.x, self.y]
	sounds.ElectricZap.playAt self
end function

Player.doDeathAnimation = function(dt)
	self.x = self.deathPosition[0] + mathUtil.randRange(-5, 5)
	self.y = self.deathPosition[1] + mathUtil.randRange(-5, 5)
	self.image = images.playerHit.any
	self.dieTimeLeft = self.dieTimeLeft - dt
	if self.dieTimeLeft < 0 then
		self.dying = false
		self.dead = true
		self.x = -999
	end if
end function

if locals == globals then
	clear
	p = new Player
	p.x = 480
	p.y = 320
	p.inputs = inputs.inputsForPlayer(0)
	displays.action.sprites.push p
	while true
		yield
		for sp in displays.action.sprites
			sp.update
		end for
	end while

end if