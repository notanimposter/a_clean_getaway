
Vacuum = class ()
function Vacuum:init (x, y)
	self.x = x
	self.y = y
	self.sprite = love.graphics.newImage ("assets/vacuum.png")
	self.eye_quads = {}
	self.eye_sprites = love.graphics.newImage ("assets/eyes.png")
	self.eye_quads.background = love.graphics.newQuad (0, 0, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.top_left = love.graphics.newQuad (3, 0, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.top = love.graphics.newQuad (0, 7, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.top_right = love.graphics.newQuad (3, 7, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.middle = love.graphics.newQuad (0, 14, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.bottom_left = love.graphics.newQuad (3, 14, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.bottom = love.graphics.newQuad (0, 21, 3, 7, self.eye_sprites:getDimensions())
	self.eye_quads.bottom_right = love.graphics.newQuad (3, 21, 3, 7, self.eye_sprites:getDimensions())
	self.expressions = {
		idle = {{'top', 'middle', 'bottom', 'bottom_left', 'bottom_right'}},
		sleep1 = {{'top'}},
		sleep2 = {{'middle'}},
		sleep3 = {{'bottom'}},
		sleep4 = {{'middle'}},
		happy = {{'top', 'top_left', 'top_right'}},
		ded = {{'middle', 'top_left', 'top_right', 'bottom_left', 'bottom_right'}},
	}
	self.left_eye = {}
	self.right_eye = {}
	self:setExpression ("sleep1")
	self.animation_timer = 0.5
end

function Vacuum:setExpression (exp)
	self.expression = exp
	self.left_eye = self.expressions[exp][1]
	self.right_eye = self.expressions[exp][2] or self.expressions[exp][1]
end

function Vacuum:update (dt)
	if self.animation_timer > 0 then
		self.animation_timer = math.max (self.animation_timer - dt, 0)
	else
		local anim, frame = self.expression:match("^(.-)(%d*)$")
		if frame ~= '' then
			frame = tonumber(frame)
			if self.animation_timer == 0 then
				frame = frame + 1
			end
			if anim == "sleep" and frame > 4 then
				frame = 1
			elseif anim == "boot" and frame > 8 then
				frame = 1
			end
			self.animation_timer = 0.5
			self:setExpression (anim..frame)
		end
	end
end


function Vacuum:draw ()
	love.graphics.push ()
		love.graphics.translate (self.x*16, self.y*16)
		love.graphics.draw (self.sprite, 0, 0)
		love.graphics.draw (self.eye_sprites, self.eye_quads.background, 4, 3)
		for i,v in ipairs (self.left_eye) do
			love.graphics.draw (self.eye_sprites, self.eye_quads[v], 4, 3)
		end
		love.graphics.draw (self.eye_sprites, self.eye_quads.background, 9, 3)
		for i,v in ipairs (self.right_eye) do
			love.graphics.draw (self.eye_sprites, self.eye_quads[v], 9, 3)
		end
	love.graphics.pop ()
end
