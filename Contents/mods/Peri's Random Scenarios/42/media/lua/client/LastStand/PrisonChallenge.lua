PrisonChallenge = {}


PrisonChallenge.Add = function()
	addChallenge(PrisonChallenge);
end

PrisonChallenge.OnGameStart = function()

    		
Events.OnGameStart.Add(PrisonChallenge.OnNewGame);
Events.EveryTenMinutes.Add(PrisonChallenge.EveryTenMinutes);


end

PrisonChallenge.DifficultyCheck = function()
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
			if ZombRand(4)+1 == ZombRand(4)+1
			then pillowmod.brutalstart = true;
				pillowmod.direstart = false;
				pillowmod.diffcheckdone = true;
			else 
				pillowmod.brutalstart = false;
			end
		else 
				pillowmod.direstart = false;
				pillowmod.brutalstart = false;
				pillowmod.diffcheckdone = true;
	end 

	--do override
	if pillowmod.alwaysdire == true
		then pillowmod.direstart = true;
			pillowmod.brutalstart = false;
	elseif pillowmod.alwaysbrutal == true
		then pillowmod.brutalstart = true;
			pillowmod.direstart = false;
	else end

	if pillowmod.direstart == true
		then 
			--dire variables
			pillowmod.extrazombs = ZombRand(50,150);
			pillowmod.difficultyloops = ZombRand(3)+1;
			pillowmod.alarmcounter = 3;
			pillowmod.spawnincellchance = ZombRand(1,3);
	elseif pillowmod.brutalstart == true
		then
			--brtual variables
			pillowmod.extrazombs = ZombRand(100,200);
			pillowmod.difficultyloops = ZombRand(6)+1;
			pillowmod.alarmcounter = 1;
			pillowmod.spawnincellchance = ZombRand(1,2);
	else
			--normal variables
			pillowmod.extrazombs = 0;
			pillowmod.difficultyloops = 1;
			pillowmod.alarmcounter = ZombRand(5,20);
			pillowmod.spawnincellchance = ZombRand(1,4);
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

	print("Params -difficultyloops:" .. pillowmod.difficultyloops .. " spawn in cell chance:" .. pillowmod.spawnincellchance .. "alarmcounter:" .. pillowmod.alarmcounter);
	-- Keep progress from an existing save.  OnGameStart is also called when a
	-- saved challenge is loaded, so these values must only be initialized once.
	if pillowmod.wasalarmed == nil then pillowmod.wasalarmed = false end
	if pillowmod.breakroomseen == nil then pillowmod.breakroomseen = false end
	if pillowmod.diningroomseen == nil then pillowmod.diningroomseen = false end
	if pillowmod.outdoorrecseen == nil then pillowmod.outdoorrecseen = false end
	if pillowmod.parkinglotseen == nil then pillowmod.parkinglotseen = false end
	if pillowmod.mainentranceseen == nil then pillowmod.mainentranceseen = false end
	if pillowmod.northcellblock == nil then pillowmod.northcellblock = false end
	if pillowmod.southcellblock == nil then pillowmod.southcellblock = false end
	if pillowmod.zombct == nil then pillowmod.zombct = 104 end
	if pillowmod.largediningroomseen == nil then pillowmod.largediningroomseen = false end
	if pillowmod.smalldiningroomseen == nil then pillowmod.smalldiningroomseen = false end
	if pillowmod.infirmaryseen == nil then pillowmod.infirmaryseen = false end
	if pillowmod.patioseen == nil then pillowmod.patioseen = false end
	if pillowmod.externalcellsseen == nil then pillowmod.externalcellsseen = false end
	if pillowmod.internalparkingseen == nil then pillowmod.internalparkingseen = false end
	if pillowmod.studyroomseen == nil then pillowmod.studyroomseen = false end
	if pillowmod.woodshopseen == nil then pillowmod.woodshopseen = false end
	if pillowmod.prisonentranceseen == nil then pillowmod.prisonentranceseen = false end


end--end difficulty check

