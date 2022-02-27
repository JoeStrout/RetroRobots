// This script controls Evil Botto, who is delighted to ruin your day.

if not globals.hasIndex("mathUtil") then import "mathUtil"
if not globals.hasIndex("listUtil") then import "listUtil"
if not globals.hasIndex("images") then import "images"
if not globals.hasIndex("updatable") then import "updatable"

bottoDisplayNum = 4

Botto = new UpdatableSprite
Botto.image = images.botto
Botto.floorPos = {"x":0, "y":0}
Botto.bounceHeight = 100	// bounce height, in pixels
Botto.bouncePeriod = 1.5	// time per bounce, in seconds
Botto.floorSpeed = 90		// how fast the floor position moves (pixels/sec)
Botto.hyper = false			// whether Botto has gone into "hyper" mode
Botto.active = false
Botto.localBounds = new Bounds
Botto.localBounds.width = Botto.image.width
Botto.localBounds.height = Botto.image.height

Botto.activate = function(x=null, y=null)
	if x != null then
		self.x = x
		self.floorPos.x = x
	end if
	if y != null then
		self.y = y
		self.floorPos.y = y
	end if
	self.setSpeed false
	display(bottoDisplayNum).sprites.push self
	self.active = true
end function

Botto.deactivate = function
	display(bottoDisplayNum).sprites.removeVal self
	self.active = false
end function

Botto.explode = function
	// ToDo: explosion animation
	sounds.BottoDie.playAt self
	self.deactivate
end function

Botto.setSpeed = function(hyper=false)
	self.hyper = hyper
	if hyper then
		self.bouncePeriod = 0.5
		self.floorSpeed = 128
	else
		self.bouncePeriod = 1.5
		self.floorSpeed = 80
	end if
end function

Botto.update = function(dt=0.0167)
	if not self.active then return
	if curRoom and not curRoom.robots.len then self.setSpeed true
	
	target = self.target
	if target and not movingToNextRoom then
		// move the floor position towards the player
		mathUtil.moveTowardsXY(self.floorPos, target, self.floorSpeed * dt)
	end if

	// move the sprite
	self.x = self.floorPos.x
	self.y = self.floorPos.y + self.bounceHeight * abs(sin(pi * time / self.bouncePeriod))

	// check for collisions
	if curRoom != null then
		for b in curRoom.robots
			if not b.isDead and b.overlaps(self) then
				b.explode
				break
			end if
		end for
	end if
	for p in players
		if p.overlaps(self) then p.die
	end for
end function

Botto.shift = function(dx, dy)
	self.x = self.x + dx
	self.y = self.y + dy
	self.floorPos.x = self.floorPos.x + dx
	self.floorPos.y = self.floorPos.y + dy
end function

Botto.jumpTo = function(x, y)
	self.x = x
	self.y = y
	self.floorPos.x = x
	self.floorPos.y = y
end function

Botto.target = function
	// pick the closest active player
	if players.len == 1 then return player
	result = null
	bestDist = 0
	for p in players
		if p.disabled or p.dead then continue
		dist = mathUtil.distance(self, p)
		if result == null or dist < bestDist then
			result = p
			bestDist = dist
		end if
	end for
	return result
end function

if locals == globals then
	clear
	curRoom = null
	movingToNextRoom = false
	Botto.target = @mouse
	players = []
	Botto.appear
	while true
		yield
		Botto.update
	end while
end if