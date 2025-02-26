local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

local function warn(str)
	print("\131WARNING: \128"..str);
end

local function notice(str)
	print("\x83NOTICE: \x80"..str);
end

local pickupnotifytime = TICRATE*3

rawset(_G, "DMG", { -- TYPEOFDAMAGE
	GENERIC = 0,
	CRUSH = 1,
	BULLET = 2,
	SLASH = 4,
	BURN = 8,
	FREEZE = 16,
	FALL = 32,
	BLAST = 64,
	CLUB = 128,
	ELEC = 256,
	SUPERSONIC = 512,
	ENERGYBEAM = 1024,
	DIRECT = 2048,
	DROWN = 4096,
	PARALYZE = 8192,
	NERVEGAS = 16384,
	POISON = 32768,
	RADIATION = 65536,
	DROWNRECOVER = 131072,
	ACID = 262144,
	SLOWBURN = 524288,
	REMOVEONDEATH = 1048576,
	PLASMA = 2097152,
	EXPLOSION_WATER = 4194304,
	BUCKSHOT = 8388608,
})

rawset(_G, "HL_GetWeapons", function(items, targetSlot, player) -- gets all available weapons.
	local filtered = {}
	local filteredweps = {0,0,0,0,0,0,0}
	if not player
		local errortype = type(player) == "userdata" and userdataType(player) or type(player)
		error("Bad argument #3 to 'HL_GetWeapons' (PLAYER_T* expected, got \$errortype\)", 2)
		return
	end
	for name, data in pairs(items) do
		if player.hl1inventory and player.hl1inventory[name]
			filteredweps[data.weaponslot] = ($ or 0)+1
			if data.weaponslot == targetSlot
				table.insert(filtered, {name = name, priority = data.priority, id = #filtered+1})
			end
		end
	end
	table.sort(filtered, function(a, b)
		return a.priority < b.priority
	end)
	return {["weapons"] = filtered, ["weaponcount"] = #filtered, ["wepslotamounts"] = filteredweps}
end)

rawset(_G, "HL_AddAmmo", function(freeman, ammotype, ammo) -- give player some munitions
	if not ammotype
		error("Bad argument #2 to 'HL_AddAmmo' (AMMO_T* expected, got " .. type(ammotype) .. ")", 2)
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

rawset(_G, "HL_AddWeapon", function(freeman, weapon, silent, autoswitch)
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
					print(ammotype, clip, space_in_clip, clip_to_add, freeman.hl1clips[weapon][clipIndex])
					remaining_gift = remaining_gift - clip_to_add
					-- Defer any excess to HL_AddAmmo
					if remaining_gift > 0 and ammotype
						HL_AddAmmo(freeman, ammotype, remaining_gift)
					end
				end
			end
		end

		handleClipGift(1, HL_WpnStats[weapon].pickupgift, HL_WpnStats[weapon].clipsize or -1, HL_WpnStats[weapon].ammo)
		handleClipGift(2, HL_WpnStats[weapon].pickupgiftalt, HL_WpnStats[weapon].clipsizealt or -1, HL_WpnStats[weapon].ammoalt)

		didsomething = true -- We gave the player a gun, so we did something there.
	else
		if HL_WpnStats[weapon].pickupgift and HL_WpnStats[weapon].ammo
			didsomething = HL_AddAmmo(freeman, HL_WpnStats[weapon].ammo, HL_WpnStats[weapon].pickupgift) or $
		end
		if HL_WpnStats[weapon].pickupgiftalt and HL_WpnStats[weapon].ammoalt
			didsomething = HL_AddAmmo(freeman, HL_WpnStats[weapon].ammoalt, HL_WpnStats[weapon].pickupgiftalt) or $
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

rawset(_G, "HL_TakeAmmo", function(freeman, ammotype, ammocount) 
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

rawset(_G, "HL_TakeClip", function(player, weapon, amount, alt)
	if weapon == nil
		for weapName, clips in pairs(player.hl1clips) do
			if alt == nil -- search for SPECIFICALLY nil.
				if amount
					player.hl1clips[weapName][1] = max(player.hl1clips[weapName][1] - amount, 0)
					player.hl1clips[weapName][2] = max(player.hl1clips[weapName][2] - amount, 0)
				else
					player.hl1clips[weapName][1] = 0
					player.hl1clips[weapName][2] = 0
				end
			elseif alt
				if amount
					player.hl1clips[weapName][2] = max(player.hl1clips[weapName][2] - amount, 0)
				else
					player.hl1clips[weapName][2] = 0
				end
			else
				if amount
					player.hl1clips[weapName][1] = max(player.hl1clips[weapName][1] - amount, 0)
				else
					player.hl1clips[weapName][1] = 0
				end
			end
		end
	else
		if player.hl1clips[weapon]
			if alt == nil
				if amount
					player.hl1clips[weapon][1] = max(player.hl1clips[weapon][1] - amount, 0)
					player.hl1clips[weapon][2] = max(player.hl1clips[weapon][2] - amount, 0)
				else
					player.hl1clips[weapon][1] = 0
					player.hl1clips[weapon][2] = 0
				end
			elseif alt
				if amount
					player.hl1clips[weapon][2] = max(player.hl1clips[weapon][2] - amount, 0)
				else
					player.hl1clips[weapon][2] = 0
				end
			else
				if amount
					player.hl1clips[weapon][1] = max(player.hl1clips[weapon][1] - amount, 0)
				else
					player.hl1clips[weapon][1] = 0
				end
			end
		else
			print("Invalid weapon: " .. tostring(weapon))
		end
	end
end)

SafeFreeSlot("sfx_hlwpnu")

addHook("TouchSpecial", function(item, mobj)
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
				type = "weapon", -- What kind?
				time = pickupnotifytime -- Clock
			})
			mobj.hl1health = min(mobj.hl1health, stats.health.limit or mobj.hl1maxhealth)
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
				type = "weapon", -- What kind?
				time = pickupnotifytime -- Clock
			})
			mobj.hl1armor = min(mobj.hl1armor, (stats.armor.limit or 0) * FRACUNIT or mobj.hl1maxarmor)
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

local function HL_GetAndSetDGStuff()
	if doomclient and doomgameplay and doomcheats -- make REAL good sure we have Doomguy installed.
	HL_PickupStats = {
		[MT_ITEM_STIMPACK] = {
			health = {give = 10}
		},
		[MT_ITEM_HEALTHPACK] = {
			health = {give = 25}
			
		},
		[MT_ITEM_COMBAT_ARMOR] = {
			armor = {set = 200, limit = 200}
		},
		[MT_ITEM_SECURITY_ARMOR] = {
			armor = {set = 100, limit = 100}
		},
		[MT_ITEM_SOUL] = {
			health = {give = 100, limit = 200}
		},
		[MT_ITEM_MEGA] = {
			health = {set = 200, limit = 200},
			armor = {set = 200, limit = 200}
		},
		[MT_ITEM_INVULNERABILITY] = {
			invuln = {set = 20*TICRATE}
		},
		[MT_POWERUP_BERSERK] = {
			berserk = INT32_MAX,
		},
		[MT_POWERUP_BACKPACK] = {
			ammo = {type = {
				"bull",
				"shel",
				"rckt",
				"cell"
				},
				give = {
				10,
				4,
				1,
				20
				},
			},
			doubleammo = true,
		},
		[MT_ITEM_HEALTH] = {
			health = {give = 1, limit = 200}
		},
		[MT_ITEM_ARMOR] = {
			armor = {give = 1, limit = 200}
		},
		[MT_AMMO_CLIP] = {
			ammo = {type = "bull", give = 10}
		},
		[MT_AMMO_CLIP_BOX] = {
			ammo = {type = "bull", give = 50}
		},
		[MT_AMMO_SHELL] = {
			ammo = {type = "shel", give = 4}
		},
		[MT_AMMO_SHELL_BOX] = {
			ammo = {type = "shel", give = 20}
		},
		[MT_AMMO_ROCKET] = {
			ammo = {type = "rckt", give = 1}
		},
		[MT_AMMO_ROCKET_BOX] = {
			ammo = {type = "rckt", give = 5}
		},
		[MT_AMMO_CELL] = {
			ammo = {type = "cell", give = 20}
		},
		[MT_AMMO_CELL_PACK] = {
			ammo = {type = "cell", give = 200}
		},
		[MT_WEAPON_CHAINSAW] = {
			weapon = "doomchainsaw"
		},
		[MT_WEAPON_PISTOL] = {
			weapon = "doompistol"
		},
		[MT_WEAPON_SHOTGUN] = {
			weapon = "doomshotgun"
		},
		[MT_WEAPON_SUPERSHOTGUN] = {
			weapon = "doomsupershotgun"
		},
		[MT_WEAPON_CHAINGUN] = {
			weapon = "doomchaingun"
		},
		[MT_WEAPON_ROCKETLAUNCHER] = {
			weapon = "doomrpg"
		},
		[MT_WEAPON_PLASMARIFLE] = {
			weapon = "doomplasmarifle"
		},
		[MT_WEAPON_BFG9000] = {
			weapon = "doombfg9000"
		},
	}
	HL_WpnStats["doomchainsaw"] = 
		{
		viewmodel = "DOOMWP2-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		["neverdenyuse"] = true,
		weaponslot = 1,
		priority = 999,
		ammo = "melee",
		volley = 2,
		clipsize = WEAPON_NONE,
		shotcost = 0,
		damage = 2*P_RandomRange(1,10),
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_sawful,
		pickupsound = sfx_wpnup,
		switchsound = sfx_sawup,
		hitsound = sfx_sawhit,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 10,
		maxdistance = 16,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 4,
		},
		realname = "Chainsaw (DOOM)",
	}
	HL_WpnStats["doompistol"] = 
		{
		viewmodel = "DOOMWP2-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 2,
		priority = 999,
		ammo = "bull", -- Holy shit, DoomGuy uses live bulls as ammunition?! (no
		refireusesspread = true,
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5*P_RandomRange(1,3),
		horizspread = 11*FRACUNIT/2,
		vertspread = 11*FRACUNIT/2,
		firesound = sfx_pist,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 10,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 14,
		},
		realname = "Pistol (DOOM)",
	}
	HL_WpnStats["doomshotgun"] = 
		{
		viewmodel = "DOOMWP3-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 3,
		priority = 999,
		ammo = "shel",
		pellets = 7,
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5*P_RandomRange(1,3),
		horizspread = 11*FRACUNIT/2,
		vertspread = 11*FRACUNIT/2,
		firesound = sfx_ssg,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 4,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 41,
		},
		realname = "Shotgun (DOOM)",
	}
	HL_WpnStats["doomsupershotgun"] = 
		{
		viewmodel = "DOOMWP3A-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 3,
		priority = 998,
		ammo = "shel",
		pellets = 20,
		clipsize = WEAPON_NONE,
		shotcost = 2,
		damage = 5*P_RandomRange(1,3),
		horizspread = 11*FRACUNIT/2,
		vertspread = 11*FRACUNIT/2,
		firesound = sfx_sht,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 4,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 48,
		},
		realname = "Super Shotgun",
	}
	HL_WpnStats["doomchaingun"] = 
		{
		viewmodel = "DOOMWP4-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 4,
		priority = 999,
		ammo = "bull",
		refireusesspread = true,
		volley = 2,
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5*P_RandomRange(1,3),
		horizspread = 11*FRACUNIT/2,
		vertspread = 11*FRACUNIT/2,
		firesound = sfx_pist,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 10,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 4,
		},
		realname = "Chaingun",
	}
	HL_WpnStats["doomrpg"] = 
		{
		viewmodel = "DOOMWP3-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 5,
		priority = 999,
		ammo = "rckt",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 20*P_RandomRange(1,8),
		["explosionradius"] = 128,
		["safety"] = true,
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_rklaun,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 2,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 18,
		},
		realname = "Rocket Launcher (DOOM)",
	}
	HL_WpnStats["doomplasmarifle"] = 
		{
		viewmodel = "DOOMWP3-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 6,
		priority = 999,
		ammo = "cell",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5*P_RandomRange(1,8),
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_plasma,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 100,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 3,
			["pause"] = 20,
		},
		realname = "Plasma Rifle",
	}
	HL_WpnStats["doombfg9000"] = -- UNFINISHED!!
		{
		viewmodel = "DOOMWP3-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 7,
		priority = 999,
		ammo = "cell",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 100*P_RandomRange(1,8),
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_bfg,
		pickupsound = sfx_wpnup,
		autoreload = true,
		vmdlflip = false,
		pickupgift = 100,
		["firedelay"] = {
			["ready"] = 14,
			["normal"] = 40,
			["pause"] = 30,
		},
		realname = "BFG9000",
	}
	end
