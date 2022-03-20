import "bmfFonts"

bmfFonts.Font.center = function(s, midX=480, y=320, scale=1, tint="#FFFFFF")
	x = midX - self.width(s, scale)/2
	self.print s, x, y, scale, tint
end function

bmfFonts.Font.rightAlign = function(s, rightX=480, y=320, scale=1)
	x = rightX - self.width(s, scale)
	self.print s, x, y, scale
end function

globals.font = bmfFonts.Font.load("fonts/robocop+.bmf")
