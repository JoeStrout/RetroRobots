// This module defines the powerups players may have.


PowerupSprite = new UpdatableSprite
PowerupSprite.powerup = null
PowerupSprite.localBounds = new Bounds
PowerupSprite.localBounds.width = images.powerup[0].width
PowerupSprite.localBounds.height = images.powerup[0].height
PowerupSprite.init = function
	super.init
	displays.action.sprites.push self
end function
PowerupSprite.die = function
	super.die
	displays.action.sprites.removeVal self
end function

PowerupSprite.update = function(dt)
	for p in players
		if p.overlaps(self) then
			p.awardPowerup self.powerup
			self.die
			return
		end if
	end for
end function


Powerup = {}
Powerup.image = null
Powerup.icon = null
Powerup.makeSprite = function
	result = new PowerupSprite
	result.powerup = self
	result.image = self.image
	result.init
	return result
end function

OneUp = new Powerup
OneUp.image = images.powerup[0]

DoubleScore = new Powerup
DoubleScore.image = images.powerup[1]
DoubleScore.icon = images.powerupIcon[1]

PowerShot = new Powerup
PowerShot.image = images.powerup[2]
PowerShot.icon = images.powerupIcon[2]

Shield = new Powerup
Shield.image = images.powerup[3]
Shield.icon = images.powerupIcon[3]

TripleShot = new Powerup
TripleShot.image = images.powerup[4]
TripleShot.icon = images.powerupIcon[4]

Bounce = new Powerup
Bounce.image = images.powerup[5]
Bounce.icon = images.powerupIcon[5]

all = [OneUp, DoubleScore, PowerShot, Shield, TripleShot, Bounce]
for i in all.indexes
	all[i].sortOrder = i
end for

// Pick a random powerup that isn't something both players
// already have.
pickAvailable = function
	for tries in range(9)
		choice = all.any
		for p in players
			if not p.hasPowerup(choice) then return choice
		end for
	end for
	// couldn't find any?  Return OneUp.
	return OneUp
end function

