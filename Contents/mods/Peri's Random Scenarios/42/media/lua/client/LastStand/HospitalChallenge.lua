--require "PillowsRandomScenarios.lua"

HospitalChallenge = {}

HospitalChallenge.Add = function()
	addChallenge(HospitalChallenge);
end

HospitalChallenge.OnGameStart = function()

	Events.OnGameStart.Add(HospitalChallenge.OnNewGame);
	Events.EveryTenMinutes.Add(HospitalChallenge.SpawnStPeregrinZombies);

end

HospitalChallenge.DifficultyCheck = function()
	local pl = getPlayer();
	pillowmod = pl:getModData();

	if ModOptions and ModOptions.getInstance then
		pillowmod.alwaysdire = PillowModOptions.options.alwaysdire
		pillowmod.alwaysbrutal = PillowModOptions.options.alwaysbrutal
	end 


	--1in2 is dire, and 1in4 of those is brutal.
	if pillowmod.diffcheckdone == nil
		and ZombRand(2)+1 == ZombRand(2)+1
		then 
			pillowmod.direstart = true;
			pillowmod.brutalstart = false;
			pillowmod.diffcheckdone = true;
			if  ZombRand(4)+1 == ZombRand(4)+1
			then
			 	pillowmod.brutalstart = true;
				pillowmod.direstart = false;
				pillowmod.diffcheckdone = true;
			else 
				pillowmod.brutalstart = false;
			end
		else 
				pillowmod.direstart = false;
				pillowmod.brutalstart = false;
				pillowmod.diffcheckdone = true;
				print("Normal Start selected");
	end 

	--do override
	if pillowmod.alwaysdire == true
		then pillowmod.direstart = true;
			pillowmod.brutalstart = false;
	elseif pillowmod.alwaysbrutal == true
		then pillowmod.brutalstart = true;
			pillowmod.direstart = false;
	else end


	--change to do dire roll, then assign variables. This where override always dire/brutal.
	if pillowmod.direstart == true
		then
			--dire variables
			pillowmod.brutalstart = false;
			pillowmod.difficultymodifier = ZombRand(5,10);
			pillowmod.injurytimemodifier = ZombRand(10,20);
			pillowmod.drunkmodifier = 25;
	elseif  pillowmod.brutalstart == true
		then
			--brutal variables
			pillowmod.direstart = false;
			pillowmod.difficultymodifier = ZombRand(10,20);
			pillowmod.injurytimemodifier = ZombRand(10,30);
			pillowmod.drunkmodifier = 50;
	else
			--normal variables
			pillowmod.difficultymodifier = 0;
			pillowmod.injurytimemodifier = 0;
			pillowmod.drunkmodifier = 0;
	end



	--play the sound
	if pillowmod.direstart 
	and pillowmod.soundplayed == nil 
	then
 		print("Dire Start selected");
		pl:playSound("Thunder");
		pillowmod.soundplayed = true;

	elseif pillowmod.brutalstart 
	and pillowmod.soundplayed == nil
	then
		print("Brutal Start selected");
		pl:playSound("PlayerDied");
		pillowmod.soundplayed = true;
	else end


end -- end DifficultyCheck

HospitalChallenge.ApplyInjuries = function() 
	local pl = getPlayer();
	--random injury
	local injury = ZombRand(8)+1;
	damage = pillowmod.difficultymodifier + 20;
	injurytime = 25+ pillowmod.injurytimemodifier;
		if injury == 1 then
			pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    elseif injury == 2 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    elseif injury == 3 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    elseif injury == 4 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
		elseif injury == 5 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    elseif injury == 6 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_L):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    elseif injury == 7 then
	    	pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
		else 
			pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):AddDamage(damage);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setFractureTime(injurytime);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setSplint(true, .8);
	        pl:getBodyDamage():getBodyPart(BodyPartType.LowerArm_R):setBandaged(true, 5, true, "Base.AlcoholBandage");
	    end 
end --end ApplyInjuries

HospitalChallenge.MakeItSpicy = function()
	local pl = getPlayer();
	pillowmod = pl:getModData();
	plbuilding = pl:getCurrentSquare():getRoom():getBuilding();	
	tile = plbuilding:getRandomRoom():getRandomSquare();

	spice = ZombRand(3) +1;
	if pillowmod.spiceadded == nil
			then 
		if spice == 1 then
			plbuilding:getDef():setAlarmed(true);	
			print("Spice is an alarm.");
		elseif spice == 2 then
			tile:explode();
			print("Spice is a fire.");
		else
			addZombiesInOutfit(pl:getX() + 12 ,pl:getY()+12, 0, 12, None, 0);
			addSound(getPlayer(), getPlayer():getX(), getPlayer():getY(), 0, 500, 500); 
			print("Spice is a horde.");
		end 
		pillowmod.spiceadded = true
	end 

