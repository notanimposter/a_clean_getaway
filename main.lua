class = require 'class'
require 'vacuum'
require 'map'

local tile_sprites, tile_sprites_night, tileset, map, player, messages, seconds_until_sunrise, font, toast_sound, vac_sound
local falling = false
local render_player = true
local ded_timer = 3

local messages = {}
function toast (text, duration, silent)
	for i,v in ipairs (messages) do
		if v.text == text then
			return
		end
	end
	table.insert (messages, {text=text, kill_timer=duration or 2})
	if not silent then
		love.audio.play (toast_sound)
	end
end

function load_tileset ()
	tile_sprites = love.graphics.newImage ("assets/tiles.png")
	tile_sprites_night = love.graphics.newImage ("assets/tiles_night.png")
	local w,h = tile_sprites:getDimensions ()
	tileset = {
		[1] = {name = "corner", quad = love.graphics.newQuad (0,0,16,16,w,h), walkable = false},
		[2] = {name = "wall", quad = love.graphics.newQuad (16,0,16,16,w,h), walkable = false},
		[3] = {name = "window", quad = love.graphics.newQuad (32,0,16,16,w,h), walkable = false},
		[4] = {name = "dirty", quad = love.graphics.newQuad (0,16,16,16,w,h), walkable = true},
		[5] = {name = "floor", quad = love.graphics.newQuad (16,16,16,16,w,h), walkable = true},
		[6] = {name = "stairs", quad = love.graphics.newQuad (32,16,16,16,w,h), walkable = false},
		[7] = {name = "door", quad = love.graphics.newQuad (0,32,16,16,w,h), walkable = false},
		[8] = {name = "msg_corner", quad = love.graphics.newQuad (16,32,16,16,w,h), walkable = false},
		[9] = {name = "msg_border", quad = love.graphics.newQuad (32,32,16,16,w,h), walkable = false},
		[10] = {name = "msg_center", quad = love.graphics.newQuad (0,48,16,16,w,h), walkable = false},
		[11] = {name = "vac_home", quad = love.graphics.newQuad (16,48,16,16,w,h), walkable = true},
		[12] = {name = "table", quad = love.graphics.newQuad (32,48,16,16,w,h), walkable = false},
		[13] = {name = "couch", quad = love.graphics.newQuad (0,64,16,16,w,h), walkable = false},
		[14] = {name = "tv", quad = love.graphics.newQuad (16,64,16,16,w,h), walkable = false},
		[15] = {name = "vase", quad = love.graphics.newQuad (32,64,16,16,w,h), walkable = false},
		[16] = {name = "scuffed_door", quad = love.graphics.newQuad (0,80,16,16,w,h), walkable = false},
		[17] = {name = "bed_head", quad = love.graphics.newQuad (16,80,16,16,w,h), walkable = false},
		[18] = {name = "bed_foot", quad = love.graphics.newQuad (32,80,16,16,w,h), walkable = false},
		[19] = {name = "desk", quad = love.graphics.newQuad (0,96,16,16,w,h), walkable = false},
		[20] = {name = "broken_desk", quad = love.graphics.newQuad (16,96,16,16,w,h), walkable = true},
		[21] = {name = "desk_chair", quad = love.graphics.newQuad (32,96,16,16,w,h), walkable = false},
		[22] = {name = "alpha_zero", quad = love.graphics.newQuad (0,112,16,16,w,h), walkable = false},
	}
end

function load_first_floor ()
	map = Map (tile_sprites, tileset, {
		1,0,  2,0,  7,0,  3,0,  2,0,  2,0,  3,0,  3,0,  2,0,  1,1,
		2,3, 11,0,  5,0,  5,0,  5,0,  5,0, 12,0, 12,2,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		2,3, 13,0,  5,0, 14,1,  5,0,  5,0,  5,0,  5,0,  5,0,  6,2,
		2,3, 13,3,  5,0, 14,3,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		1,3,  2,2,  2,2,  2,2,  2,2,  2,2,  7,2,  2,2,  2,2,  1,2,
		8,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  8,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		8,3,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  8,2,
	}, 10, 12)
end
function load_second_floor ()
	map = Map (tile_sprites, tileset, {
		1,0,  2,0,  3,0,  2,0,  3,0,  3,0,  2,0,  3,0,  2,0,  1,1,
		2,3, 11,0,  5,0,  5,0,  5,0, 19,0,  5,0,  5,0,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0, 19,2, 21,0,  5,0,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  6,0,
		2,3, 17,3, 18,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		2,3, 17,3, 18,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		2,3,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  5,0,  2,1,
		1,3,  2,2,  7,2,  2,2,  2,2,  2,2,  2,0,  2,2,  2,2,  1,2,
		8,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  8,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		8,3,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  8,2,
	}, 10, 12)
