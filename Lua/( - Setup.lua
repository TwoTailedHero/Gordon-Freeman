-- HL_HurtMobj, HL_DamageGordon, and HL_GetDistance in WpnSetup due to SRB2 wanting to be "special."
local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

SafeFreeSlot("sfx_hlwpnu","sfx_hdryfi")

local function warn(str)
	print("\130WARNING: \128"..str);
end

local function notice(str)
	print("\x82NOTICE: \x80"..str);
end

local pickupnotifytime = TICRATE*3 -- how long does each weapon notification last?

if not HL then
	rawset(_G, "HL", {})
end

HL.DMG = {
	-- Potential types of damage
	GENERIC       = 0,
	CRUSH         = 1 << 0,
	BULLET        = 1 << 1,
	SLASH         = 1 << 2,
	BURN          = 1 << 3,
	FREEZE        = 1 << 4,
	FALL          = 1 << 5,
	BLAST         = 1 << 6,
	CLUB          = 1 << 7,
	ELEC          = 1 << 8,
	SUPERSONIC    = 1 << 9,
	ENERGYBEAM    = 1 << 10,
	DIRECT        = 1 << 11,
	DROWN         = 1 << 12,
	PARALYZE      = 1 << 13,
	NERVEGAS      = 1 << 14,
	POISON        = 1 << 15,
	RADIATION     = 1 << 16,
	DROWNRECOVER  = 1 << 17,
	ACID          = 1 << 18,
	SLOWBURN      = 1 << 19,
	REMOVEONDEATH = 1 << 20,
	PLASMA        = 1 << 21,
	ALWAYSGIB     = 1 << 6, -- same as BLAST (always gib)
	NEVERGIB	  = 1 << 22	-- never gib, even if damage > critical threshold
}

HL.GmanSpots = {
	["gamemap 1 level greenflower zone 1"] = {
		{
			x = 6074,
			y = 7082,
			z = 1248,
			angle = {init = 180, leave = 30},
			leavedelay = TICRATE,
			leaverange = 256*FRACUNIT,
			useportal = true,
		}
	},
	["gamemap 2 level greenflower zone 2"] = {
		{
			x = 482,
			y = 2245,
			z = 2624,
			angle = {init = 0, leave = 180},
			leavedelay = TICRATE,
			leaverange = 256*FRACUNIT
		}
	},
	["gamemap 4 level techno hill zone 1"] = {
		x = 15964,
		y = -9244,
		z = 3392,
		angle = {init = 55, leave = 270},
		leavedelay = TICRATE,
		leaverange = 256*FRACUNIT,
		activatecondition = {passline = {{x = 0, y = 0}, {x = 0, y = 0}}}
	},
	["gamemap 5 level techno hill zone 2"] = {
		x = -14569,
		y = 2391,
		z = 1920,
		angle = {init = 60, leave = 270},
	},
	["gamemap 7 level deep sea zone 1"] = {
		x = 5810,
		y = 816,
		z = 800,
		angle = {init = 215, leave = 45},
		leavedelay = TICRATE,
		leaverange = 1024*FRACUNIT,
	},
	["gamemap 8 level deep sea zone 2"] = {
		x = 21472,
		y = -5064,
		z = 296,
		angle = {init = 270, leave = 90},
	},
	["gamemap 10 level castle eggman zone 1"] = {
		x = 10700,
		y = 6049,
		z = 4096,
		angle = {init = 0, leave = 180},
		leavedelay = TICRATE*2,
		leaverange = 16384*FRACUNIT,
	},
	["gamemap 11 level castle eggman zone 2"] = {
		x = 1068,
		y = -18178,
		z = 1376,
		angle = {init = 195, leave = 90},
		leavedelay = TICRATE,
		leaverange = 16384*FRACUNIT,
		dissapearcondition = {passline = {{x = 0, y = 0}, {x = 0, y = 0}}}
	},
	["gamemap 13 level arid canyon zone 1"] = {
		x = -672,
		y = 138,
		z = 2736,
		angle = {init = 10, leave = 200},
		leavedelay = TICRATE,
		leaverange = 16384*FRACUNIT,
		activatecondition = {passline = {{x = 0, y = 0}, {x = 0, y = 0}}}
	},
	["gamemap 13 level arid canyon zone 1"] = {
		x = 2800,
		y = -2,
		z = 2736,
		angle = {init = 10, leave = 200},
		leavedelay = TICRATE,
		leaverange = 16384*FRACUNIT,
		activatecondition = {passline = {{x = 0, y = 0}, {x = 0, y = 0}}}
	},
}

if not HL1_DMGStats rawset(_G, "HL1_DMGStats", {}) end

local function safeGetMT(mt)
	local success, value = pcall(function() return mt end)
	return success and value or nil
end

rawset(_G, "HL_SetMTStats", function(mt, wishhealth, wishdamage)
	local mobjType = type(mt) == "string" and _G[mt] or mt
	if not mobjType return end
	HL1_DMGStats[mobjType] = {health = wishhealth, damage = wishdamage}
end)

HL_SetMTStats(safeGetMT(MT_BLUECRAWLA), {health = 30}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_REDCRAWLA), {health = 60}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_GFZFISH), {health = 20}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_GOLDBUZZ), {health = 30}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_REDBUZZ), {health = 30}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_DETON), {health = 10}, {dmg = 60})
HL_SetMTStats(safeGetMT(MT_POPUPTURRET), {health = 80}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_CRAWLACOMMANDER), {health = 70}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SPRINGSHELL), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_YELLOWSHELL), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SKIM), {health = 80}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_CRUSHSTACEAN), {health = 80}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_JETJAW), {health = 50}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BIGMINE), {health = 40}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_BANPYURA), {health = 80}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_FACESTABBER), {health = 175}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_FACESTABBERSPEAR), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_ROBOHOOD), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_EGGGUARD), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_GSNAPPER), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_VULTURE), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_POINTY), {health = 80}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_MINUS), {health = 40}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_CANARIVORE), {health = 50}, {dmg = 80})
HL_SetMTStats(safeGetMT(MT_UNIDUS), {health = 80}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_PYREFLY), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_PTERABYTE), {health = 60}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_DRAGONBOMBER), {health = 70}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_JETTBOMBER), {health = 70}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_JETTGUNNER), {health = 70}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SNAILER), {health = 80}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SPINCUSHION), {health = 80}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_PENGUINATOR), {health = 80}, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_POPHAT), {health = 70}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_CACOLANTERN), {health = 70}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_HIVEELEMENTAL), {health = 70}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BUMBLEBORE), {health = 30}, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_SPINBOBERT), {health = 40}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_HANGSTER), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BUGGLE), {health = 30}, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_GOOMBA), {health = 40}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_BLUEGOOMBA), {health = 40}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_FANG),         {health = 180}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE),      {health = 300}, {dmg = 1})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE2),     {health = 420}, {dmg = 1})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE3),     {health = 540}, {dmg = 1})  -- Sea Egg rebalanced
HL_SetMTStats(safeGetMT(MT_EGGMOBILE4),     {health = 660}, {dmg = 1})
HL_SetMTStats(safeGetMT(MT_METALSONIC_BATTLE), {health = 780}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_CYBRAKDEMON),    {health = 900}, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_CYBRAKDEMON_ELECTRIC_BARRIER), nil, {dmg = 1000})
HL_SetMTStats(safeGetMT(MT_ROSY), {health = 30})
HL_SetMTStats(safeGetMT(MT_PLAYER), {health = 100})
--projectiles
HL_SetMTStats(safeGetMT(MT_REDRING), nil, {dmg = 6})
HL_SetMTStats(safeGetMT(MT_THROWNBOUNCE), nil, {dmg = 3})
HL_SetMTStats(safeGetMT(MT_THROWNAUTOMATIC), nil, {dmg = 9})
HL_SetMTStats(safeGetMT(MT_THROWNSCATTER), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_THROWNGRENADE), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_THROWNEXPLOSION), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_CORK), nil, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_ROCKET), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_LASER), nil, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_TORPEDO), nil, {dmg = 35})
HL_SetMTStats(safeGetMT(MT_TORPEDO2), nil, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_ENERGYBALL), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_MINE), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_JETTBULLET), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_TURRETLASER), nil, {dmg = 3})
HL_SetMTStats(safeGetMT(MT_ARROW), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_DEMONFIRE), nil, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_CANNONBALL), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_RING), {healh = INT32_MAX}, {dmg = 40})

