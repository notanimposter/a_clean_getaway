Map = class ()

function Map:init (spritesheet, tileset, tiledata, width, height)
	self.spritesheet = spritesheet
	self.tileset = tileset
	self.tiledata = tiledata
	self.width = width
	self.height = height
end

function Map:isWalkableAt (x, y)
	if x < 0 or x > self.width or y < 0 or y > self.height then
		return false
	end
	return self.tileset[self.tiledata[1+y*self.width*2 + x*2]].walkable
end

function Map:getTile (x, y)
	return self.tiledata[1+y*self.width*2 + x*2]
end
function Map:replaceTile (x, y, id)
	self.tiledata[1+y*self.width*2 + x*2] = id
end

function Map:update (dt)
	
end

function Map:draw ()
	for x=0,self.width-1 do
		for y=0,self.height-1 do
			love.graphics.push ()
				love.graphics.translate (x * 16+8, y * 16+8)
				love.graphics.draw (self.spritesheet, self.tileset[self.tiledata[1+y*self.width*2 + x*2]].quad, 0, 0, math.pi/2 * self.tiledata[2+y*self.width*2 + x*2], 1, 1, 8, 8)
			love.graphics.pop ()
		end
	end
end
