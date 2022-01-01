// Manages room appearance and sounds.

import "mazeGenerator"

wallDisplayNum = 4

kScorebarHeight = 32
kWidth = 960
kHeight = 640 - kScorebarHeight

kWallThickness = 16

Wall = new Sprite
Wall.image = file.loadImage("/sys/pics/shapes/Square.png")

Room = {}
Room.x = 0
Room.y = 0

Room.createWalls = function
	self.walls = []
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
	display(wallDisplayNum).sprites.push wall
	return wall
end function

Room.newVerticalWall = function(col, row)
	wall = new Wall
	w = kWallThickness
	h = kHeight / mazeGenerator.kRows + kWallThickness
	wall.scale = [w / wall.image.width, h / wall.image.height]
	wall.x = self.x + col * kWidth / mazeGenerator.kCols
	wall.y = self.y + (row + 0.5) * kHeight / mazeGenerator.kRows
	display(wallDisplayNum).sprites.push wall
	return wall
end function


if locals == globals then
	display(wallDisplayNum).clear
	r = new Room
	r.createWalls
end if