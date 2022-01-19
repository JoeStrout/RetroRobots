// Controls shots from both players and bots.

import "listUtil"
import "mathUtil"
if locals == globals then
	import "images"
end if

Shot = new Sprite
Shot.image = images.shot
Shot.dx = null	// set on first update, based on rotation
Shot.dy = null
Shot.speed = 1000			// (pixels/sec)

Shot.update = function(dt=0.0167)
	if self.dx == null then
		ang = self.rotation * pi/180
		self.dx = cos(ang)
		self.dy = sin(ang)
	end if
	
	// remember old tail position (for collision detection)
	halfLen = self.image.width / 2
	oldTailX = self.x - halfLen * self.dx
	oldTailY = self.y + halfLen * self.dy
	
	// move forward
	self.x = self.x + self.speed * self.dx * dt
	self.y = self.y + self.speed * self.dy * dt
	
	// check whether we've hit something
	// ToDo!
	
	// check whether we're out of bounds
	if self.x < -40 or self.x > 1000 or self.y < -40 or self.y > 680 then
		self.die
	end if
end function

Shot.die = function
	display(4).sprites.removeVal self
end function

if locals == globals then
	sh = new Shot
	sh.x = 200
	sh.y = 100
	sh.rotation = 30
	display(4).sprites.push sh
	while display(4).sprites.indexOf(sh) != null
		sh.update
		yield
	end while
end if