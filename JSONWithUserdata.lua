
-- Defaultio

--[[
	
	This module adds support for encoding userdata values to JSON strings.
	It also supports lists which skip indices, such as {[1] = "a", [2] = "b", [4] = "c"}
	
	Userdata support is implemented by replacing userdata types with a new table, with keys _T and _V:
		_T = userdata type enum (index in the supportedUserdataTypes list)
		_V = a value or table representing the value
	
	Follow the examples bellow to add suppport for additional userdata types.
	
	~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~	
	
	Usage example:
	
		local myTable = {CFrame.new(), BrickColor.Random(), 4, "String", Enum.Material.CorrodedMetal}
		
		local jsonModule = require(PATH_TO_MODULE)
		
		local jsonString = jsonModule:Encode(myTable)
		
		local decodedTable = jsonModule:Decode(jsonString)
	
--]]

local jsonPlusUserdata = {}
local httpService = game:GetService("HttpService")

local tableUtil = {}


local supportedUserdataTypes = {
	
	{UserDataType = "EnumItem",
	Encode = function(v) return {tostring(v.EnumType), v.Value} end,
	Decode = function(v) for _, enumItem in pairs(Enum[v[1]]:GetEnumItems()) do if enumItem.Value == v[2] then return enumItem end end end},

	{UserDataType = "Vector3",
	Encode = function(v) return {v.X, v.Y, v.Z} end,
	Decode = function(v) return Vector3.new(unpack(v)) end},

	{UserDataType = "CFrame",
	Encode = function(v) return {v:components()} end,
	Decode = function(v) return CFrame.new(unpack(v)) end},

	{UserDataType = "Color3",
	Encode = function(v) return {v.r, v.g, v.b} end,
	Decode = function(v) return Color3.new(unpack(v)) end},

	{UserDataType = "BrickColor",
	Encode = function(v) return v.Number end,
	Decode = function(v) return BrickColor.new(v) end},

}

function jsonPlusUserdata:Encode(stateTable)
	stateTable = tableUtil:DeepCopy(stateTable)
	
	local function traverseTable(tab)
		for key, value in pairs(tab) do
			local valueType = typeof(value)
			if valueType == "table" then
				traverseTable(value)
			else
				for userdataEnum, userdataType in pairs(supportedUserdataTypes) do
					if userdataType.UserDataType == valueType then
						tab[key] = {_T = userdataEnum, _V = userdataType.Encode(value)}
						break
					end
				end
			end
		end
	end		
	
	traverseTable(stateTable)	
	if tableUtil:DoesMixedTableHaveListWithMissingKeys(stateTable) then
		stateTable = tableUtil:MakeKeysStrings(stateTable)
	end
	return httpService:JSONEncode(stateTable)
end


function jsonPlusUserdata:Decode(stateString)
	if not stateString then
		return
	end
	
	local stateTable = httpService:JSONDecode(stateString)
	stateTable = tableUtil:MakeKeysNumbers(stateTable)
	
	local function traverseTable(tab)
		for key, value in pairs(tab) do
			if typeof(value) == "table" then
				if value._T and value._V then
					tab[key] = supportedUserdataTypes[value._T].Decode(value._V)
				else
					traverseTable(value)
				end
			end
		end
	end		
	
	traverseTable(stateTable)
	return stateTable
end


--------------------------- Table utility -----------------------

function tableUtil:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tableUtil:DeepCopy(orig_key)] = tableUtil:DeepCopy(orig_value)
        end
        setmetatable(copy, tableUtil:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tableUtil:IsListMissingKeys(tbl)
	local prevKey
	for key, value in pairs(tbl) do
		if not (typeof(key) == "number") then
			break
		end
		if not prevKey and not (key == 1) then
			return true
		elseif prevKey and not (key == prevKey + 1) then
			return true
		end
		prevKey = key
	end
	return false
end

function tableUtil:DoesMixedTableHaveListWithMissingKeys(tbl)
	if tableUtil:IsListMissingKeys(tbl) then
		return true
	else
		for key, value in pairs(tbl) do
			if typeof(value) == "table" then
				if tableUtil:DoesMixedTableHaveListWithMissingKeys(value) then
					return true
				end
			end
		end
	end
	return false
end

function tableUtil:MakeKeysStrings(orig)
	local new = {}
	for key, value in pairs(orig) do
		if typeof(value) == "table" then
			value = tableUtil:MakeKeysStrings(value)
		end
		new[tostring(key)] = value
	end
	return new
end

function tableUtil:MakeKeysNumbers(orig)
	local new = {}
	for key, value in pairs(orig) do
		if typeof(value) == "table" then
			value = tableUtil:MakeKeysNumbers(value)
		end
		new[tonumber(key) or key] = value
	end
	return new
end


return jsonPlusUserdata
