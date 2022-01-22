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

Shot.init = function(shooter)
	super.init
	self.ignore = shooter
	self.x = shooter.x
	self.y = shooter.y
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
		if curRoom.lineSegmentHitsWall(oldTail, newHead) then
			self.die
			return
		end if
		bot = curRoom.botHitByLineSegment(oldTail, newHead)
		if bot and bot != self.ignore then
			bot.explode
			self.die	// ToDo: unless powershot!
		end if
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