end

local function mobjtype_exists_aux(mt) return _G[mt] end
local function MobjTypeExists(mt) return pcall(mobjtype_exists_aux, mt) end -- pcall ensures we can continue executing code even if the mobjtype doesn't exist

local function HL_GetAndSetW3DStuff()
	if not MobjTypeExists(MT_WOLFCGUNPICKUP) return end
	HL_WpnStats["wolf3dpistol"] = -- UNFINISHED!!
		{
		viewmodel = "WOLFWP2-",
		crosshair = "XHRPIS",
		nobob = true,
		doomweaponraise = true,
		weaponslot = 7,
		priority = 999,
		ammo = "wolfbullet",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5,
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_wpist,
		pickupsound = sfx_wammo,
		vmdlflip = false,
		pickupgift = 4,
		["firedelay"] = {
			["ready"] = 8,
			["normal"] = 12,
		},
		realname = "BFG9000",
	}
	HL_WpnStats["wolf3dminigun"] = -- UNFINISHED!!
		{
		viewmodel = "WOLFWP3-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 7,
		priority = 999,
		ammo = "wolfbullet",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 5,
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_wmgun,
		pickupsound = sfx_wmgpic,
		vmdlflip = false,
		pickupgift = 4,
		["firedelay"] = {
			["ready"] = 8,
			["normal"] = 8,
		},
		realname = "BFG9000",
	}
	HL_WpnStats["wolf3dchaingun"] = -- UNFINISHED!!
		{
		viewmodel = "WOLFWP4-",
		crosshair = "XHRPIS",
		doombob = true,
		doomweaponraise = true,
		weaponslot = 7,
		priority = 999,
		ammo = "wolfbullet",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		damage = 10,
		horizspread = 0,
		vertspread = 0,
		firesound = sfx_wcgun,
		pickupsound = sfx_wcgpic,
		vmdlflip = false,
		pickupgift = 8,
		["firedelay"] = {
			["ready"] = 8,
			["normal"] = 8,
		},
		realname = "BFG9000",
	}
end

HL_GetAndSetDGStuff()

addHook("AddonLoaded", function()
	if OLDC and OLDC.SkinFullNames and not OLDC.SkinFullNames["kombifreeman"]
		if P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "JOHN HALFLIFE"
		elseif P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "GORDON FREEMAN THE THRORETICAL PHYSICIST"
		elseif P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "GORDON THE FREEMAN"
		else
			OLDC.SkinFullNames["kombifreeman"] = "GORDON FREEMAN"
		end
	end
	HL_GetAndSetDGStuff()
end)