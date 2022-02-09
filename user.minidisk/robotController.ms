// Controller for each of the evil robots.

if not globals.hasIndex("mathUtil") then import "mathUtil"
if not globals.hasIndex("listUtil") then import "listUtil"
if not globals.hasIndex("images") then import "images"
if not globals.hasIndex("updatable") then import "updatable"

robotDisplayNum = 4

levelColors = ["#7FFF7F","#88AAFF","#CCCC33","#990000","#990000"]

Robot = new UpdatableSprite
Robot.walkSpeed = 64
Robot.level = 0
Robot.isArmored = false
Robot.image = images.botIdle[0]
Robot.walking = false
Robot.animFrames = images.botIdle
Robot.curFrame = 0
Robot.nextFrameTime = 0
Robot.nextActionTime = 0
Robot.frameRate = 16		// frames per second
Robot.isDead = false
Robot.localBounds = new Bounds
Robot.localBounds.width = 25
Robot.localBounds.height = 38

Robot.make = function(level=0)
	noob = new Robot
	noob.init
	noob.level = level
	noob.tint = levelColors[level]
	noob.nextActionTime = time + mathUtil.randRange(1.5, 5)
	display(robotDisplayNum).sprites.push noob
	return noob
end function

Robot.die = function(room)
	if room == null then room = curRoom
	super.die
	display(robotDisplayNum).sprites.removeVal self
	room.robots.removeVal self
	if room == curRoom and not curRoom.robots then
		curRoom.awardRoomBonus
	end if
end function

Robot.update = function(dt=0.0167)
	if time > self.nextFrameTime then
		if self.isDead and self.curFrame == self.animFrames.len-1 then
			self.die
			return
		end if
		self.curFrame = (self.curFrame + 1) % self.animFrames.len
		self.image = self.animFrames[self.curFrame]
		self.nextFrameTime = time + 1/self.frameRate
	end if
	
	if self.isDead then return
	
	if self.walking then self.continueWalk dt
	if time > self.nextActionTime and (not self.walking or self.level > 1) then
		self.act
	end if
end function

Robot.act = function
	// Either start walking towards the player, or shoot.
	if rnd < 0.5 and self.level > 0 then self.fire else self.startWalk
	
	if self.level < 2 then
		self.nextActionTime = time + mathUtil.randRange(1.5, 5)
	else
		self.nextActionTime = time + mathUtil.randRange(0.5, 1.5)
	end if
end function

Robot.fire = function
	// Shoot in the player's general direction
	player = self.closestPlayer
	if not player then return
	angle = atan(player.y - self.y, player.x - self.x) * 180/pi
	angle = round(angle / 45) * 45
	
	shot = new shotController.Shot
	shot.init self
	shot.x = self.x + cos(angle * pi/180) * 20
	shot.y = self.y + sin(angle * pi/180) * 20
	shot.rotation = angle
	shot.tint = self.tint
	if self.level > 2 then shot.speed = 1000 else shot.speed = 400
	displays.action.sprites.push shot
end function

Robot.explode = function
	if self.isDead then return
	self.isDead = true
	self.animFrames = images.botBoom
	self.curFrame = -1
	self.frameRate = 16
	self.nextFrameTime = time
end function

Robot.startWalk = function
	// Test each of the eight directions; pick the one that gets
	// us closest to the player, and doesn't intersect a wall
	// any time soon.
	playerPos = self.closestPlayer
	if not playerPos then return
	bestDx = 0; bestDy = 0
	bestDistToPlayer = mathUtil.distance(playerPos, self) - 5
	for dx in range(-1, 1)
		for dy in range(-1, 1)
			if not dx and not dy then continue
			endPos = {"x":self.x + dx*200, "y":self.y + dy*200}
			t = mathUtil.proportionAlongLine(self, endPos, playerPos)
			if t < 0 then continue
			dist = mathUtil.distanceToLine(self, endPos, playerPos)
			if dist < bestDistToPlayer then
				// This looks like a good direction...
				// but does it hit a wall?
				hitsWall = curRoom.lineSegmentHitsWall(self,
					[self.x + dx*200, self.y + dy*200])
				hitsWall = false  // HACK!
				if not hitsWall then
					bestDx = dx
					bestDy = dy
					bestDistToPlayer = dist
				end if
			end if
		end for
	end for
	
	if not bestDx and not bestDy then return // couldn't find ANY direction to walk
	
	self.walkDirection = {"x":bestDx, "y":bestDy}
	
	self.scale = [1,1]
	if bestDy < 0 then		// face down
		self.animFrames = images.botWalkDown
	else if bestDy > 0 then	// face up
		self.animFrames = images.botWalkUp
	else if bestDx < 0 then	// face left
		self.animFrames = images.botWalkRight
		self.scale = [-1,1]
	else					// face right
		self.animFrames = images.botWalkRight
	end if
	self.frameRate = 4
	self.walking = true
end function

Robot.continueWalk = function(dt)
	// First, check to see if we need to keep walking...
	// stop when we would go past the player
	player = self.closestPlayer
	walkDir = self.walkDirection
	stop = not player
	if player then
		if walkDir.x < 0 and self.x <= player.x then stop = true
		if walkDir.y < 0 and self.y <= player.y then stop = true
		if walkDir.x > 0 and self.x >= player.x then stop = true
		if walkDir.y > 0 and self.y >= player.y then stop = true
	end if
	
	// Also stop when we're about to hit a wall
	if curRoom.lineSegmentHitsWall(self, 
		[self.x + walkDir.x * 50, self.y + walkDir.y * 50]) then stop = true
	
	if stop then
		self.walking = false
		if self.level < 2 then
			self.nextActionTime = time + mathUtil.randRange(0.25, 2)
		else
			self.nextActionTime = time + mathUtil.randRange(0.1, 1)
		end if
		self.animFrames = images.botIdle
		self.frameRate = 16
	else
		self.x = self.x + walkDir.x * self.walkSpeed * dt
		self.y = self.y + walkDir.y * self.walkSpeed * dt
		
		// Check for collisions
		for sp in curRoom.robots + curRoom.walls
			if sp == self then continue
			if sp.overlaps(self) then
				if sp isa Robot then
					if sp.isDead then continue
					sp.explode
				end if
				self.explode
				return
			end if
		end for
		
		for p in players
			if p.overlaps(self) then
				if not p.dying then p.die
				self.explode
			end if
		end for
	end if
	
end function

Robot.closestPlayer = function
	// Return the closest non-disabled player on the screen.
	if not globals.hasIndex("players") then return mouse	// TEST HACK
	result = null
	for p in players
		if p.disabled then continue
		if not result or mathUtil.distance(p, self) < mathUtil.distance(result, self) then
			result = p
		end if
	end for
	return result
end function

if locals == globals then
	clear
	bot = Robot.make(1)
	bot.x = 480
	bot.y = 320
	while true
		yield
		bot.update
	end while
end if