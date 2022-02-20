// Manages room appearance and sounds.

import "mazeGenerator"
if not globals.hasIndex("displays") then import "displays"
if not globals.hasIndex("mathUtil") then import "mathUtil"
if not globals.hasIndex("listUtil") then import "listUtil"
if not globals.hasIndex("robotController") then import "robotController"

kScorebarHeight = 32
kWidth = 960
kHeight = 640 - kScorebarHeight

kWallThickness = 16

Wall = new Sprite
Wall.image = file.loadImage("/sys/pics/shapes/Square.png")
Wall.localBounds = new Bounds
Wall.localBounds.width = Wall.image.width
Wall.localBounds.height = Wall.image.height

DoorMover = new updatable.Updatable
DoorMover.speed = 100  // (pixels/sec)
DoorMover.init = function(wall, delta, delay=1)
	super.init
	self.wall = wall
	self.delta = delta
	self.wall.x = self.wall.x + delta[0]
	self.wall.y = self.wall.y + delta[1]
	self.startTime = time + delay
end function
DoorMover.update = function(dt)
	if time < self.startTime then return
	d = dt * self.speed
	if d > abs(self.delta[0]) and d > abs(self.delta[1]) then
		self.wall.x = self.wall.x - self.delta[0]
		self.wall.y = self.wall.y - self.delta[1]
		self.die
	else
		dx = -d * sign(self.delta[0])
		dy = -d * sign(self.delta[1])
		self.wall.x = self.wall.x + dx
		self.wall.y = self.wall.y + dy
		self.delta[0] = self.delta[0] + dx
		self.delta[1] = self.delta[1] + dy
	end if		
end function

Room = {}
Room.x = 0
Room.y = 0
Room.allBotsBonus = 0
Room.chicken = false

Room.createWalls = function
	self.walls = []
	self.robots = []
	mazeGenerator.generate
	
	// Create the vertical walls
	for j in range(0, mazeGenerator.kRows-1)
		for i in range(0, mazeGenerator.kCols)
			if self.shouldHaveWall(i, j, false) then
				self.walls.push self.newVerticalWall(i, j)
			end if
		end for
	end for
	
	// Create the horizontal walls
	for j in range(0, mazeGenerator.kRows)
		for i in range(0, mazeGenerator.kCols-1)
			if self.shouldHaveWall(i, j, true) then
				self.walls.push self.newHorizontalWall(i, j)
			end if
		end for
	end for	
end function

Room.shouldHaveWall = function(col, row, horizontal)
	// Determine whether we should have the indicated wall in this room.
	
	// Outer walls should always be there, except for the middle
	// (which is the doorway to the next room).
	if not horizontal and (col == 0 or col == mazeGenerator.kCols) then
		return row != floor(mazeGenerator.kRows/2)
	end if
	if horizontal and (row == 0 or row == mazeGenerator.kRows) then
		return col != floor(mazeGenerator.kCols/2)
	end if
	
	// Otherwise, ask the maze generator.
	return mazeGenerator.shouldHaveWall(col, row, horizontal)
end function

Room.newHorizontalWall = function(col, row)
	wall = new Wall
	w = kWidth / mazeGenerator.kCols + kWallThickness
	h = kWallThickness
	wall.scale = [w / wall.image.width, h / wall.image.height]
	wall.x = self.x + (col + 0.5) * kWidth / mazeGenerator.kCols
	wall.y = self.y + row * kHeight / mazeGenerator.kRows
	displays.wall.sprites.push wall
	return wall
end function

Room.newVerticalWall = function(col, row)
	wall = new Wall
	w = kWallThickness
	h = kHeight / mazeGenerator.kRows + kWallThickness
	wall.scale = [w / wall.image.width, h / wall.image.height]
	wall.x = self.x + col * kWidth / mazeGenerator.kCols
	wall.y = self.y + (row + 0.5) * kHeight / mazeGenerator.kRows
	displays.wall.sprites.push wall
	return wall
end function

// Assume the player is entering the room at entryPos.
// Prepare a door, to be activated later, after the
// room shift is complete.
Room.prepareDoors = function(entryPos)
	if entryPos.x < self.x + 100 then
		door = self.newVerticalWall(0, floor(mazeGenerator.kRows/2))
		door2 = self.newVerticalWall(0,floor(mazeGenerator.kRows/2))
		startDir = [0, door.image.height * door.scale[1]]
	else if entryPos.x > self.x + kWidth - 100 then
		door = self.newVerticalWall(mazeGenerator.kCols,floor(mazeGenerator.kRows/2))
		door2 = self.newVerticalWall(mazeGenerator.kCols,floor(mazeGenerator.kRows/2))
		startDir = [0, -door.image.height * door.scale[1]]
	else if entryPos.y < self.y + 100 then
		door = self.newHorizontalWall(floor(mazeGenerator.kCols/2), 0)
		door2 = self.newHorizontalWall(floor(mazeGenerator.kCols/2), 0)
		startDir = [door.image.width * door.scale[0], 0]
	else
		door = self.newHorizontalWall(floor(mazeGenerator.kCols/2), mazeGenerator.kRows)
		door2 = self.newHorizontalWall(floor(mazeGenerator.kCols/2), mazeGenerator.kRows)
		startDir = [-door.image.width * door.scale[0], 0]
	end if
	
	self.walls.push door
	self.walls.push door2

	// Move the doors to their "open" position, then set them to move
	// back to the closed position after a delay.
	mover = new DoorMover
	mover.init door, startDir
	mover2 = new DoorMover
	mover2.init door2, [-startDir[0], -startDir[1]]
