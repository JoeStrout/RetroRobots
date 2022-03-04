bigMapImg = file.loadImage("pics/Title.png")

clear
sprites = display(4).sprites
sections = 12
secW = bigMapImg.width / sections
rings = 8
ringH = bigMapImg.height / rings
R = 200  // globe radius
for j in range(0, rings-1)
	for i in range(0, sections-1)
		sp = new Sprite
		sp.image = bigMapImg.getImage(i*secW, j*ringH, secW, ringH)
		yangBot = (10 + 160/rings * j) * pi/180
		yangTop = (10 + 160/rings * (j+1)) * pi/180
		sp.yBot = 440 - R * cos(yangBot)
		sp.yTop = 440 - R * cos(yangTop)
		sp.rBot = R * sin(yangBot) // radius at bottom
		sp.rTop = R * sin(yangTop) // radius at top
		sp.x = 480; sp.y = (sp.yBot + sp.yTop)/2
		sp.angLeft = i * 2*pi/sections
		sp.angRight = (i+1) * 2*pi/sections
		sprites.push sp
	end for
	
end for

positionSprites = function(rotDegrees)
	dang = rotDegrees * pi/180
	for sp in sprites
		corners = []
		corners.push [480+sp.rBot*cos(sp.angLeft+dang), sp.yBot]
		corners.push [480+sp.rBot*cos(sp.angRight+dang), sp.yBot]
		corners.push [480+sp.rTop*cos(sp.angRight+dang), sp.yTop]
		corners.push [480+sp.rTop*cos(sp.angLeft+dang), sp.yTop]
		sp.setCorners  corners
		sp.sortOrder = sin((sp.angLeft + sp.angRight)/2 + dang)
		if corners[1][0] > corners[0][0] then
			sp.tint = color.white
		else
			sp.tint = "#AAAAAA44"
		end if
	end for	
	sprites.sort "sortOrder", false
end function

rot = 0
while true
	yield
	positionSprites rot
	rot = (rot + 358) % 360
end while

