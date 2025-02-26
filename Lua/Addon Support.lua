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
		realname = "Pistol (Wolfenstein 3D)",
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
		realname = "Minigun (Wolfenstein 3D)",
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
		realname = "Chaingun (Wolfenstein 3D)",
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