PrisonChallenge.EveryTenMinutes = function ()
	pl=getPlayer();
	if pl == nil then return end
	pillowmod = pl:getModData();
	PrisonChallenge.SpawnZombiesInCells();
	--start alarm check stuff
	if pl:getCurrentSquare():isOutside() == true 
				or pl:getCurrentSquare():getRoom() == nil
				then return
				else 
					plbuilding = pl:getCurrentSquare():getRoom():getBuilding();			
	end 

	if building == plbuilding 
		and pillowmod.wasalarmed == false 
		and pillowmod.alarmcounter  <= 1 
		then
			plbuilding:getDef():setAlarmed(true);	
			pillowmod.wasalarmed = true;
	else 
		pillowmod.alarmcounter = pillowmod.alarmcounter - 1 ;
	end	 -- end alarm check stuff	


	--if direstart or brutalstart then
	--	zombct = zombct + extrazombs;
	--else end


	local areaSpawns = {
		{marker = "largediningroomseen", label = "large dining room", x = 7578, y = 11792, count = 20},
		{marker = "smalldiningroomseen", label = "small dining room", x = 7623, y = 11793, count = 10},
		{marker = "infirmaryseen", label = "infirmary", x = 7518, y = 11846, count = 8},
		{marker = "patioseen", label = "patio", x = 7492, y = 11808, count = 15},
		{marker = "externalcellsseen", label = "external cells", x = 7372, y = 11709, count = 15},
		{marker = "internalparkingseen", label = "internal parking", x = 7392, y = 11791, count = 12},
		{marker = "studyroomseen", label = "study room", x = 7440, y = 11756, count = 8},
		{marker = "woodshopseen", label = "woodshop", x = 7441, y = 11858, count = 10},
		{marker = "prisonentranceseen", label = "prison entrance", x = 7673, y = 11793, count = 15},
		{marker = "mainentranceseen", label = "main entrance", x = 7705, y = 11885, count = 30, direCount = 45, brutalCount = 60},
	}

	for _, area in ipairs(areaSpawns) do
		if pillowmod[area.marker] == nil then pillowmod[area.marker] = false end
		if pillowmod[area.marker] == false and getCell():getGridSquare(area.x, area.y, 0) ~= nil then
			local zombz = area.count
			if pillowmod.brutalstart == true and area.brutalCount ~= nil then
				zombz = area.brutalCount
			elseif pillowmod.direstart == true and area.direCount ~= nil then
				zombz = area.direCount
			end
			print("spawning horde in " .. area.label .. " size:" .. zombz)
			addZombiesInOutfit(area.x, area.y, 0, zombz, "Inmate", 0)
			pillowmod[area.marker] = true
		end
	end


end --end every 10 mins


