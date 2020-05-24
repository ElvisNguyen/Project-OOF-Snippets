-- Elvis' Brainchild

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local masterDatastore = DataStoreService:GetDataStore("masterDatastore")

local itemTable = {} -- Item table stores the inventory stuff
local globalExpTable = {}
local globalKCTable = {}
local playerStatTable = {}
local playerClassTable = {}
local masterDatastoreTable = {}

function commitGameData()
	for i, player in pairs(Players:GetPlayers()) do
				--print (player.Name) 					-- Player name will be the key
				
				local backpack = player:FindFirstChild("Backpack") -- Get player inventory
				if backpack then -- make sure it exists
					for a,b in pairs(backpack:GetChildren()) do --iterate over inventory
						--print (player.name)
						itemTable[a] = tostring(b) --store items in the item table
					end
				end	
				if workspace:FindFirstChild(player.Name):FindFirstChild("SubspaceGun") then -- If they're equipping it
					itemTable[66] = "SubspaceGun"
				end
					masterDatastoreTable["itemTable"] = itemTable -- Loads it into the master table
				--[[for a, b in pairs (itemTable) do
					print (itemTable[a])
				end]]--
				
				local globalExp = workspace:FindFirstChild("GlobalExp") --Same pattern
				if globalExp then
					globalExpTable[player.name] = globalExp.Value
					--print("DSglobalExp: ", globalExpTable[player.name])
					
					masterDatastoreTable["globalExpTable"] = globalExpTable
				end
				
				local playerName = player.name
				local player_humanoid = workspace:FindFirstChild(player.name):FindFirstChild("Humanoid")
				if player_humanoid then
					local HP = player_humanoid.Health
					local Agi = player_humanoid:FindFirstChild("Agi").Value
					local Def = player_humanoid:FindFirstChild("Def").Value
					local Dmg = player_humanoid:FindFirstChild("Dmg").Value
					
					playerStatTable["HP"] = HP
					playerStatTable["Agi"] = Agi
					playerStatTable["Def"] = Def
					playerStatTable["Dmg"] = Dmg
					
					--print ("DSHealth: ", playerStatTable["HP"])
					--print ("DSAgi: ", playerStatTable["Agi"])
					--print ("DSDef: ", playerStatTable["Def"])
					--print ("DSDmg: ", playerStatTable["Dmg"])
					
					masterDatastoreTable["playerStatTable"] = playerStatTable
				end
				
				local mobKillcount = workspace:FindFirstChild("mobs_killed")
				if mobKillcount then
					local killcount = mobKillcount.Value
					globalKCTable[player.name] = killcount
					--print ("Global KC: ", globalKCTable[player.name])
					
					masterDatastoreTable["globalKCTable"] = globalKCTable
				end
				
				local player_class = workspace:FindFirstChild("character_class")
				if player_class then
					local class = player_class.Value
					playerClassTable[player.name] = class
					masterDatastoreTable["playerClassTable"] = playerClassTable
				end
	end
end

function extractMasterTable()
	local ds_itemTable = {} -- Item table stores the inventory stuff
	local ds_globalExpTable = {}
	local ds_globalKCTable = {}
	local ds_playerStatTable = {}

	ds_itemTable = masterDatastoreTable["itemTable"]
	ds_globalExpTable = masterDatastoreTable["globalExpTable"]
	ds_globalKCTable = masterDatastoreTable["globalKCTable"]
	ds_playerStatTable = masterDatastoreTable["playerStatTable"]
	
	for a, b in pairs (ds_itemTable) do
		print (a, b)
	end
	
	for a, b in pairs (globalExpTable) do
		print(a, b)
	end

	for a, b in pairs (globalKCTable) do
		print (a, b)
	end
	
	for a, b in pairs (playerStatTable) do
		print (a, b)
	end

	for a, b in pairs (playerClassTable) do
		print (a, b)
	end
	
end

		
function pushGameData()
	local jsonModule = require(game.ServerScriptService.JSONWithUserdata)
		
	local masterToJSON = jsonModule:Encode(masterDatastoreTable)
	--local JSONtomaster = jsonModule:Decode(masterToJSON)
	--masterDatastoreTable = JSONtomaster

for i, player in pairs(Players:GetPlayers()) do
	
	local success, err = pcall(function() masterDatastore:SetAsync(player.name, masterToJSON)
	end)
	
	if success then
		print("Table saved successfully")
	else
		print(err)
	end
end

end

function loadGameData()
	for i, player in pairs(Players:GetPlayers()) do
			local jsonModule = require(game.ServerScriptService.JSONWithUserdata)
			local success, JSONtoMaster = pcall(function()
				return masterDatastore:GetAsync(player.name)
			end)
			
			if success then
				print("Data loaded successfully...attempting to deserialize")
				masterDatastoreTable = jsonModule:Decode(JSONtoMaster)
				itemTable = masterDatastoreTable["itemTable"]
				globalExpTable = masterDatastoreTable["globalExpTable"]
				globalKCTable = masterDatastoreTable["globalKCTable"]
				playerStatTable = masterDatastoreTable["playerStatTable"]
				playerClassTable = masterDatastoreTable["playerClassTable"]
			else
				print (JSONtoMaster)
			end
	end	
