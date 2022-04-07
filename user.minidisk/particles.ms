// This module manages "particle effects", i.e. little showers of sprites.

if not globals.hasIndex("images") then import "images"
if not globals.hasIndex("updatable") then import "updatable"

Particle = new UpdatableSprite
Particle.image = images.debris
Particle.tint = color.yellow
Particle.init = function
	super.init
	radians = rnd * 2 * pi
	speed = 10 + 50*rnd
	self.vx = cos(radians) * speed
	self.vy = sin(radians) * speed + 100 * rnd
	self.rotation = 360 * rnd
	self.startTime = time - rnd*0.25
	displays.action.sprites.push self
	self.startTint = self.tint
end function
Particle.die = function
	super.die
	displays.action.sprites.removeVal self
end function

Particle.update = function(dt)
	self.vy = self.vy - 150*dt
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
	age = time - self.startTime
	if age > 1 then
		self.tint = color.lerp(self.startTint, color.clear, (age - 1)*2)
		if age > 1.5 then self.die
	end if
	//gfx.setPixel self.x, self.y, color.gray
end function

makeBurst = function(posXY, particleCount = 100)
	for i in range(particleCount-1)
		p = new Particle
		p.init
		p.x = posXY.x
		p.y = posXY.y
		p.update 0.2
	end for
end function

if locals == globals then
	clear
	displays = {}
	displays.action = display(4)
	makeBurst mouse
	t0 = time
	while time < t0 + 1.5
		updatable.update
		yield
	end while
end if

