// This module provides images from our asset files.

spriteSheet = file.loadImage("/usr/pics/spriteTexMap.png")
playerStanding = spriteSheet.getImage(0,192, 32,64)
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
	botIdle.push spriteSheet.getImage(48*i,138, 48,48)
end for
botWalkDown = []
botWalkDown.push spriteSheet.getImage(48*0,90, 48,48)
botWalkDown.push spriteSheet.getImage(48*1,90, 48,48)
botWalkUp = []
botWalkUp.push spriteSheet.getImage(48*2,90, 48,48)
botWalkUp.push spriteSheet.getImage(48*3,90, 48,48)
botFaceRight = spriteSheet.getImage(48*4,90, 48,48)
botWalkRight = []
botWalkRight.push spriteSheet.getImage(48*5,90, 48,48)
botWalkRight.push spriteSheet.getImage(48*6,90, 48,48)