end -- end make it spicy

HospitalChallenge.SpawnStPeregrinZombies = function()
	if HospitalChallenge.isStPeregrinSpawn ~= true then return end

	local pl = getPlayer()
	if pl == nil then return end

	local cell = getCell()
	local modData = pl:getModData()
	local outfit = "HospitalPatient"

	-- Ground floor: fixed groups supplied for the hospital rooms.
	local groundFloorSpawns = {
		{marker = "stPeregrinMainExit", label = "main exit", x = 12376, y = 3674, count = 20},
		{marker = "stPeregrinCafeteria", label = "cafeteria", x = 12416, y = 3711, count = 10},
		{marker = "stPeregrinCrematorium", label = "crematorium", x = 12380, y = 3713, count = 4},
		{marker = "stPeregrinWaitingRoom", label = "waiting room", x = 12379, y = 3657, count = 5},
	}

	for _, area in ipairs(groundFloorSpawns) do
		if modData[area.marker] ~= true and cell:getGridSquare(area.x, area.y, 0) ~= nil then
			addZombiesInOutfit(area.x, area.y, 0, area.count, outfit, 0)
			modData[area.marker] = true
			print("[HospitalChallenge] St. Peregrin " .. area.label .. " spawned " .. area.count .. " zombies")
		end
	end

	local function processPoints(marker, label, points)
		if modData[marker] == true then return end

		local stateKey = marker .. "Points"
		local pointState = modData[stateKey]
		if pointState == nil then
			pointState = {}
			modData[stateKey] = pointState
		end

		local pending = 0
		for _, point in ipairs(points) do
			local pointKey = point.x .. "_" .. point.y .. "_" .. point.z
			if pointState[pointKey] ~= true then
				if cell:getGridSquare(point.x, point.y, point.z) ~= nil then
					addZombiesInOutfit(point.x, point.y, point.z, 1, outfit, 0)
					pointState[pointKey] = true
				else
					pending = pending + 1
				end
			end
		end

		if pending == 0 then
			modData[marker] = true
			print("[HospitalChallenge] St. Peregrin " .. label .. " spawn completed")
		end
	end

	-- First upper floor: 30 points distributed inside the supplied quadrilateral.
	local secondFloorPoints = {}
	local topLeft = {x = 12374, y = 3652}
	local topRight = {x = 12426, y = 3669}
	local bottomRight = {x = 12431, y = 3712}
	local bottomLeft = {x = 12376, y = 3713}
	for row = 1, 5 do
		local verticalProgress = row / 6
		local leftX = topLeft.x + (bottomLeft.x - topLeft.x) * verticalProgress
		local leftY = topLeft.y + (bottomLeft.y - topLeft.y) * verticalProgress
		local rightX = topRight.x + (bottomRight.x - topRight.x) * verticalProgress
		local rightY = topRight.y + (bottomRight.y - topRight.y) * verticalProgress
		for column = 1, 6 do
			local horizontalProgress = column / 7
			table.insert(secondFloorPoints, {
				x = math.floor(leftX + (rightX - leftX) * horizontalProgress + 0.5),
				y = math.floor(leftY + (rightY - leftY) * horizontalProgress + 0.5),
				z = 1,
			})
		end
	end
	processPoints("stPeregrinSecondFloor", "second floor", secondFloorPoints)

	-- Second upper floor: 22 zombies distributed evenly along the supplied line.
	local thirdFloorPoints = {}
	local xStart, yStart = 12362, 3656
	local xEnd, yEnd = 12424, 3704
	local dx, dy = xEnd - xStart, yEnd - yStart
	local thirdFloorCount = 22
	for index = 0, thirdFloorCount - 1 do
		local progress = index / (thirdFloorCount - 1)
		local pointX = math.floor(xStart + dx * progress + 0.5)
		local pointY = math.floor(yStart + dy * progress + 0.5)
		table.insert(thirdFloorPoints, {x = pointX, y = pointY, z = 2})
	end
	processPoints("stPeregrinThirdFloor", "third floor", thirdFloorPoints)
end