PrisonChallenge.SpawnZombiesInCells = function()
	local pl = getPlayer()
	if pl == nil then return end
	local cell = getCell()
	pillowmod = pl:getModData()

	-- Each cell row is three tiles apart.  The supplied endpoints differ by one
	-- X tile, so both columns are tested and used for the two cell faces.
	local blocks = {
		{marker = "southcellblock", label = "south", yStart = 11862, yEnd = 11806},
		{marker = "northcellblock", label = "north", yStart = 11778, yEnd = 11723},
	}

	for _, block in ipairs(blocks) do
		if pillowmod[block.marker] == nil then pillowmod[block.marker] = false end
		if pillowmod[block.marker] == false then
			local points = {}
			for y = block.yStart, block.yEnd, -3 do
				table.insert(points, {x = 7632, y = y, z = 0})
				table.insert(points, {x = 7633, y = y, z = 0})
				table.insert(points, {x = 7632, y = y, z = 1})
				table.insert(points, {x = 7633, y = y, z = 1})
			end
			-- The final supplied cell coordinate is not exactly three tiles from
			-- the preceding row, so retain it as an explicit final row.
			if points[#points].y ~= block.yEnd then
				table.insert(points, {x = 7632, y = block.yEnd, z = 0})
				table.insert(points, {x = 7633, y = block.yEnd, z = 0})
				table.insert(points, {x = 7632, y = block.yEnd, z = 1})
				table.insert(points, {x = 7633, y = block.yEnd, z = 1})
			end

			-- Chunks at opposite ends of the prison are not always loaded together.
			-- Remember each processed point so available cells can spawn immediately
			-- without duplicating them when the remaining chunks load later.
			local pointStateKey = block.marker .. "points"
			local pointState = pillowmod[pointStateKey]
			if pointState == nil then
				pointState = {}
				pillowmod[pointStateKey] = pointState
			end

			local pending = 0
			for _, point in ipairs(points) do
				local pointKey = point.x .. "_" .. point.y .. "_" .. point.z
				if pointState[pointKey] ~= true then
					if cell:getGridSquare(point.x, point.y, point.z) ~= nil then
						if ZombRand(pillowmod.spawnincellchance) + 1 == 1 then
							addZombiesInOutfit(point.x, point.y, point.z, 1, "Inmate", 0)
						end
						pointState[pointKey] = true
					else
						pending = pending + 1
					end
				end
			end

			if pending == 0 then
				pillowmod[block.marker] = true
				print("[PrisonChallenge] " .. block.label .. " cell block spawn completed")
			else
				print("[PrisonChallenge] " .. block.label .. " cell block has " .. pending .. " unloaded points; spawn postponed")
			end
		end
	end

end --end spawn zombies in cell function


PrisonChallenge.OnNewGame = function()
--moved this stuff from onGameStart. 
local pl = getPlayer();
local inv = pl:getInventory();
PrisonChallenge.DifficultyCheck();
building = pl:getCurrentSquare():getRoom():getBuilding();



		-- give player a jump suit and a random tool to break out with
		--check if it's a new game
		print(pl:getHoursSurvived());
		if getPlayer():getHoursSurvived()<=1 then
			--remove everything
			pl:clearWornItems();
		    pl:getInventory():clear();

		  --give player gear
			PrisonChallenge.clothes = {"Base.Boilersuit_Prisoner","Base.Shoes_Slippers","Base.Socks_Long"}
			for i , item in pairs(PrisonChallenge.clothes) do
				clothes = inv:AddItem(item);
				pl:setWornItem(clothes:getBodyLocation(), clothes);
			end

			belt = inv:AddItem("Base.Belt2");
			pl:setWornItem(belt:getBodyLocation(),belt);

			inv:AddItem("Base.KeyRing");
			

			PrisonChallenge.toollist = {"Base.BallPeenHammer","Base.Broom","Base.ClubHammer","Base.Crowbar","Base.Hammer","Base.HandAxe",
			"Base.LeadPipe","Base.Nightstick","Base.PickAxe","Base.PipeWrench","Base.Rake","Base.Shovel","Base.Shovel2",
			"Base.SnowShovel","Base.WoodAxe","Base.WoodenMallet"}

			--roll for Sledgehammer
			--give slege for roll won, else something from the list
			if ZombRand(100)+1 == ZombRand(100)+1 then
				print("Lucky enough to win the Sledgehammer")
				wpn = inv:AddItem("Base.Sledgehammer");
			else
				local pickatool = ZombRand(16)+1;
				wpn = inv:AddItem(PrisonChallenge.toollist[pickatool]);
			end

			pl:setPrimaryHandItem(wpn);
			pl:setSecondaryHandItem(wpn);

			--roll for building key
			if ZombRand(100)+1 == ZombRand(100)+1 then
				print("Lucky enough to win the building key")
				sq = pl:getCurrentSquare();
				keyid = sq:getBuilding():getDef():getKeyId();
				inv:AddItem("Base.Key1"):setKeyID(keyid);
			end


			PrisonChallenge.SpawnZombiesInCells();



		--make noise so zombies try to get player
		addSound(getPlayer(), getPlayer():getX(), getPlayer():getY(), 0, 500, 500); 
		addSound(getPlayer(), 7578, 11792, 0, 500, 500); --large dining room
		addSound(getPlayer(), 7492, 11808, 0, 500, 500); --patio
		addSound(getPlayer(), 7705, 11885, 0, 500, 500); --main entrance

		else end --end of new game check loop, anything below this is not going to happen


end


PrisonChallenge.OnInitWorld = function()
--SandboxVars = require "Sandbox/SixMonthsLater"

	--SandboxVars.StartMonth = 7;
	
	Events.OnGameStart.Add(PrisonChallenge.OnGameStart);
	PrisonChallenge.setSandBoxVars();
end

PrisonChallenge.setSandBoxVars = function()
	local presets = getSandboxPresets()
	if presets and presets:indexOf("pillow") ~= -1 then
		local options = getSandboxOptions()
		options:loadPresetFile("pillow")
		options:toLua()
		options:updateFromLua()
		options:applySettings()
	end
end


PrisonChallenge.RemovePlayer = function(p)

end

PrisonChallenge.AddPlayer = function(p)

end

PrisonChallenge.Render = function()

end

PrisonChallenge.spawns = {
{xcell = 25, ycell = 39, x = 130, y = 62, z = 0},
{xcell = 24, ycell = 39, x = 155, y = 65, z = 0},
{xcell = 25, ycell = 39, x = 130, y = 150, z = 0},
{xcell = 24, ycell = 39, x = 165, y = 3, z = 0}
}



local spawnselection = ZombRand(4)+1;
local xcell = PrisonChallenge.spawns[spawnselection].xcell;
local ycell = PrisonChallenge.spawns[spawnselection].ycell;
local x = PrisonChallenge.spawns[spawnselection].x;
local y = PrisonChallenge.spawns[spawnselection].y;
local z = PrisonChallenge.spawns[spawnselection].z;

PrisonChallenge.id = "PrisonChallenge";
PrisonChallenge.image = "media/lua/client/LastStand/PrisonChallenge.png";
PrisonChallenge.gameMode = "PrisonChallenge";
PrisonChallenge.world = "Muldraugh, KY";
PrisonChallenge.xcell = xcell;
PrisonChallenge.ycell = ycell;
PrisonChallenge.x = x;
PrisonChallenge.y = y;
PrisonChallenge.z = z;
PrisonChallenge.enableSandbox = true;

Events.OnChallengeQuery.Add(PrisonChallenge.Add)