local function weightedRandom(chances) -- returns one random entry based on the weighted chances
	local total = 0
	for _, entry in ipairs(chances) do
		total = total + tonumber(entry.chance)
	end
	local r = P_RandomFixed() * total
	local highestChanceEntry
	for _, entry in ipairs(chances) do
		if not highestChanceEntry or entry.chance > highestChanceEntry.chance then
			highestChanceEntry = entry
		end
		r = r - tonumber(entry.chance)
		if r <= 0 then
			return entry
		end
	end
	return highestChanceEntry -- Ensures a valid return value
end

local function removeFromChanceList(chances, toremove) -- get a new weighted chance, without some specific item
	local newList = {}
	local dudChance = 0
	local otherItems = 0

	-- separate the dud and count the non-dud entries
	for _, entry in ipairs(chances) do
		if entry.name == toremove then
			dudChance = tonumber(entry.chance)
		else
			otherItems = otherItems + 1
			-- copy the entry to avoid mutating the original list
			table.insert(newList, { name = entry.name, chance = tonumber(entry.chance) })
		end
	end

	-- add an equal share of the dud's chance to every remaining weapon
	local bonus = dudChance / otherItems
	for _, entry in ipairs(newList) do
		entry.chance = entry.chance + bonus
	end

	return newList
end

