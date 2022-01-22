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

Room = {}
Room.x = 0
Room.y = 0

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
		bot.x = self.x + round(x); bot.y = self.y + round(y)
		self.robots.push bot
	end for
end function

Room.isOutOfBounds = function(xyPos)
	return xyPos.x < self.x or xyPos.x > self.x + kWidth or
	  xyPos.y < self.y or xyPos.y > self.y + kHeight
end function

Room.lineSegmentHitsWall = function(endA, endB)
	for wall in self.walls
		if wall.worldBounds.overlapsLineSegment(endA, endB) then return true
	end for
	return false
end function

Room.botHitByLineSegment = function(endA, endB)
	for bot in self.robots
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
			self.robots[i].die
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