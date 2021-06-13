local DEFAULT_VOLUME = 0.4

local volume = DEFAULT_VOLUME
local policeCodeActive = false
local xmlData = {}

-- ********
-- Resource start
-- ********

local function loadXML(fileName, index)
	local xmlRoot = xmlLoadFile(fileName)
	if not xmlRoot then return false end
	
	local t = {}
	
	local nodes = xmlNodeGetChildren(xmlRoot)
	for k,node in ipairs(nodes) do
		local attr = xmlNodeGetAttributes(node)
		for k,v in pairs(attr) do
			attr[k] = tonumber(v) or v
		end
		
		if not attr[index] then
			xmlUnloadFile(xmlRoot)
			return false
		end
		
		t[attr[index]] = attr
	end
	
	xmlUnloadFile(xmlRoot)
	
	return t
end

local function onClientResourceStart()
	xmlData.codezones = loadXML("codezones.xml", "loc")
	if not xmlData.codezones then return cancelEvent(true, "Loading codezones.xml failed") end
	
	xmlData.carcolors = loadXML("carcolors.xml", "id")
	if not xmlData.carcolors then return cancelEvent(true, "Loading carcolors.xml failed") end
	
	xmlData.vehiclecode = loadXML("vehiclecode.xml", "id")
	if not xmlData.vehiclecode then return cancelEvent(true, "Loading vehiclecode.xml failed") end
	
	xmlData.vehiclecodetime = loadXML("vehiclecodetime.xml", "id")
	if not xmlData.vehiclecodetime then return cancelEvent(true, "Loading vehiclecodetime.xml failed") end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)

-- ********
-- Sound functions
-- ********

local function playPoliceSFX(...)
	local sound = playSFX(...)
	setSoundVolume(sound, volume)
	return sound
end

local function playSwitchSFX(switchedOn)
	if isElement(static) then
		destroyElement(static)
	end
	
	if switchedOn then
		static = playSFX("genrl", 52, 3, true)
		setSoundVolume(static, volume * 0.1)
		
		policeCodeActive = true
	else
		policeCodeActive = false
	end

	playSFX("genrl", 52, 24, false)
	return true
end

local function sayZone(location)
	return playPoliceSFX("script", 0, xmlData.codezones[location].id, false)
end

local function sayIn() -- ~180
	local snd = playPoliceSFX("script", 3, 2, false)
	setTimer(destroyElement, 120, 1, snd)
	return snd
end

local function sayTenCode(id) -- 9 sounds different, id should be 0 - 8 or 10
	return playPoliceSFX("script", 4, id, false)
end

local function sayInWater() -- ~830
	return playPoliceSFX("script", 3, 2, false)
end

local function sayVehicleColor(veh)
	if (not isElement(veh)) then return end
	
	local c1 = getVehicleColor(veh)
	return playPoliceSFX("script", 1, xmlData.carcolors[c1].name, false)
end

local function sayCarType(veh_code)
	return playPoliceSFX("script", 5, veh_code, false)
end

local function sayOnFoot()
	return playPoliceSFX("script", 3, 4, false)
end

local function sayInA()
	return playPoliceSFX("script", 3, 1, false)
end

-- ********
-- Exported functions
-- ********

-- Plays the "We got a 10-'id'... in ..." sound for position of 'player'
function playCrimeReport(player, id, optionalVolume)
	if not isElement(player) then return false end
	if policeCodeActive then return false end
	
	id = tonumber(id)
	if not id then return falses end
	id = math.ceil(id)
	if id < 1 or id > 10 or id == 9 then return false end
	
	volume = tonumber(optionalVolume) or DEFAULT_VOLUME
	
	local x, y, z = getElementPosition(player)
	local location = getZoneName(x, y, z)
	
	if not location or location == "Unknown" then
		return false
	end
	
	playSwitchSFX(true)
	setTimer(playPoliceSFX, 500, 1, "script", 3, 8, false) -- we got a 10
	setTimer(sayTenCode, 1180, 1, id) -- 37 in

	local totalDuration
	
	if not xmlData.codezones[location] then	
		location = getZoneName(x, y, z, true)
	end
	setTimer(sayZone, 1910, 1, location) -- Location
	
	totalDuration = xmlData.codezones[location].dur * 1000 + 2010
	setTimer(playSwitchSFX, totalDuration, 1)
	totalDuration = totalDuration + 100
	
	return totalDuration
end

-- Plays the "Suspect last seen in ..." location sound for position of 'player'
function playLastSeenLocation(player, optionalVolume)
	if not isElement(player) then return false end
	if policeCodeActive then return false end
	
	volume = tonumber(optionalVolume) or DEFAULT_VOLUME

	local x, y, z = getElementPosition(player)
	local location = getZoneName (x, y, z)
	
	playSwitchSFX(true)
	setTimer(playPoliceSFX, 500, 1, "script", 3, 7, false) -- suspect last seen
	
	local totalDuration
	
	if location == "Unknown" then -- Outside bounds?
		setTimer(sayInWater, 1630, 1) -- in water
		
		totalDuration = 2390
		setTimer(playSwitchSFX, totalDuration, 1)
		totalDuration = totalDuration + 100
	else
		setTimer(sayIn, 1500, 1)
		
		if not xmlData.codezones[location] then	
			location = getZoneName(x, y, z, true)
		end
		setTimer(sayZone, 1710, 1, location) -- location
		
		totalDuration = xmlData.codezones[location].dur * 1000 + 1810
		setTimer(playSwitchSFX, totalDuration, 1)
		totalDuration = totalDuration + 100
	end	
	
	return totalDuration
end

-- Plays the "Suspect last seen in ..." description sound for 'player'
function playLastSeenDescription(player, optionalVolume)
	if not isElement(player) then return false end
	if policeCodeActive then return false end
	
	volume = tonumber(optionalVolume) or DEFAULT_VOLUME

	local veh = getPedOccupiedVehicle(player)
	local veh_code
	if veh then
		local vehID = getElementModel(veh)
		if not xmlData.vehiclecode[vehID] then return false end

		veh_code = xmlData.vehiclecode[vehID].code
	end
	
	playSwitchSFX(true)	
	setTimer(playPoliceSFX, 500, 1, "script", 3, 7, false) -- suspect last seen	
	
	local totalDuration
	
	if veh_code then
		setTimer(sayInA, 1550, 1) -- in a
		setTimer(sayVehicleColor, 1900, 1, veh) -- blue (color)
		setTimer(sayCarType, 2500, 1, veh_code)	-- 2 door (type)
		
		totalDuration = xmlData.vehiclecodetime[veh_code].dur * 1000 + 2600
		setTimer(playSwitchSFX, totalDuration, 1)
		totalDuration = totalDuration + 100
	else
		setTimer(sayOnFoot, 1550, 1)
		totalDuration = 2350
		setTimer(playSwitchSFX, totalDuration, 1)
		totalDuration = totalDuration + 100
	end
	
	return totalDuration
end