rawset(_G, "HL_InitHealth", function(mobj) -- Sets up mobjs.
	HL.valuemodes["HLGetObjectHealth"] = HL_LASTFUNC
	local health = HL.RunHook("HLGetObjectHealth", mobj)
	if health == nil
	if (mobj.skin == "scieinstein" or mobj.skin == "scinerd" or mobj.skin == "sciluther" or mobj.skin == "scislick")
		mobj.hl1health = 20 -- 20 HP for scientist users.
	else
		mobj.hl1health = $ or (HL1_DMGStats[mobj.type] and HL1_DMGStats[mobj.type].health) or max(1, FixedInt(FixedSqrt(max(1, FixedDiv(FixedMul(mobj.radius * 2, mobj.height),4*FRACUNIT/3)))))
		if type(mobj.hl1health) == "table"
			mobj.hl1health = $.health
		end
		mobj.hl1armor = 0
	end
	end
	HL.valuemodes["HLGetObjectMaxStats"] = HL_LASTFUNC
	local maxhealth, maxarmor = HL.RunHook("HLGetObjectMaxStats", mobj)
	mobj.hl1maxhealth = maxhealth or 100
	mobj.hl1maxarmor = (maxarmor or 100)*FRACUNIT
end)

rawset(_G, "HL_GetMonitorPickUps", function(chanceList, amount) -- get an amount-length list of weapons, chances determined by chanceList. Main purpose is to get pick-ups dropped by Monitors.
	local results = {}
	for i = 1, amount do
		local selected = weightedRandom(chanceList)
		if selected.name == "crowbar" then -- we got a dud!! make sure we don't rip people off by getting another weapon
			local reweightedList = removeFromChanceList(chanceList, "crowbar")
			selected = weightedRandom(reweightedList)
		end
		table.insert(results, selected)
	end
	return results
end)

local function printTable(data, prefix)
    prefix = prefix or ""
	if not data
		print("No table!")
		return
	end
    for k, v in pairs(data or {}) do
        local key = prefix .. k
        if type(v) == "table" then
            print("key " .. key .. " = a table:")
            printTable(v, key .. ".")
        else
            print("key " .. key .. " = " .. v)
        end
    end
end

-- Helper to extract the numeric suffix from a sentinel string, e.g. "CROWBAR_SWING_1" => 1
local function getSentinelNumber(s, player)
	if not s warn("Invalid state '" .. player.hl1viewmdaction .."'!") printTable(player.hl1currentAnimation, "PRINTOUT: " .. player.hl1viewmdaction .. ".") return 1 end
	local num = s:match("(%d+)$")
	return tonumber(num) or 0
end

