local volume = 0.4

local locID
local colorID
local vehCode
local vehCodeTime

function loadXML()
	local xml = xmlLoadFile("codezones.xml")
	local locNodes = xmlNodeGetChildren(xml)
	locID = {}
	for i, xmlnode in ipairs(locNodes) do
		local loc = xmlNodeGetAttribute(xmlnode, "loc")
		locID[loc] = xmlNodeGetAttributes(xmlnode)
	end
	xmlUnloadFile(xml)
	
	xml = xmlLoadFile("carcolors.xml")
	locNodes = xmlNodeGetChildren(xml)
	colorID = {}
	for i, xmlnode in ipairs(locNodes) do
		local id = tonumber(xmlNodeGetAttribute(xmlnode, "id"))
		colorID[id] = xmlNodeGetAttributes(xmlnode)
	end
	xmlUnloadFile(xml)
	
	xml = xmlLoadFile("vehiclecode.xml")
	locNodes = xmlNodeGetChildren(xml)
	vehCode = {}
	for i, xmlnode in ipairs(locNodes) do
		local id = tonumber(xmlNodeGetAttribute(xmlnode, "id"))
		vehCode[id] = xmlNodeGetAttributes(xmlnode)
	end
	xmlUnloadFile(xml)
	
	xml = xmlLoadFile("vehiclecodetime.xml")
	locNodes = xmlNodeGetChildren(xml)
	vehCodeTime = {}
	for i, xmlnode in ipairs(locNodes) do
		local id = tonumber(xmlNodeGetAttribute(xmlnode, "id"))
		vehCodeTime[id - 1] = xmlNodeGetAttributes(xmlnode)
	end
	xmlUnloadFile(xml)
end
addEventHandler("onClientResourceStart", resourceRoot, loadXML)

-- ********
-- Sound functions
-- ********

function playPoliceSFX(...)
	local sound = playSFX(...)
	setSoundVolume(sound, volume)
	return sound
end

function playSwitchSFX()
	if (isElement(static)) then
		destroyElement(static)
	else
		static = playSFX("genrl", 52, 3, true)
		setSoundVolume(static, volume * 0.1)
	end
	return playSFX("genrl", 52, 24, false)	
end

function sayZone(player)
	if (not isElement(player)) then return end
	
	local x, y, z = getElementPosition(player)
	local location = getZoneName (x, y, z)		
	if (locID[location]) then
		playPoliceSFX("script", 0, locID[location].id, false)
	else
		location = getZoneName(x, y, z, true)
		playPoliceSFX("script", 0, locID[location].id, false)
	end
end

function sayIn() -- ~180
	local snd = playPoliceSFX("script", 3, 2, false)
	setTimer(destroyElement, 120, 1, snd)
end

function sayTenCode(id)
	local tenCode = playPoliceSFX("script", 4, id, false)
end

function sayInWater() -- ~830
	local wtr = playPoliceSFX("script", 3, 2, false)
end

function sayVehicleColor(veh)
	if (not isElement(veh)) then return end
	
	local c1,c2,c3,c4 = getVehicleColor(veh)
	local carColor = playPoliceSFX("script", 1, colorID[c1].name, false)
end

function sayCarType(veh)
	if (not isElement(veh)) then return end
	
	local vehID = getElementModel(veh)
	local vehType = playPoliceSFX("script", 5, tonumber(vehCode[vehID].code), false)
end

function sayOnFoot()
	local onFoot = playPoliceSFX("script", 3, 4, false)
end

function sayInA()
	local inA = playPoliceSFX("script", 3, 1, false)
end

-- ********
-- Exported functions
-- ********

-- Plays the "We got a 10-... in ..." sound for position of 'player'
function playLocationCode(player, id)
	if (not isElement(player)) then return false end
	
	local x, y, z = getElementPosition(player)
	local location = getZoneName(x, y, z)
	playSwitchSFX()
	setTimer(playPoliceSFX, 500, 1, "script", 3, 8, false) -- we got a 10
	setTimer(sayTenCode, 1180, 1, id) -- 37 in
	
	if (location == "Unknown") or (isElementInWater(player)) then -- If the player is outside world bounds or submerged in water
		setTimer(sayInWater, 1740, 1) -- in water
		setTimer(playSwitchSFX, 2500, 1)
	else
		setTimer(sayZone, 1910, 1, player) -- Location
		if (locID[location]) then
			setTimer(playSwitchSFX, (tonumber(locID[location].dur) * 1000 + 2010), 1)
		else
			location = getZoneName(x, y, z, true)
			setTimer(playSwitchSFX, (tonumber(locID[location].dur) * 1000 + 2010), 1)
		end
	end
	
	return true
end

-- Plays the "Suspect last seen in ..." sound for position of 'player'
function playLastSeenLocationCode(player)
	if (not isElement(player)) then return false end

	local x, y, z = getElementPosition(player)
	local location = getZoneName (x, y, z)
	playSwitchSFX()
	setTimer(playPoliceSFX, 500, 1, "script", 3, 7, false) --suspect last seen
	if (location == "Unknown") or (isElementInWater(player)) then --if in water
		setTimer(sayInWater, 1630, 1) -- in water
		setTimer(playSwitchSFX, 2390, 1)
	else
		setTimer(sayIn, 1400, 1)
		setTimer(sayZone, 1610, 1, player) -- Location
		if(locID[location]) then
			setTimer(playSwitchSFX, (tonumber(locID[location].dur) * 1000 + 1710), 1)
		else
			location = getZoneName(x, y, z, true)
			setTimer(playSwitchSFX, (tonumber(locID[location].dur) * 1000 + 1710), 1)
		end
	end	
	
	return true
end

-- Plays the "last seen in ..." sound for 'player'
function playLastSeenVehicleCode(player)
	if (not isElement(player)) then return false end

	local x, y, z = getElementPosition(player)
	local location = getZoneName(x, y, z)
	playSwitchSFX()	
	setTimer(playPoliceSFX, 500, 1, "script", 3, 7, false) --suspect last seen	
	
	if (getPedOccupiedVehicle(player)) then
		local vehID = getElementModel(getPedOccupiedVehicle(player))
		local vehType = tonumber(vehCode[vehID].code)
		setTimer(sayInA, 1550, 1) --in a
		setTimer(sayVehicleColor, 1900, 1, getPedOccupiedVehicle(player)) --blue (color)
		setTimer(sayCarType, 2500, 1, getPedOccupiedVehicle(player))	--2 door (type)
		setTimer(playSwitchSFX, (tonumber(vehCodeTime[vehType].dur) * 1000 + 2100), 1)
	else
		setTimer(sayOnFoot, 1550, 1)
		setTimer(playSwitchSFX, 2350, 1)
	end
	
	return true
end