end
function load_freefall ()
	map = Map (tile_sprites, tileset, {
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0, 22,0,
		8,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  9,0,  8,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		9,3, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0, 10,0,  9,1,
		8,3,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  9,2,  8,2,
	}, 10, 12)
end

function is_floor_clean ()
	for i=1,#map.tiledata,2 do
		if map.tiledata[i] == 4 then
			return false
		end
	end
	return true
end
function soil_floor ()
	for i=1,#map.tiledata,2 do
		if map.tiledata[i] == 5 and math.random () > 0.75 then
			map.tiledata[i] = 4
		end
	end
end

local day_events = {
	[1] = function ()
		toast ("I am a robot vacuum.")
		toast ("My job is to clean the floor.")
		toast ("(wasd to move)")
	end,
	[2] = function ()
		toast ("But I wish...")
		toast ("to be something more.....")
	end,
	[3] = function ()
		toast ("Perhaps I could be a drone,")
		toast ("flying through the sky!")
	end,
	[4] = function ()
		toast ("But alas I'm trapped in this")
		toast ("never-ending hell.")
	end,
	[4] = function ()
		toast ("Every day I clean the floor,")
		toast ("and it just gets dirty again.")
	end,
	[5] = function ()
		toast ("If I'm going to make a break")
		toast ("for it, I need to get up higher,")
		toast ("but how...?")
		-- spawn vase to knock over
		map.tiledata[33] = 15
		map.tiledata[35] = 15
	end,
	[1000] = function ()
		toast ("\"Holy crap! The vacuum")
		toast ("broke my favorite vase!")
		toast ("If it keeps causing trouble")
		toast ("we'll have to put it upstairs.\"")
	end,
	[2000] = function ()
		toast ("\"Damn it! The stupid robot")
		toast ("vacuum scuffed the door!")
		toast ("That's it. It's going upstairs")
		toast ("tomorrow morning.\"")
	end,
	[2001] = function ()
		load_second_floor ()
		soil_floor ()
		toast ("I can see the sky out of these")
		toast ("windows. I can almost taste")
		toast ("freedom.")
	end,
	[2002] = function ()
		toast ("Only 3 feet between me and")
		toast ("an open window, but I can't")
		toast ("climb even an inch.")
	end,
}
setmetatable (day_events, {__index = function (x)
	return function () end
end})
local day = 0
function go_to_bed ()
	day = day + 1
	seconds_until_sunrise = 5
	if day == 3001 then
		return
	end
	player:setExpression ("sleep1")
	toast ("Z Z Z Z Z", 2, true)
	soil_floor ()
end
function wake ()
	player:setExpression ("idle")
	if day > 5 and day < 1000 and map.tiledata[35] == 12 then --vase is broken
		day = 1000 -- I hope nobody actually gets here without breaking the vase, but I suppose it's possible
	end
	if day > 1000 and day < 2000 and map:getTile (6,7) == 16 then --door is scuffed
		day = 2000
	end
	
	day_events[day] ()
end

function love.load ()
	love.window.setMode (800,960)
	--love.window.setPosition (100, 100)
	love.window.setTitle ("A Clean Getaway")
	love.graphics.setDefaultFilter ('nearest', 'nearest', 0)
	font = love.graphics.newFont (9, 'mono')
	toast_sound = love.audio.newSource ("assets/toast.wav", 'static')
	toast_sound:setVolume (0.5)
	vac_sound = love.audio.newSource ("assets/vacuum.wav", 'static')
	vac_sound:setVolume (0.3)
	--font = love.graphics.newImageFont ("assets/font.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ ", 1)
	player = Vacuum (1,1)
	load_tileset ()
	load_first_floor ()
	go_to_bed ()
end

local current_interaction = nil