end function

Room.createRobots = function(botLevel=0)
	self.robots = []
	// Start by making a list of all the sub-rooms, then shuffling that list.
	subrooms = []
	for col in range(0, mazeGenerator.kCols-1)
		for row in range(0, mazeGenerator.kRows-1)
			subrooms.push [col,row]
		end for
	end for
	subrooms.shuffle
	
	// Then, pick a reasonable number of bots, and place each one in
	// a subroom drawn from the list.
	qtyBots = floor(rnd*5 + 5)
	w = kWidth / mazeGenerator.kCols
	h = kHeight / mazeGenerator.kRows
	for i in range(0, qtyBots-1)
		colRow = subrooms[i % subrooms.len]
		col = colRow[0]; row = colRow[1]
		x = w * (col + 0.5) + w * mathUtil.randRange(-0.35, 0.35)
		y = h * (row + 0.5) + h * mathUtil.randRange(-0.3, 0.3)
		bot = robotController.Robot.make(botLevel)
		bot.positionAt self.x + x, self.y + y
		self.robots.push bot
	end for
	
	self.allBotsBonus = self.robots.len * constants.bonusPerRobot
end function

Room.clearRobotsNearPlayer = function
	for p in players
		if p.dead then continue
		
		for i in range(self.robots.len - 1)
			dist = mathUtil.distance(self.robots[i], p)
			if dist < 200 then self.robots[i].die self
		end for		
	end for
	self.allBotsBonus = self.robots.len * constants.bonusPerRobot
end function

Room.playIntroSounds = function(pitch=0, delay=0)
	if pitch == 0 then
		// pick a random pitch
		if rnd < 0.25 then
			pitch = 0.9
		else if rnd < 0.25 then
			pitch = 1.1
		else
			pitch = 1
		end if
	end if
	
	if rnd < 0.3 then
		sounds.VoiceThe.playAfterDelay delay, pitch
		self.randomEpithet.playAfterDelay delay + 0.25, pitch
		sounds.VoiceMustNotEscape.playAfterDelay delay + 0.9, pitch
	else
		sounds.VoiceGetThe.playAfterDelay delay, pitch
		self.randomEpithet.playAfterDelay delay + 0.45, pitch
	end if
	
	if pitch < 1.1 and rnd < 0.9 then
		self.playIntroSounds pitch + 0.1, delay + 1.5
	end if
end function

Room.randomEpithet = function
	if self.chicken and rnd < 0.5 then
		return sounds.VoiceChicken
	else if rnd < 0.5 then
		return sounds.VoiceIntruder
	else
		return sounds.VoiceHumanoid
	end if
end function

Room.playChickenTaunt = function
	sounds.VoiceChicken.play
	if rnd < 0.5 then
		sounds.VoiceBokBok.playAfterDelay 0.7
	else
		sounds.VoiceFightLikeRobot.playAfterDelay 0.7
	end if
	Room.chicken = true
end function

Room.awardRoomBonus = function
	for p in players
		p.addToScore self.allBotsBonus
	end for
	self.allBotsBonus = 0
	Room.chicken = false
end function

Room.isOutOfBounds = function(xyPos, extraFar=false)
	extraX = 20 * extraFar
	extraY = 40 * extraFar
	return xyPos.x < self.x - extraX or
		   xyPos.x > self.x + kWidth + extraX or
		   xyPos.y < self.y - extraY or
		   xyPos.y > self.y + kHeight + extraY
end function

Room.lineSegmentHitsWall = function(endA, endB)
	for wall in self.walls
		if wall.worldBounds.overlapsLineSegment(endA, endB) then return true
	end for
	return false
end function

Room.botHitByLineSegment = function(endA, endB)
	for bot in self.robots
		if bot.isDead then continue
		if bot.worldBounds.overlapsLineSegment(endA, endB) then return bot
	end for
	return null
end function

Room.shift = function(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
	for wall in self.walls
		wall.x = wall.x + dx
		wall.y = wall.y + dy
	end for
	for bot in self.robots
		bot.x = bot.x + dx
		bot.y = bot.y + dy
		bot.updateArmor
	end for
end function

Room.moveTowards = function(targetX, targetY, maxShift=10)
	newX = mathUtil.moveTowards(self.x, targetX, maxShift)
	newY = mathUtil.moveTowards(self.y, targetY, maxShift)
	delta = {"x":newX - self.x, "y":newY - self.y};
	self.shift delta.x, delta.y
	return delta
end function

Room.close = function
	for wall in self.walls
		displays.wall.sprites.removeVal wall
	end for
	self.walls = []
	if self.robots then
		for i in range(self.robots.len - 1)
			self.robots[i].die self
		end for
	end if
	self.robots = []
end function

if locals == globals then
	display(wallDisplayNum).clear
	r = new Room
	r.createWalls
	r.createRobots
end if