// This module provides images from our asset files.

spriteSheet = file.loadImage("/usr/pics/spriteTexMap.png")
playerStanding = spriteSheet.getImage(0,192, 32,64)
playerLifeIcon = spriteSheet.getImage(0,192+32, 32,32)
playerHit = []
playerHit.push spriteSheet.getImage(32*1,192, 32,64)
playerHit.push spriteSheet.getImage(32*2,192, 32,64)
playerRun = []
for i in range(3,7)
	playerRun.push spriteSheet.getImage(32*i,192, 32,64)
end for
playerAimN = spriteSheet.getImage(32*8,192, 32,64)
playerAimNE = spriteSheet.getImage(32*9,192, 32,64)
playerAimE = spriteSheet.getImage(32*10,192, 32,64)
playerAimSE = spriteSheet.getImage(32*11,192, 32,64)
playerAimS = spriteSheet.getImage(32*12,192, 32,64)
playerHandsOnHips = playerAimS
playerTapping = []
playerTapping.push spriteSheet.getImage(32*13,192, 32,64)
playerTapping.push spriteSheet.getImage(32*14,192, 32,64)


botIdle = []
for i in range(0,7)
	botIdle.push spriteSheet.getImage(48*i+4,138, 48,48)
end for
botWalkDown = []
botWalkDown.push spriteSheet.getImage(48*0+4,88, 48,48)
botWalkDown.push spriteSheet.getImage(48*1+4,88, 48,48)
botWalkUp = []
botWalkUp.push spriteSheet.getImage(48*2+4,88, 48,48)
botWalkUp.push spriteSheet.getImage(48*3+4,88, 48,48)
botFaceRight = spriteSheet.getImage(48*4+4,88, 48,48)
botWalkRight = []
botWalkRight.push spriteSheet.getImage(48*5+4,88, 48,48)
botWalkRight.push spriteSheet.getImage(48*6+4,88, 48,48)

armorFront = spriteSheet.getImage(48*0+3, 55, 48, 32)
armorBack = spriteSheet.getImage(48*1+3, 55, 48, 32)
armorSide = spriteSheet.getImage(48*2+5, 55, 48, 32)
armorBoom = []
armorBoom.push spriteSheet.getImage(148, 53, 48, 35)
armorBoom.push spriteSheet.getImage(196, 53, 48, 35)

debris = spriteSheet.getImage(159, 62, 12, 10)

powerup = []
powerup.push spriteSheet.getImage(427, 32*2, 36, 32)
powerup.push spriteSheet.getImage(427, 32*1, 36, 32)
powerup.push spriteSheet.getImage(427, 32*0, 36, 32)
powerup.push spriteSheet.getImage(470, 32*2, 36, 32)
powerup.push spriteSheet.getImage(470, 32*1, 36, 32)
powerup.push spriteSheet.getImage(470, 32*0, 36, 32)
powerupIcon = []
powerupIcon.push spriteSheet.getImage(427, 32*5, 36, 32)
powerupIcon.push spriteSheet.getImage(427, 32*4, 36, 32)
powerupIcon.push spriteSheet.getImage(427, 32*3, 36, 32)
powerupIcon.push spriteSheet.getImage(470, 32*5, 36, 32)
powerupIcon.push spriteSheet.getImage(470, 32*4, 36, 32)
powerupIcon.push spriteSheet.getImage(470, 32*3, 36, 32)

shield = spriteSheet.getImage(290, 4, 63, 55)

botBoom = []
for i in range(0,3)
	botBoom.push spriteSheet.getImage(54*i, 4, 54, 56)
end for

shot = Image.create(32,8, color.white)
powershot = Image.create(34,10, color.white)

botto = spriteSheet.getImage(369, 11, 53, 54)

if locals == globals then
	clear
	for i in botBoom.indexes
		gfx.drawImage botBoom[i], 0, i*botBoom[0].height
	end for
	
	bot = new Sprite
	bot.image = botWalkRight[0]
	bot.localBounds = new Bounds
	bot.localBounds.width = 25
	bot.localBounds.height = 38
	bot.x = 480
	bot.y = 320
	displays.action.sprites.push bot
	gfx.drawPoly bot.worldBounds.corners, color.yellow
end if