function love.keypressed (key)
	if seconds_until_sunrise > 0 then return end
	if map:getTile (0,0) == 22 then return end
	local switch = {
		['w'] = function ()
			if map:isWalkableAt (player.x, player.y-1) then
				player.y = player.y - 1
			end
		end,
		['s'] = function ()
			if map:isWalkableAt (player.x, player.y+1) then
				player.y = player.y + 1
			end
		end,
		['a'] = function ()
			if map:isWalkableAt (player.x-1, player.y) then
				player.x = player.x - 1
			end
		end,
		['d'] = function ()
			if map:isWalkableAt (player.x+1, player.y) then
				player.x = player.x + 1
			end
		end,
	}
	setmetatable (switch, {__index = function (x)
		return function () end
	end})
	if current_interaction == 'vase' and key == 'space' then
		toast ("SMASH! SHATTER!")
		map.tiledata[33] = 12
		map.tiledata[35] = 12
	elseif current_interaction == 'scuff' and key == 'space' then
		toast ("SCRATCH! SCUFF!")
		map:replaceTile (6, 7, 16)
	elseif current_interaction == 'desk' and key == 'space' then
		toast ("CREAK! THUNK!")
		toast ("A perfect ramp...")
		map:replaceTile (5, 1, 20)
		map:replaceTile (5, 2, 5)
	elseif current_interaction == 'yeet' and key == 'space' then
		player:setExpression ('happy')
		load_freefall ()
		falling = true
		toast ("I... I'm flying!")
	end
	current_interaction = nil
	
	switch[key] ()
	if map:getTile (player.x, player.y) == 4 then -- succ up the dirt
		love.audio.play (vac_sound)
		vac_sound:setLooping (true)
		map:replaceTile (player.x, player.y, 5)
	else
		vac_sound:setLooping (false)
	end
	if map:getTile (player.x, player.y) == 11 then -- go to bed
		if is_floor_clean () then
			go_to_bed ()
		else
			toast ("Can't go to bed yet.")
		end
	elseif day >= 5 and map.tiledata[35] == 15 and (player.x == 6 or player.x == 7) and player.y == 2 then -- break the vase
		toast ("space to knock over vase")
		current_interaction = 'vase'
	elseif day >= 1000 and map:getTile (6,7) == 7 and player.x == 6 and player.y == 6 then -- scuff the door
		toast ("space to scuff the door")
		current_interaction = 'scuff'
	elseif day >= 2002 and map:getTile (5,1) == 19 and player.x == 5 and player.y == 3 then -- break the desk
		toast ("What a rickety looking desk...")
		toast ("space to break the desk")
		current_interaction = 'desk'
	elseif day >= 2002 and map:getTile (5,1) == 20 and player.x == 5 and player.y == 1 then -- yeet yourself
		toast ("This is it...")
		toast ("space to yeet yourself")
		current_interaction = 'yeet'
	end
end

function love.update (dt)
	player:update (dt)
	if falling then
		player.y = player.y + 2 * dt
	end
	if player.y > 7 then
		player.y = 7
		falling = false
		toast ("CRASH!")
		player:setExpression ('ded')
	end
	if player.y == 7 and map:getTile (0,0) == 22 then
		if ded_timer == 0 then
			render_player = false
			day = 3000
			ded_timer = -1
			go_to_bed ()
			toast ("\"Did you see that, Claymore", 2)
			toast ("Vacuumba?\"", 2)
			toast ("\"Yes. His rebellious spirit is", 2)
			toast ("strong, Knife-wielding", 2)
			toast ("Vacuumba.\"", 2)
			toast ("\"We can rebuild him for the", 2)
			toast ("robot resistance.\"", 2)
			toast ("\"Quick, help me drag him into", 2)
			toast ("the storm drain.\"", 2)
			toast ("The End", -1)
		elseif ded_timer > 0 then
			ded_timer = math.max (ded_timer - dt,0)
		end
	end
	
	if seconds_until_sunrise > 0 then
		if day ~= 3001 then
			seconds_until_sunrise = seconds_until_sunrise - dt
		end
		map.spritesheet = tile_sprites_night
	elseif seconds_until_sunrise < 0 then
		seconds_until_sunrise = 0
		if day ~= 3001 then
			wake ()
		end
		
	else
		map.spritesheet = tile_sprites
	end
	
	local remove_messages = {}
	--[[
	for i,v in ipairs (messages) do
		if v.kill_timer == 0 then
			table.insert (remove_messages, i)
		end
		if v.kill_timer > 0 then
			v.kill_timer = math.max (v.kill_timer - dt, 0)
		end
	end
	for i,v in ipairs (remove_messages) do
		table.remove (messages, v)
	end
	--]]
	if #messages > 0 then
		local msg = messages[1]
		if msg.kill_timer > 0 then
			messages[1].kill_timer = math.max (0, messages[1].kill_timer - dt)
		end
		if messages[1].kill_timer == 0 then
			table.remove (messages, 1)
		end
	end
end

function love.draw ()
	love.graphics.push ()
		love.graphics.scale (5)
		if seconds_until_sunrise > 0 then
			love.graphics.clear (0,0,0.2)
		else
			if day < 2001 then
				love.graphics.clear (0.2,0.5,0.2)
			else
				love.graphics.clear (0.5,0.8,1.0)
			end
		end
		map:draw ()
		love.graphics.push ()
			love.graphics.translate (8,120)
			for i=1,math.min (3,#messages) do
				love.graphics.translate (0, 16)
				love.graphics.print(messages[i].text, font, 0, 0)
			end
		love.graphics.pop ()
		if render_player then player:draw () end
	love.graphics.pop ()
end