HospitalChallenge.OnNewGame = function()
--moved this stuff from onGameStart. 
		--check if it's a new game
		local pl = getPlayer();
		pillowmod = pl:getModData();
		HospitalChallenge.SpawnStPeregrinZombies();
		--check if it's a new game
		print(pl:getHoursSurvived());
		if pillowmod.startconditionsset == nil
			and getPlayer():getHoursSurvived()<=1 then
			HospitalChallenge.DifficultyCheck();
			local inv = pl:getInventory();

			--remove all clothes and give player a hospital gown
			pl:clearWornItems();
		    pl:getInventory():clear();
			clothes = inv:AddItem("Base.HospitalGown");
			inv:AddItem("Base.KeyRing");
			pl:setWornItem(clothes:getBodyLocation(), clothes);

			--set stats 
			pl:getStats():set(CharacterStat.INTOXICATION, 50+pillowmod.drunkmodifier); -- 0 to 100
			pl:getStats():set(CharacterStat.THIRST, 0.25); -- from 0 to 1
			pl:getStats():set(CharacterStat.HUNGER, 0.25); -- from 0 to 1
			pl:getStats():set(CharacterStat.FATIGUE, 0.25); -- from 0 to 1

			HospitalChallenge.ApplyInjuries();
			if pillowmod.brutalstart then
				HospitalChallenge.MakeItSpicy();
			else end 
			pillowmod.startconditionsset = true;

		else 
		end 
end

HospitalChallenge.OnCreatePlayer = function()

end

HospitalChallenge.OnInitWorld = function()
	
	Events.OnGameStart.Add(HospitalChallenge.setSandBoxVars);

	Events.OnGameStart.Add(HospitalChallenge.OnGameStart);

end

HospitalChallenge.setSandBoxVars = function()
	local presets = getSandboxPresets()
	if presets and presets:indexOf("pillow") ~= -1 then
		local options = getSandboxOptions()
		options:loadPresetFile("pillow")
		options:toLua()
		options:updateFromLua()
		options:applySettings()
	end
end


HospitalChallenge.RemovePlayer = function(p)

end

HospitalChallenge.AddPlayer = function(p)

end

HospitalChallenge.Render = function()

--~ 	getTextManager():DrawStringRight(UIFont.Small, getCore():getOffscreenWidth() - 20, 20, "Zombies left : " .. (EightMonthsLater.zombiesSpawned - EightMonthsLater.deadZombie), 1, 1, 1, 0.8);

--~ 	getTextManager():DrawStringRight(UIFont.Small, (getCore():getOffscreenWidth()*0.9), 40, "Next wave : " .. tonumber(((60*60) - EightMonthsLater.waveTime)), 1, 1, 1, 0.8);
end

local ss = ZombRand(7)+1;
local xcell = 1
local ycell = 1
local x = 1
local y = 1
local z = 0
if ss == 1 then 
	xcell = 33; ycell = 42; x = 255; y = 150;-- March Ridge, dr office, exam room ID:341
elseif ss == 2 then
	xcell = 39; ycell = 23;x = 169; y = 15; -- West Point, dr office: 11869x6915x0
elseif ss == 3 then
	xcell = 36; ycell = 33;x = 63; y = 140;  -- Muldraugh, Cortman Medical: 10863x10040x0
elseif ss == 4 then
	xcell = 26; ycell = 38;x = 287; y = 123;  -- Rosewood, dr office: 8087x11523x0
elseif ss == 5 then
	xcell = 18; ycell = 31;x = 99; y = 279;  -- Isolated Areas, dr office: 5499x9579x0
elseif ss == 6 then
	xcell = 24; ycell = 27; x = 96; y = 292; -- Fallas Lake, dr office: 7296x8392x0
else
	xcell = 41; ycell = 12; x = 119; y = 77; z = 2; -- St. Peregrin Hospital: 12419x3677x2
end

HospitalChallenge.isStPeregrinSpawn = ss == 7

HospitalChallenge.id = "HospitalChallenge";
HospitalChallenge.image = "media/lua/client/LastStand/HospitalChallenge.png";
HospitalChallenge.gameMode = "HospitalChallenge";
HospitalChallenge.world = "Muldraugh, KY";
HospitalChallenge.xcell = xcell;
HospitalChallenge.ycell = ycell;
HospitalChallenge.x = x;
HospitalChallenge.y = y;
HospitalChallenge.z = z;
HospitalChallenge.enableSandbox = true;

Events.OnChallengeQuery.Add(HospitalChallenge.Add)

