local function safeGetMT(mt)
	local success, value = pcall(function() return mt end)
	return success and value or nil
end

local function HL_CreateItem(mt, stats)
	local mobj = type(mt) == "string" and _G[mt] or mt
	if not mobj return end
	HL_PickupStats[mobj] = stats
end
local function HL_DefineWeapon(name, stats)
	HL_WpnStats[name] = stats
end

local function CheckAddons()
	-- DOOM:
	HL_CreateItem(safeGetMT(MT_ITEM_STIMPACK), {health = {give = 10}})
	HL_CreateItem(safeGetMT(MT_ITEM_HEALTHPACK), {health = {give = 25}})
	HL_CreateItem(safeGetMT(MT_ITEM_COMBAT_ARMOR), {armor = {set = "limit", maxmult = FRACUNIT*2}})
	HL_CreateItem(safeGetMT(MT_ITEM_SECURITY_ARMOR), {armor = {set = "limit", maxmult = FRACUNIT}})
	HL_CreateItem(safeGetMT(MT_ITEM_SOUL), {health = {give = "maxhp", maxmult = FRACUNIT*2}})
	HL_CreateItem(safeGetMT(MT_ITEM_MEGA), {health = {give = "limit", maxmult = FRACUNIT*2}, armor = {give = "limit", maxmult = FRACUNIT*2}})
	HL_CreateItem(safeGetMT(MT_ITEM_INVULNERABILITY), {invuln = {set = 20*TICRATE}})
	HL_CreateItem(safeGetMT(MT_POWERUP_BERSERK), {berserk = INT32_MAX})
	HL_CreateItem(safeGetMT(MT_POWERUP_BACKPACK), {ammo = {type = {"bull","shel","rckt","cell"}, give = {10,4,1,20}}, doubleammo = true})
	HL_CreateItem(safeGetMT(MT_ITEM_HEALTH), {health = {give = 1, maxmult = FRACUNIT*2}})
	HL_CreateItem(safeGetMT(MT_ITEM_ARMOR), {armor = {give = 1, maxmult = FRACUNIT*2}})
	HL_CreateItem(safeGetMT(MT_AMMO_CLIP), {ammo = {type = "bull", give = 10}})
	HL_CreateItem(safeGetMT(MT_AMMO_CLIP_BOX), {ammo = {type = "bull", give = 50}})
	HL_CreateItem(safeGetMT(MT_AMMO_SHELL), {ammo = {type = "shel", give = 4}})
	HL_CreateItem(safeGetMT(MT_AMMO_SHELL_BOX), {ammo = {type = "shel", give = 20}})
	HL_CreateItem(safeGetMT(MT_AMMO_ROCKET), {ammo = {type = "rckt", give = 1}})
	HL_CreateItem(safeGetMT(MT_AMMO_ROCKET_BOX), {ammo = {type = "rckt", give = 5}})
	HL_CreateItem(safeGetMT(MT_AMMO_CELL), {ammo = {type = "cell", give = 20}})
	HL_CreateItem(safeGetMT(MT_AMMO_CELL_PACK), {ammo = {type = "cell", give = 200}})
	HL_CreateItem(safeGetMT(MT_WEAPON_CHAINSAW), {weapon = "doomchainsaw"})
	HL_CreateItem(safeGetMT(MT_WEAPON_PISTOL), {weapon = "doompistol"})
	HL_CreateItem(safeGetMT(MT_WEAPON_SHOTGUN), {weapon = "doomshotgun"})
	HL_CreateItem(safeGetMT(MT_WEAPON_SUPERSHOTGUN), {weapon = "doomsupershotgun"})
	HL_CreateItem(safeGetMT(MT_WEAPON_CHAINGUN), {weapon = "doomchaingun"})
	HL_CreateItem(safeGetMT(MT_WEAPON_ROCKETLAUNCHER), {weapon = "doomrpg"})
	HL_CreateItem(safeGetMT(MT_WEAPON_PLASMARIFLE), {weapon = "doomplasmarifle"})
	HL_CreateItem(safeGetMT(MT_WEAPON_BFG9000), {weapon = "doombfg9000"})

	if DoomGuy
		HL_DefineWeapon("doomchainsaw", {
			viewmodel = "DOOMWP2-",
			weaponclass = "doom",
			neverdenyuse = true,
			weaponslot = 1,
			priority = 999,
			primary = {
				ammo = "melee",
				clipsize = WEAPON_NONE,
				shotcost = 0,
				damagemin = 2,
				damagemax = 20,
				damageincs = 2,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_sawful,
				firedelay = 4,
			},
			pickupsound = sfx_wpnup,
			switchsound = sfx_sawup,
			hitsound = sfx_sawhit,
			autoreload = true,
			pickupgift = 10,
			maxdistance = 16,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Chainsaw (DOOM)",
		})
		HL_DefineWeapon("doompistol", {
			viewmodel = "DOOMWP2-",
			weaponclass = "doom",
			weaponslot = 2,
			priority = 999,
			primary = {
				ammo = "bull", -- Holy shit, DoomGuy uses live bulls as ammunition?! (no
				refireusesspread = true,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_pist,
				firedelay = 14,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 10,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Pistol (DOOM)",
		})
		HL_DefineWeapon("doomshotgun", {
			viewmodel = "DOOMWP3-",
			weaponclass = "doom",
			weaponslot = 3,
			priority = 999,
			primary = {
				ammo = "shel",
				pellets = 7,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_ssg,
				firedelay = 41,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 4,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Shotgun (DOOM)",
		})
		HL_DefineWeapon("doomsupershotgun", {
			viewmodel = "DOOMWP3A-",
			weaponclass = "doom",
			weaponslot = 3,
			priority = 998,
			primary = {
				ammo = "shel",
				pellets = 20,
				clipsize = WEAPON_NONE,
				shotcost = 2,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_sht,
				firedelay = 48,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 4,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Super Shotgun",
		})
		HL_DefineWeapon("doomchaingun", {
			viewmodel = "DOOMWP4-",
			weaponclass = "doom",
			weaponslot = 4,
			priority = 999,
			primary = {
				ammo = "bull",
				refireusesspread = true,
				volley = 2,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_pist,
				firedelay = 4,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 10,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Chaingun",
		})
		HL_DefineWeapon("doomrpg", {
			viewmodel = "DOOMWP3-",
			weaponclass = "doom",
			weaponslot = 5,
			priority = 999,
			primary = {
				ammo = "rckt",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 20,
				damagemax = 160,
				damageincs = 20,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_rklaun,
				firedelay = 18,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 2,
			globalfiredelay = {
				ready = 14,
			},
			realname = "Rocket Launcher (DOOM)",
		})
		HL_DefineWeapon("doomplasmarifle", {
			viewmodel = "DOOMWP3-",
			weaponclass = "doom",
			weaponslot = 6,
			priority = 999,
			primary = {
				ammo = "cell",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 40,
				damageincs = 5,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_plasma,
				firedelay = 3,
			},
			pickupsound = sfx_wpnup,
			pickupgift = 100,
			globalfiredelay = {
				ready = 14,
				firepost = 20,
			},
			realname = "Plasma Rifle",
		})
		HL_DefineWeapon("doombfg9000", { -- UNFINISHED!!
			viewmodel = "DOOMWP3-",
			weaponclass = "doom",
			weaponslot = 7,
			priority = 999,
			primary = {
				firefunc = function(player, mystats)
				
				end,
				ammo = "cell",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 100,
				damagemax = 800,
				damageincs = 100,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_bfg,
				firedelay = 40,
			},
			pickupsound = sfx_wpnup,
			autoreload = true,
			vmdlflip = false,
			pickupgift = 100,
			globalfiredelay = {
				ready = 14,
				tilshot = 30,
			},
			realname = "BFG9000",
		})
	end

	-- SONIC DOOM II:
	HL_SetMTStats(safeGetMT(MT_SD2_BUZZBOMBER), {health = 400, dmgdmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT(MT_SD2_COCONUTS), {health = 60, dmgmult = 2*FRACUNIT, flinches = true}, {min = 8, max = 24, increments = 8})
	HL_SetMTStats(safeGetMT(MT_SD2_GROUNDER_PISTOL), {health = 20, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_GROUNDER_SHOTGUN), {health = 30, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_GROUNDER_CHAINGUN), {health = 30, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_METALSONIC), {health = 700, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_PSEUDOKNUCKLES), {health = 300, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_PSEUDOFLICKY), {health = 300, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 24, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_PSEUDOTAILS), {health = 400, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 24, increments = 3})
	HL_SetMTStats(safeGetMT(MT_SD2_VILE_FIRE), 0, {dmg = 90})
	HL_SetMTStats(safeGetMT(MT_SD2_OVASHORT), {health = 150, dmgmult = 2*FRACUNIT, flinches = true}, {min = 4, max = 40, increments = 4})
	HL_SetMTStats(safeGetMT(MT_SD2_OVASHORT_SHADOW), {health = 150, dmgmult = 2*FRACUNIT, flinches = true}, {min = 4, max = 40, increments = 4})
	HL_SetMTStats(safeGetMT(MT_SD2_OVASHOT), 0, {min = 8, max = 64, increments = 8})
	HL_SetMTStats(safeGetMT(MT_SD2_OVARED), {health = 1000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT(MT_SD2_OVAGRAY), {health = 1000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT(MT_SD2_PSEUDOSUPER), {health = 500, dmgmult = 2*FRACUNIT, flinches = true}, 0)
	HL_SetMTStats(safeGetMT(MT_SD2_PSEUDOSUPER_BALL), 0, {min = 5, max = 40, increments = 5})
	HL_SetMTStats(safeGetMT(MT_SD2_REDMETALSONIC), {health = 4000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT(MT_SD2_ROCKET), 0, {min = 20, max = 160, increments = 20})
	
	/* -- TODO: port to new system.
	-- WOLF3D:
	if rawget(_G, "MT_WOLFCAMERA")
		HL_DefineWeapon("wolf3dpistol", {
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
			globalfiredelay = {
				ready = 8,
				["normal"] = 12,
			},
			realname = "Pistol (Wolfenstein 3D)",
		})
		HL_DefineWeapon("wolf3dminigun", {
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
			globalfiredelay = {
				ready = 8,
				["normal"] = 8,
			},
			realname = "Minigun (Wolfenstein 3D)",
		})
		HL_DefineWeapon("wolf3dchaingun", {
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
			globalfiredelay = {
				ready = 8,
				["normal"] = 8,
			},
			realname = "Chaingun (Wolfenstein 3D)",
		})
	end
	*/
end

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
	CheckAddons()
end)

CheckAddons()