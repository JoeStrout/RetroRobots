// Controls shots from both players and bots.

import "listUtil"
import "mathUtil"
if not globals.hasIndex("displays") then import "displays"
if not globals.hasIndex("images") then import "images"
if not globals.hasIndex("updatable") then import "updatable"

Shot = new UpdatableSprite
Shot.image = images.shot
Shot.dx = null	// set on first update, based on rotation
Shot.dy = null
Shot.speed = 1000			// (pixels/sec)
Shot.ignore = null			// sprite to NOT hit
Shot.powershot = false
Shot.bounce = false
Shot.isBouncing = false

Shot.init = function(shooter)
	super.init
	self.ignore = shooter
	self.x = shooter.x
	self.y = shooter.y
	self.tint = shooter.tint

	if shooter isa playerController.Player then
		if shooter.hasPowerup(powerups.PowerShot) then
			self.powershot = true
			self.image = images.powershot
			self.tint = color.lerp(self.tint, color.white, 0.5)
		end if
		if shooter.hasPowerup(powerups.Bounce) then
			self.bounce = true
		end if
	end if
end function

Shot.update = function(dt=0.0167)
	if self.dx == null then
		ang = self.rotation * pi/180
		self.dx = cos(ang)
		self.dy = sin(ang)
	end if
	
	// remember old tail position (for collision detection)
	halfLen = self.image.width / 2
	oldTail = {}
	oldTail.x = self.x - halfLen * self.dx
	oldTail.y = self.y - halfLen * self.dy
	
	// move forward
	self.x = self.x + self.speed * self.dx * dt
	self.y = self.y + self.speed * self.dy * dt
	
	// check whether we've hit something
	newHead = {}
	newHead.x = self.x + halfLen * self.dx
	newHead.y = self.y + halfLen * self.dy
	if curRoom != null then
		wallHit = curRoom.lineSegmentHitsWall(oldTail, newHead)
		if wallHit and not self.isBouncing then
			if self.bounce and abs(self.dx) > 0.1 and abs(self.dy) > 0.1 then
				if wallHit.isHorizontal then
					self.dy = -self.dy
				else
					self.dx = -self.dx
				end if
				self.rotation = atan(self.dy, self.dx) * 180/pi
				self.bounce = false
				self.isBouncing = true
				sounds.bounce.playAt self
			else
				self.die
				return
			end if
		else
			self.isBouncing = false
		end if
		bot = curRoom.botHitByLineSegment(oldTail, newHead)
		if bot and bot != self.ignore then
			points = 0
			if bot.isArmored then
				bot.breakArmor
				points = constants.pointsPerArmorHit
			else
				bot.explode
				points = constants.pointsPerRobotDestroyed
			end if
			if self.ignore isa playerController.Player then
				self.ignore.addToScore points
			end if
			if not self.powershot then self.die
		end if
	end if
	if botto.active and botto.hitByLineSegment(oldTail, newHead) then
		if self.powershot then
			botto.explode
			if self.ignore isa playerController.Player then
				self.ignore.addToScore constants.pointsPerBottoDestroyed
			end if
		end if
		self.die
		return
	end if
	if not (self.ignore isa playerController.Player) then
		for p in players
			if p.hitByLineSegment(oldTail, newHead) then
				p.handleHit self, oldTail, newHead
			end if
		end for
	end if
		
	// check whether we're out of bounds
	if self.x < -40 or self.x > 1000 or self.y < -40 or self.y > 680 then
		self.die
	end if
end function

Shot.die = function
	super.die
	displays.action.sprites.removeVal self
end function

if locals == globals then
	curRoom = null
	
	sh = new Shot
	sh.x = 200
	sh.y = 100
	sh.rotation = 30
	displays.action.sprites.push sh
	while displays.action.sprites.indexOf(sh) != null
		sh.update
		yield
	end while
end if