local function getFrameData(state, animations)
    -- Split the incoming state string into keys (numbers stay numbers)
    local keys = {}
    for key in state:gmatch("%S+") do
        table.insert(keys, tonumber(key) or key)
    end

    local node = animations
    local pathParts = {}   -- keep the actual key path, for debugging
    local lastValidNode, lastValidKey

    -- Traverse as far as we can
    for _, key in ipairs(keys) do
        if node and node[key] then
            lastValidNode = node
            lastValidKey  = key
            node = node[key]
            table.insert(pathParts, tostring(key))
        else
            break
        end
    end

    -- If we ended up on nil, back up one step
    if not node and lastValidNode and lastValidKey then
        node = lastValidNode[lastValidKey]
    end

    -- Build a dot-style prefix for printTable (e.g. "primaryfire.normal.")
    local prefix = (#pathParts > 0) and (table.concat(pathParts, ".") .. ".") or ""

    -- If this node has *no* numeric keys but *does* have multiple anim-tables,
    -- that means the user stopped at an ambiguous branch—dump them out:
    do
        local hasNumbered = false
        local branches = {}
        for k, v in pairs(node or {}) do
            if type(k) == "number" then
                hasNumbered = true
            elseif type(v) == "table" and v.sentinel and type(v.frameDurations) == "table" then
                table.insert(branches, k)
            end
        end
        if not hasNumbered and #branches > 0 then
            warn("HL_ChangeViewmodelState: State '" .. state .. "' is ambiguous, available sub-states:")
            printTable(node, prefix)
            return nil, nil
        end
    end

    -- If it *is* a list of numbered frames, pick one at random
    if type(node) == "table" then
        local numberedKeys = {}
        for k in pairs(node) do
            if type(k) == "number" then
                table.insert(numberedKeys, k)
            end
        end
        if #numberedKeys > 0 then
            local choice = numberedKeys[P_RandomRange(1, #numberedKeys)]
            table.insert(pathParts, tostring(choice))
            node = node[choice]
        end
    end

    -- Finally check for a valid animation definition
    if type(node) == "table" and node.sentinel and type(node.frameDurations) == "table" then
        return node, table.concat(pathParts, " ")
    else
        warn("HL_ChangeViewmodelState: State '" .. state .. "' is not a valid animation definition!")
        return nil, nil
    end
end

rawset(_G, "HL_ChangeViewmodelState", function(player, action, backup)
    local weapon    = player.hl1weapon
    local viewmodel = kombihl1viewmodels[HL_WpnStats[weapon].viewmodel or "PISTOL"]

    local frameData, realPath = getFrameData(action, viewmodel.animations)
    if not frameData then
        frameData, realPath = getFrameData(backup, viewmodel.animations)
    end
    if not frameData then
        return
    end

    player.hl1viewmdaction    = realPath or action
    player.hl1currentAnimation = frameData
    player.hl1frame           = 0
    player.hl1frameclock      = frameData.frameDurations[1] or 1
end)

local function HL_IsWeaponUsable(player, name)
	local wpnStats = HL_WpnStats[name]
	if not wpnStats then return false end

	-- Primary mode check
	local function isUsable(mode)
		local stats = wpnStats[mode]
		if not stats then return false end

		local clipMode = (mode == "secondary" and stats.altusesprimaryclip) and "primary" or mode
		local curModeStats = wpnStats[clipMode]
		if not curModeStats then return false end

		local clipSize = curModeStats.clipsize or -1
		local ammoType = curModeStats.ammo
		local reserveCount = (ammoType and player.hl1ammo[ammoType]) or 0
		local clipCount = (player.hl1clips[name] and player.hl1clips[name][clipMode]) or 0
		local neverDeny = curModeStats.neverdenyuse

		if clipSize > -1 then
			return clipCount > 0 or reserveCount > 0 or neverDeny
		elseif ammoType and reserveCount >= 0 then
			return reserveCount > 0 or neverDeny
		else
			return true -- infinite ammo
		end
	end

	return isUsable("primary") or isUsable("secondary")
end

rawset(_G, "HL_GetWeapons", function(items, targetSlot, player)
	local filtered = {}
	local filteredweps = {
		usable = {} -- usable entries
	}
	for i = 0, 9 do
		filteredweps[i] = 0
		filteredweps.usable[i] = {}
	end

	if not player then
		local errortype = type(player) == "userdata" and userdataType(player) or type(player)
		error("Bad argument #3 to 'HL_GetWeapons' (PLAYER_T* expected, got "..errortype..")", 2)
		return
	end

	-- Temporary table for normalization per slot
	local slotTables = {}
	for i = 0, 9 do slotTables[i] = {} end

	for name, data in pairs(items) do
		if not data.weaponslot or data.priority == nil then
			if not data.weaponslot then
				warn('Warning: Weapon "' .. data.realname .. '" missing weapon slot!')
				data.weaponslot = 1
			end
			if data.priority == nil then
				warn('Warning: Weapon "' .. data.realname .. '" missing slot priority!')
				data.priority = INT32_MIN
			end
		end

		local slot = data.weaponslot
		if slot >= 0 and slot <= 9 then
			if player.hl1inventory and player.hl1inventory[name] then
				local usable = HL_IsWeaponUsable(player, name)
				filteredweps[slot] = (filteredweps[slot] or 0) + 1

				-- Add to normalization table
				table.insert(slotTables[slot], {
					name = name,
					priority = data.priority,
					usable = usable
				})

				-- If in the selected slot, insert into filtered (which is already sorted below)
				if slot == targetSlot then
					table.insert(filtered, {
						name = name,
						priority = data.priority,
						id = #filtered + 1,
						usable = usable
					})
				end
			end
		else
			warn('Warning: Weapon "' .. data.realname .. '" has an out-of-bounds weaponslot: ' .. slot)
		end
	end

	-- Normalize `usable` entries per slot
	for slot, weps in pairs(slotTables) do
		table.sort(weps, function(a, b)
			return a.priority < b.priority
		end)

		for i, wep in ipairs(weps) do
			filteredweps.usable[slot][i] = wep.usable
		end
	end

	-- Sort the filtered list for the selected slot
	table.sort(filtered, function(a, b)
		return a.priority < b.priority
	end)

	return {
		weapons = filtered,
		weaponcount = (#filtered or 0),
		wepslotamounts = filteredweps
	}
end)

rawset(_G, "HL_AddAmmo", function(freeman, ammotype, ammo) -- give player some munitions
	if not ammotype
		error("Bad argument #2 to 'HL_AddAmmo' (AMMO_T* expected, got '" .. tostring(ammotype) .. "')", 2)
	end

	if not freeman.hl1ammo
		error("HL_AddAmmo called, but no ammo inventory was found for the player!", 2)
	end

	if not freeman.hl1ammo[ammotype]
		freeman.hl1ammo[ammotype] = 0
	end

	local curammo = freeman.hl1ammo[ammotype]
	local maxammo = HL_AmmoStats[ammotype] and HL_AmmoStats[ammotype].max or 0
	if not HL_AmmoStats[ammotype]
		warn("Ammo type '\$ammotype\' doesn't have an associated HL_AmmoStats index!")
	end

	local doubleammo = freeman.hl1doubleammo
	local effectiveMaxAmmo = doubleammo
		and (HL_AmmoStats[ammotype] and HL_AmmoStats[ammotype].backpackmax or maxammo * 2)
		or maxammo

	local spaceleft = effectiveMaxAmmo - curammo
	local actualgain = min(ammo or 0, spaceleft)
	freeman.hl1ammo[ammotype] = curammo + actualgain
	if actualgain > 0
		-- Play pickup sound
		S_StartSound(nil, HL_AmmoStats[ammotype] and HL_AmmoStats[ammotype].pickupsound or sfx_hl1pr2, freeman)

		-- Record pickup history
		table.insert(freeman.pickuphistory, {
			thing = ammotype, -- What did we get?
			count = actualgain, -- How much did we get? Rendered nil for non-ammo pickups.
			type = "ammo", -- What kind?
			time = pickupnotifytime -- Clock
		})
	end

	return actualgain > 0
end)

rawset(_G, "HL_AddWeapon", function(freeman, weapon, silent, autoswitch) -- give some amount of weapon to freeman
	-- Push weapon to the weapon list if not already
	local didsomething = false
	if not freeman.hl1inventory
		error("HL_AddWeapon called, but no inventory was found for the player!", 2)
		return
	end

	if not freeman.hl1inventory[weapon]
		freeman.hl1inventory[weapon] = true

		if not silent
			S_StartSound(nil, HL_WpnStats[weapon].pickupsound or sfx_hlwpnu, freeman)
			table.insert(freeman.pickuphistory, {
				thing = weapon,
				type = "weapon",
				time = pickupnotifytime
			})
		end

		if autoswitch
			freeman.hl1weapon = weapon
		end

		if freeman.kombihl1wpn
			freeman.selectionlist = HL_GetWeapons(HL_WpnStats, freeman.kombihl1category, freeman)
		end

		-- Handle initial clip fill from pickup gift
		freeman.hl1clips = freeman.hl1clips or {}
		freeman.hl1clips[weapon] = freeman.hl1clips[weapon] or {min(HL_WpnStats[weapon].clipsize or 0, 0), min(HL_WpnStats[weapon].clipsizealt or 0, 0)}

		local function handleClipGift(clipIndex, gift, clipsize, ammotype)
			if gift
				if clipsize < 0
					HL_AddAmmo(freeman, ammotype, gift)
				else
					local remaining_gift = gift
					local clip = max(freeman.hl1clips[weapon][clipIndex], 0)
					local space_in_clip = clipsize - clip
					local clip_to_add = min(remaining_gift, space_in_clip)
					freeman.hl1clips[weapon][clipIndex] = clip + clip_to_add
					remaining_gift = remaining_gift - clip_to_add
					-- Defer any excess to HL_AddAmmo
					if remaining_gift > 0 and ammotype
						HL_AddAmmo(freeman, ammotype, remaining_gift)
					end
				end
			end
		end
		if HL_WpnStats[weapon].primary
			if not HL_WpnStats[weapon].primary.ammo
				warn("Weapon " .. weapon .. " missing primary.ammo property!")
			else
				handleClipGift(1, HL_WpnStats[weapon].primary.pickupgift, HL_WpnStats[weapon].primary.clipsize or -1, HL_WpnStats[weapon].primary.ammo)
			end
		end
		if HL_WpnStats[weapon].secondary
			if not HL_WpnStats[weapon].secondary.ammo
				warn("Weapon " .. weapon .. " missing secondary.ammo property!")
			else
				handleClipGift(2, HL_WpnStats[weapon].secondary.pickupgift, HL_WpnStats[weapon].secondary.clipsize or -1, HL_WpnStats[weapon].secondary.ammo)
			end
		end

		didsomething = true -- We gave the player a gun, so we did something there.
	else
		if HL_WpnStats[weapon].primary
			if HL_WpnStats[weapon].primary.pickupgift and HL_WpnStats[weapon].primary.ammo
				didsomething = HL_AddAmmo(freeman, HL_WpnStats[weapon].primary.ammo, HL_WpnStats[weapon].primary.pickupgift) or $
			end
		end
		if HL_WpnStats[weapon].secondary
			if HL_WpnStats[weapon].secondary.pickupgift and HL_WpnStats[weapon].secondary.ammo
				didsomething = HL_AddAmmo(freeman, HL_WpnStats[weapon].secondary.ammo, HL_WpnStats[weapon].secondary.pickupgift) or $
			end
		end
	end

	return didsomething -- Report that something happened for stuff like pick-up removal.
end)

rawset(_G, "HL_TakeWeapon", function(freeman, weapon) -- no more weapon privileges
	local didsomething = false
	if not freeman.hl1inventory error("HL_TakeWeapon called, but no inventory was found for the player!", 2) return end
	if not weapon
		freeman.hl1inventory = {}
		if freeman.kombihl1wpn
			freeman.selectionlist = HL_GetWeapons(HL_WpnStats, freeman.kombihl1category, freeman)
		end
		didsomething = true
	else
		if freeman.hl1inventory[weapon]
			freeman.hl1inventory[weapon] = false
			if freeman.kombihl1wpn
				freeman.selectionlist = HL_GetWeapons(HL_WpnStats, freeman.kombihl1category, freeman)
			end
			didsomething = true
		end
	end
	return didsomething
end)

rawset(_G, "HL_TakeAmmo", function(freeman, ammotype, ammocount) -- remove some amount of ammo from freeman
	if not freeman.hl1ammo error("HL_TakeAmmo called, but no ammo inventory was found for the player!", 2) return end
	ammocount = ammocount or 0
	if not ammotype and not ammocount
		freeman.hl1ammo = {}
		return
	end
	if not ammotype
		for atype, acount in pairs(freeman.hl1ammo) do
			freeman.hl1ammo[atype] = acount - ammocount
		end
	else
		freeman.hl1ammo[ammotype] = (freeman.hl1ammo[ammotype] or 0) - ammocount
	end
end)

rawset(_G, "HL_TakeClip", function(player, weapon, amount, alt) -- remove some amount of clip from freeman
	if weapon == nil
		for weapName, clips in pairs(player.hl1clips) do
			if alt == nil -- search for SPECIFICALLY nil.
				if amount
					player.hl1clips[weapName].primary = max(player.hl1clips[weapName].primary - amount, 0)
					player.hl1clips[weapName].secondary = max(player.hl1clips[weapName].secondary - amount, 0)
				else
					player.hl1clips[weapName].primary = 0
					player.hl1clips[weapName].secondary = 0
				end
			elseif alt
				if amount
					player.hl1clips[weapName].secondary = max(player.hl1clips[weapName].secondary - amount, 0)
				else
					player.hl1clips[weapName].secondary = 0
				end
			else
				if amount
					player.hl1clips[weapName].primary = max(player.hl1clips[weapName].primary - amount, 0)
				else
					player.hl1clips[weapName].primary = 0
				end
			end
		end
	else
		if player.hl1clips[weapon]
			if alt == nil
				if amount
					player.hl1clips[weapon].primary = max(player.hl1clips[weapon].primary - amount, 0)
					player.hl1clips[weapon].secondary = max(player.hl1clips[weapon].secondary - amount, 0)
				else
					player.hl1clips[weapon].primary = 0
					player.hl1clips[weapon].secondary = 0
				end
			elseif alt
				if amount
					player.hl1clips[weapon].secondary = max(player.hl1clips[weapon].secondary - amount, 0)
				else
					player.hl1clips[weapon].secondary = 0
				end
			else
				if amount
					player.hl1clips[weapon].primary = max(player.hl1clips[weapon].primary - amount, 0)
				else
					player.hl1clips[weapon].primary = 0
				end
			end
		else
			print("Invalid weapon: " .. tostring(weapon))
		end
	end
end)

addHook("TouchSpecial", function(item, mobj)
	if mobj.skin != "kombifreeman" then return end
	local player = mobj.player
	local stats = HL_PickupStats[item.type]
	if not stats return end
	local isAKeeper = true

	if stats.health
		if mobj.hl1health < (stats.health.limit or mobj.hl1maxhealth)
			if stats.health.give
				mobj.hl1health = $ + stats.health.give
				isAKeeper = false
			elseif stats.health.set
				mobj.hl1health = stats.health.set
				isAKeeper = false
			else
				error("Requested pickup has a health list, but no give or set sub-list entries!", 1)
			end
			table.insert(player.pickuphistory, {
				thing = "medikit", -- What did we get?
				type = "special", -- What kind?
				time = pickupnotifytime -- Clock
			})
			mobj.hl1health = min(mobj.hl1health, FixedMul(mobj.hl1maxhealth, stats.health.maxmult) or stats.health.limit or mobj.hl1maxhealth)
		end
	end

	if stats.armor
		if mobj.hl1armor < ((stats.armor.limit or 0) * FRACUNIT or mobj.hl1maxarmor)
			if stats.armor.give
				mobj.hl1armor = $ + stats.armor.give * FRACUNIT
				isAKeeper = false
			elseif stats.armor.set
				mobj.hl1armor = stats.armor.set * FRACUNIT
				isAKeeper = false
			else
				error("Requested pickup has an armor list, but no give or set sub-list entries!", 1)
			end
			table.insert(player.pickuphistory, {
				thing = "hevbattery", -- What did we get?
				type = "special", -- What kind?
				time = pickupnotifytime -- Clock
			})
			mobj.hl1armor = min(mobj.hl1armor, FixedMul(mobj.hl1maxarmor, stats.armor.maxmult) or (stats.armor.limit or 0) * FRACUNIT or mobj.hl1maxarmor)
		end
	end

	if stats.ammo
		-- Handle multiple ammo types from backpack pickup
		if type(stats.ammo.type) == "table" and type(stats.ammo.give) == "table"
			for i, ammoType in ipairs(stats.ammo.type) do
				local ammoGive = stats.ammo.give[i]
				if ammoGive and HL_AddAmmo(player, ammoType, ammoGive)
					isAKeeper = false
				end
			end
		-- Handle single ammo type pickup
		elseif stats.ammo.type and stats.ammo.give
			if HL_AddAmmo(player, stats.ammo.type, stats.ammo.give)
				isAKeeper = false
			end
		else
			error("Requested pickup has an ammo list, but no valid give or type sub-list entries!", 1)
		end
	end

	if stats.weapon
		if type(stats.weapon) == "table"
			for _, weaponType in ipairs(stats.weapon) do
				if HL_AddWeapon(player, weaponType)
					isAKeeper = false
				end
			end
		elseif HL_AddWeapon(player, stats.weapon, false, true)
			isAKeeper = false
		end
	end

	if stats.invuln
		player.powers[pw_invulnerability] = stats.invuln.set
		isAKeeper = false
	end

	if stats.doubleammo and not player.hl1doubleammo
		player.hl1doubleammo = true
	end

	if stats.berserk
		player.hl1berserk = INT32_MAX
		isAKeeper = false
	end

	if not isAKeeper
		P_RemoveMobj(item)
	end
end)