end

function loadTableToGame()
	--Removes everything from their bag
	for i, j in pairs(game.Players:GetChildren())do
		local Backpack = j:FindFirstChild("Backpack",true)
		if Backpack ~= nil then  --Check if the child has a backpack
	        local c = Backpack:GetChildren() --Get the children of the backpack
	        for i = 1,#c do
	            c[i]:Destroy() --Use Destroy method instead
	        end
	    end
	end
	
	for i, player in pairs(Players:GetPlayers()) do
		--[[print (player.Name)
		local backpack = player:FindFirstChild("Backpack")
		
			if backpack then
				for a,b in pairs(itemTable) do
					if not backpack:FindFirstChild(b) and not workspace:FindFirstChild(player.Name):FindFirstChild(b) then -- if they don't already have the item
						local item = game.ServerStorage:FindFirstChild(b)
						
						if item then
							local item_clone = item:Clone()
							item_clone.Parent = backpack
						end
						
					end
				end
			end--]]
			
			for a, b in pairs (globalExpTable) do
				if (a == player.name) then
					workspace.GlobalExp.Value = b
					local item = game.ServerStorage:FindFirstChild("HealSpell")
						if not(game.StarterPack:FindFirstChild("HealSpell")) then
							local clone = item:Clone()
							clone.Parent = game.StarterPack
						end
				end
			end
			
			for a, b in pairs (globalKCTable) do
				if(a == player.name) then
					workspace.mobs_killed.Value = b
				end
			end
			
			local player_humanoid = workspace:FindFirstChild(player.name):FindFirstChild("Humanoid")
			if player_humanoid then

				for a, b in pairs (playerStatTable) do
					if(a == "HP") then
						player_humanoid.Health = b
					elseif(a=="Agi") then
						player_humanoid:FindFirstChild("Agi").Value = b
					elseif(a=="Def") then
						player_humanoid:FindFirstChild("Def").Value = b
					elseif(a=="Dmg") then
						player_humanoid:FindFirstChild("Dmg").Value = b
					end
				end					
			end
			
			for a, b in pairs(playerClassTable) do
				if(a == player.name) then
					workspace.character_class.Value = b
					local character_selected = workspace.character_class.Value
					local classSet = {} -- This is a table so we can pull whatever we want into a class' toolbox from ServerStorage

					if character_selected == "warrior" then -- Checks for different class scenarios
						game.StarterPlayer.StarterCharacter:Destroy() --Destroys the default startercharacter
						local model = game.ServerStorage.Warrior:Clone() -- replaces it with our class model
						model.Parent = game.StarterPlayer -- clones it into the starter player folder
						model.Name = "StarterCharacter" --Sets the name to StarterCharacter so it'll respawn as that model
					
						classSet = {"Tool", "Crash", "Rush", "Flying Thunder God"} -- These will be the items and skills our class should be able to use
					
					elseif character_selected == "shooter" then
						game.StarterPlayer.StarterCharacter:Destroy() --Destroys the default startercharacter
						local model = game.ServerStorage.Shooter:Clone() -- replaces it with our class model
						model.Parent = game.StarterPlayer -- clones it into the starter player folder
						model.Name = "StarterCharacter" --Sets the name to StarterCharacter so it'll respawn as that model
						
						classSet = {"Knock","Handbullets", "Tool", "Katana","LightRifle"}  -- These will be the items and skills our class should be able to use
					elseif character_selected == "mage" then
						game.StarterPlayer.StarterCharacter:Destroy() --Destroys the default startercharacter
						local model = game.ServerStorage.Mage:Clone() -- replaces it with our class model
						model.Parent = game.StarterPlayer -- clones it into the starter player folder
						model.Name = "StarterCharacter" --Sets the name to StarterCharacter so it'll respawn as that model
						
						classSet = {"Lightball", "Flash", "Fireball"}  --These will be the items and skills our class should be able to use
					end
					
					for i, j in pairs(game.StarterPack:GetChildren())do
						if j ~= nil then  --Check if the child has a backpack
					         j:Destroy() --Use Destroy method instead
					    end
					end	
									
					for yes, ok in pairs(classSet) do
						local item = game.ServerStorage:FindFirstChild(ok)
						if not(game.StarterPack:FindFirstChild(ok)) then
							local clone = item:Clone()
							clone.Parent = game.StarterPack
						end
					end
					
					for i, player in pairs(Players:GetPlayers()) do
						--print (player.Name)
						player:LoadCharacter() -- Reloads the character model
					end
				end
			end
	end
end	

function loadGame()
	loadGameData()
	loadTableToGame()
end

function saveGame()
	commitGameData()
	pushGameData()
end

while true do
wait(5) --Save the game every 5s
	--commitGameData()
	--pushGameData()
	--extractMasterTable()
	
	--loadGameData()
	--loadTableToGame()

	
end






--[[
local success, currentExperience = pcall(function()
	return experienceStore:GetAsync("elvis96")
end)
 
if success then
	print("Current Experience:", currentExperience)
end]]--
