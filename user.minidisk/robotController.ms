// Controller for each of the evil robots.

import "mathUtil"
if locals == globals then
	import "images"
end if

levelColors = ["#7FFF7F","#6666FF","#CCCC33","#990000","#990000"]

Robot = new Sprite
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

Robot.make = function(level=0)
	noob = new Robot
	noob.level = level
	noob.tint = levelColors[level]
	noob.nextActionTime = time + mathUtil.randRange(1.5, 5)
	return noob
end function

Robot.update = function(dt=0.0167)
	if time > self.nextFrameTime then
		self.curFrame = (self.curFrame + 1) % self.animFrames.len
		self.image = self.animFrames[self.curFrame]
		self.nextFrameTime = time + 1/self.frameRate
	end if
	
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
	// Show in the player's general direction
	print "Pew!"
end function

Robot.startWalk = function
	// Test each of the eight directions; pick the one that gets
	// us closest to the player, and doesn't intersect a wall
	// any time soon.
	playerPos = self.closestPlayer
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
				hitsWall = false		// ToDo
				if not hitsWall then
					bestDx = dx
					bestDy = dy
					bestDistToPlayer = dist
				end if
			end if
		end for
	end for
	
	print "Best direction: " + bestDx + "," + bestDy
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
	self.x = self.x + self.walkDirection.x * self.walkSpeed * dt
	self.y = self.y + self.walkDirection.y * self.walkSpeed * dt

end function

Robot.closestPlayer = function
	// Return the closest player on the screen.
	// HACK for now:
	return mouse
end function

if locals == globals then
	clear
	bot = Robot.make(1)
	bot.x = 480
	bot.y = 320
	display(4).sprites.push bot
	while true
		yield
		bot.update
	end while
end if