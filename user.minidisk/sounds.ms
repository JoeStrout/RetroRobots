

SoundSubclass = new Sound
SoundSubclass.volume = 1
SoundSubclass.pitchVariation = 0

SoundSubclass.playAt = function(xOrMap,y)
	if xOrMap isa map then
		x = xOrMap.x
	else
		x = xOrMap
	end if
	
	pan = (x-480)/480
	speed = 1
	if self.pitchVariation then
		speed = 1 + self.pitchVariation * 2 * rnd - self.pitchVariation
	end if
	self.play self.volume, pan, speed
end function

SoundSubclass.playAfterDelay = function(delay=0.5, pitch=1)
	delayedSound = new DelayedSoundPlayer
	delayedSound.init
	delayedSound.playTime = time + delay
	delayedSound.sound = self
	delayedSound.pitch = pitch
end function

DelayedSoundPlayer = new updatable.Updatable
DelayedSoundPlayer.playTime = 0
DelayedSoundPlayer.sound = null
DelayedSoundPlayer.update = function(dt=0.016)
	if time > self.playTime then
		self.sound.play 1, 0, self.pitch
		self.die
	end if
end function

loadAll = function
	for f in file.children("sounds")
		if f[-4:] != ".wav" then continue
		s = file.loadSound("sounds/" + f)
		if s == null then continue
		s.__isa = SoundSubclass
		name = f - ".wav"
		outer[name] = s
	end for
	
	// custom tweaking:
	PlayerShot.pitchVariation = 0.05
	BotShot.pitchVariation = 0.1
	BotDie.volume = 0.7
	BotDie.pitchVariation = 0.1
end function