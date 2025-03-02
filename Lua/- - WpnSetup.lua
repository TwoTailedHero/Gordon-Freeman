local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

SafeFreeSlot("SPR_LEGOBATTLESPROJ","S_KOMBI_SHURIKEN",
"S_KOMBI_BULLETHOLE",
"S_KOMBI_SNARKDIE",
"MT_HL1_BULLET",
"MT_HL1_BOLT",
"MT_HL1_ARGRENADE",
"MT_HL1_ROCKET",
"MT_HL1_HANDGRENADE",
"MT_HL1_SATCHEL",
"MT_HL1_TRIPMINE",
"MT_HL1_SNARK",
"MT_HL1_HORNET")

states[S_KOMBI_SHURIKEN] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_SHURIKEN
}

states[S_KOMBI_BULLETHOLE] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A|FF_PAPERSPRITE,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_BULLETHOLE
}

states[S_KOMBI_SNARKDIE] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_SHURIKEN
}

mobjinfo[MT_HL1_BULLET] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_NULL,
speed = 4*FRACUNIT,
radius = 2*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY|MF_MISSILE,
}

mobjinfo[MT_HL1_ARGRENADE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_NULL,
speed = 0*mobjinfo[MT_CORK].speed/2,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE,
}

mobjinfo[MT_HL1_HANDGRENADE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_NULL,
speed = 3*mobjinfo[MT_CORK].speed/4,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_BOUNCE,
}

mobjinfo[MT_HL1_SATCHEL] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_NULL,
speed = 3*mobjinfo[MT_CORK].speed/4,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_SLIDEME,
}

mobjinfo[MT_HL1_TRIPMINE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_KOMBI_SNARKDIE,
speed = 3*mobjinfo[MT_CORK].speed/4,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_NOGRAVITY,
}

SafeFreeSlot("sfx_hl1wpn",
"sfx_hlcbar","sfx_hlcbb1","sfx_hlcbb2","sfx_hlcbb3","sfx_hlcbh1","sfx_hlcbh2",
"sfx_hl1g17","sfx_hl1pr1","sfx_hl1pr2",
"sfx_hl3571","sfx_hl3572","sfx_hl357r",
"sfx_hl1sr1","sfx_hl1sr2","sfx_hl1sr3",
"sfx_hl1ar1","sfx_hl1ar2","sfx_hl1ar3","sfx_hlarr1","sfx_hlarr2","sfx_hlarg1","sfx_hlarg2",
"sfx_hl1sg1","sfx_hl1sgc",
"sfx_pistol","sfx_shotgn","sfx_dshtgn","sfx_dbopn","sfx_dbload","sfx_dbcls","sfx_dmbfg",
"SPR_HLHITEFFECT","S_HL1_HIT")
sfxinfo[sfx_hlcbar].caption = "Crowbar Swing"
sfxinfo[sfx_hlcbh1].caption = "Crowbar Hit"
sfxinfo[sfx_hlcbh2].caption = "Crowbar Hit"
sfxinfo[sfx_hlcbb1].caption = "Crowbar Hit (Body)"
sfxinfo[sfx_hlcbb2].caption = "Crowbar Hit (Body)"
sfxinfo[sfx_hlcbb3].caption = "Crowbar Hit (Body)"
sfxinfo[sfx_hl1sr1].caption = "Shotgun Loading"
sfxinfo[sfx_hl1sr2].caption = "Shotgun Loading"
sfxinfo[sfx_hl1sr3].caption = "Shotgun Loading"
sfxinfo[sfx_hl1g17].caption = "Pistol Firing"
sfxinfo[sfx_hl1pr1].caption = "Pistol Clip Out"
sfxinfo[sfx_hl1pr2].caption = "Pistol Clip In"
sfxinfo[sfx_hl3571].caption = ".357 Firing"
sfxinfo[sfx_hl3572].caption = ".357 Firing"
sfxinfo[sfx_hl357r].caption = ".357 Reloading"
sfxinfo[sfx_hl1ar1].caption = "MP5 Firing"
sfxinfo[sfx_hl1ar2].caption = "MP5 Firing"
sfxinfo[sfx_hl1ar3].caption = "MP5 Firing"
sfxinfo[sfx_hlarr1].caption = "MP5 Clip Out"
sfxinfo[sfx_hlarr2].caption = "MP5 Clip In"
sfxinfo[sfx_hlarg1].caption = "MP5 Grenade Launched"
sfxinfo[sfx_hlarg2].caption = "MP5 Grenade Launched"

states[S_HL1_HIT] = {
	sprite = SPR_HLHITEFFECT,
	frame = A|FF_ANIMATE,
	tics = 9,
	var1 = 9,
	var2 = 1,
	nextstate = S_NULL
}

local skin = "kombifreeman"
local fire = BT_ATTACK
local altfire = BT_FIRENORMAL
local sound = sfx_hl1g17

rawset(_G, "VMDL_FLIP", 1)
rawset(_G, "VBOB_NONE", 1)
rawset(_G, "VBOB_DOOM", 2)
rawset(_G, "WEAPON_NONE", -1)

rawset(_G, "kombihl1viewmodels", {
	["CROWBAR"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				{frame = 0, duration = 3, rlelength = 3},
			},
			primaryfire = {
				normal = {
					{
						{frame = 4, duration = 2},
						{frame = 55, duration = 4},
						{frame = 56, duration = 3},
						{frame = 57, duration = 4},
						{frame = 58, duration = 3},
						{frame = 59, duration = 2},
					},
					{
						{frame = 59, duration = 3, rlelength = 5},
					},
					{
						{frame = 65, duration = 3, rlelength = 5},
					},
				},
				hit = {
					{
						{frame = 71, duration = 3, rlelength = 4},
					},
					{
						{frame = 59, duration = 1},
						{frame = 60, duration = 2},
						{frame = 61, duration = 3, rlelength = 4},
					},
					{
						{frame = 82, duration = 1},
						{frame = 83, duration = 2},
						{frame = 84, duration = 3, rlelength = 4},
					},
				},
			},
			idle = {
				{
					{frame = 4, duration = 10, rlelength = 9},
				},
				{
					{frame = 15, duration = 8, rlelength = 19},
				},
				{
					{frame = 35, duration = 8, rlelength = 19},
				},
			},
		},
	},
	["PISTOL"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				{frame = 1, duration = 3, rlelength = 6},
			},
			primaryfire = {
				normal = {
					{frame = 53, duration = 2, rlelength = 8},
				},
				empty = {
					{frame = 2, duration = 2},
					{frame = 62, duration = 2, rlelength = 8},
				}
			},
			secondaryfire = {
				normal = {
					{frame = 59, duration = 1},
					{frame = 52, duration = 2, rlelength = 8},
				},
				empty = {
					{frame = 59, duration = 1},
					{frame = 52, duration = 2, rlelength = 9},
				}
			},
			reload = {
				{frame = 27, duration = 6},
				{frame = 84, duration = 6, rlelength = 1},
				{frame = 86, duration = 6, sound = sfx_hl1pr1, rlelength = 5},
				{frame = 92, duration = 6, sound = sfx_hl1pr2, rlelength = 4},
			},
			idle = {
				{
					{frame = 27, duration = 8},
					{frame = 8, duration = 8, rlelength = 19},
					{frame = 27, duration = 8},
				},
				{
					{frame = 27, duration = 8},
					{frame = 28, duration = 12, rlelength = 9},
				},
				{
					{frame = 27, duration = 8},
					{frame = 37, duration = 10, rlelength = 14},
				},
			},
		},
	},
	["357-"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				{frame = 0, duration = 3, rlelength = 6},
			},
			primaryfire = {
				{frame = 6, duration = 2},
				{frame = 120, duration = 3, rlelength = 8},
			},
			reload = {
				{frame = 6, duration = 6},
				{frame = 130, duration = 4, rlelength = 2},
				{frame = 133, duration = 3, rlelength = 18},
				{frame = 152, duration = 3, sound = sfx_hl357r, rlelength = 3},
				{frame = 156, duration = 8},
			},
			idle = {
				{
					{frame = 6, duration = 6, rlelength = 18},
					{frame = 25, duration = 5},
				},
				{
					{frame = 26, duration = 6, rlelength = 18},
					{frame = 45, duration = 5},
				},
				{
					{frame = 46, duration = 6, rlelength = 24},
					{frame = 71, duration = 15},
				},
				{
					{frame = 72, duration = 6, rlelength=46},
					{frame = 119, duration = 10},
				},
			},
		},
	},
	["SHOTGUN"] = {
		idleanims = 3,
		flags = VMDL_FLIP,
		ready = {
			{frame = 0, duration = 3, rlelength = 4},
		},
		primaryfire = {
			{frame = 5, duration = 3},
			{frame = 43, duration = 3, rlelength = 4},
			{frame = 48, duration = 3, sound = sfx_hl1sgc, rlelength = 6},
		},
		reload = {
			start = {
				{frame = 5, duration = 3},
				{frame = 75, duration = 3, rlelength = 5},
			},
			loop = {
				{frame = 81, duration = 4, rlelength = 2},
				{frame = 83, duration = 4, sound = sfx_hl1sr1, sounds = 3},
				{frame = 84, duration = 4, rlelength = 2},
			},
			stop = {
				{frame = 80, duration = 4},
				{frame = 86, duration = 4, rlelength = 2},
				{frame = 88, duration = 4, sound = sfx_hl1sgc},
				{frame = 89, duration = 4, rlelength = 4},
			},
		},
		idle1 = {
			{frame = 5, duration = 8, rlelength = 7},
			{frame = 12, duration = 8},
		},
		idle2 = {
			{frame = 5, duration = 8},
			{frame = 32, duration = 8, rlelength = 10},
			{frame = 42, duration = 5},
		},
		idle3 = {
			{frame = 5, duration = 8},
			{frame = 15, duration = 10, rlelength=15},
			{frame = 31, duration = 16},
		},
	},
	["DOOMWP2-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{frame = 1, duration = 3},
			},
			fire = {
				{frame = 4, duration = 6},
				{frame = 3, duration = 4},
				{frame = 2, duration = 5},
			},
			reload = { -- compatibility layer
				{frame = 2, duration = 6},
			},
			idle = {
				{frame = 1, duration = INT32_MAX},
			},
		},
	},
	["DOOMWP3-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
			animations = {
			ready = {
				{1,3},
			},
			fire = {
				{frame = 1, duration = 4, overlay = 5},
				{frame = 1, duration = 3, overlay = 6},
				{frame = 2, duration = 5, rlelength = 1},
				{frame = 4, duration = 4},
				{frame = 3, duration = 5},
				{frame = 2, duration = 5},
				{frame = 1, duration = 3},
				{frame = 1, duration = 7},
			},
			reload = {
				{frame = 2, duration = 6},
			},
			idle1 = {
				{frame = 1, duration = INT32_MAX},
			},
		},
	},
	["DOOMWP3A-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{frame = 1,3},
			},
			fire = {
				{frame = 1, duration = 3, overlay = 9},
				{frame = 1, duration = 4, overlay = 10},
				{frame = 2, duration = 7, rlelength = 1},
				{frame = 4, duration = 7, sound = sfx_dbopn,rlelength = 1},
				{frame = 6, duration = 7, sound = sfx_dbload},
				{frame = 7, duration = 6},
				{frame = 8, duration = 6, sound = sfx_dbcls},
			},
			reload = {
				{frame = 2, duration = 6},
			},
			idle1 = {
				{frame = 1, duration = INT32_MAX},
			},
		},
	},
	["DOOMWP4-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{frame = 1, duration = 4},
			},
			fire = {
				{frame = 1, duration = 4,overlay = 3},
				{frame = 2, duration = 4,overlay = 4},
			},
			reload = {
				{frame = 2, duration = 6},
			},
			idle1 = {
				{frame = 1, duration = INT32_MAX},
			},
		},
	},
})

rawset(_G, "HL_WpnStats", {
	["crowbar"] =
	{
		israycaster = true, -- the rest probably don't need this property. determines if the bullet object kills itself if it doesn't hit anything.
		viewmodel = "CROWBAR", -- the graphic we'll use for the weapon. Graphic format is VMDL[vmdlkey][frame]!!
		vmdlflip = true,
		selectgraphic = "HL1HUDCROWBAR",
		neverdenyuse = true,
		autoswitchweight = 0,
		weaponslot = 1,
		priority = 1,
		primary = {
			ammo = "melee",
			ismelee = true, -- Gets affected by DoomGuy's berserk if set to true.
			clipsize = WEAPON_NONE,
			shotcost = 0,
			damage = 5,
			firesound = sfx_hlcbar,
			firehitsound = sfx_hlcbh1,
			firehitsounds = 2,
			maxdistance = 32,
			firedelay = 18,
			hitdelay = 9,
		},
		altfire = false,
		globalfiredelay = {
			ready = 12,
		},
		realname = "Crowbar",
	},
	["9mmhandgun"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHRPIS",
		selectgraphic = "HL1HUD9MM",
		autoswitchweight = 10,
		pickupgift = 17,
		weaponslot = 2,
		priority = 1,
		primary = {
			ammo = "9mm",
			clipsize = 17,
			shotcost = 1,
			damage = 8,
			refireusesspread = true,
			horizspread = 5*FRACUNIT,
			vertspread = 5*FRACUNIT,
			kickback = 5*FRACUNIT/2,
			firesound = sfx_hl1g17,
			firedelay = 12,
		},
		autoreload = true,
		secondary = {
			ammo2 = "none",
			clipsize2 = WEAPON_NONE,
			shotcost2 = 1,
			horizspread2 = 5,
			vertspread2 = 5,
			kickback2 = 5*FRACUNIT/2,
			firesound2 = sfx_hl1g17,
			firedelay = 6,
		},
		altfire = true,
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 12,
			reload = 53,
			["reloadpost"] = 18,
		},
		realname = "9mm Handgun",
	},
	["357"] = 
		{
		viewmodel = "357-",
		crosshair = "XHR357",
		selectgraphic = "HL1HUD357",
		autoswitchweight = 15,
		pickupgift = 6,
		weaponslot = 2,
		priority = 2,
		primary = {
			ammo = "357",
			clipsize = 6,
			shotcost = 1,
			damage = 50,
			horizspread = 0,
			vertspread = 0,
			kickback = 7*FRACUNIT,
			firesound = sfx_hl3571,
			["firesounds"] = 2,
			firedelay = 26,
		},
		autoreload = true,
		altfire = true,
		secondary = {
			firefunc = function(player, mystats)
				-- TODO: add Deathmatch Zoom-In
				return true
			end,
			firedelay = 18,
		},
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 18,
			reload = 92
		},
		realname = ".357",
	},
	["mp5"] = 
		{
		crosshair = "XHR9MM",
		selectgraphic = "HL1HUDMP5",
		autoswitchweight = 15,
		weaponslot = 3,
		priority = 1,
		primary = {
			pickupgift = 25,
			ammo = "9mm",
			clipsize = 50,
			shotcost = 1,
			damage = 5,
			horizspread = 4*FRACUNIT,
			vertspread = 4*FRACUNIT,
			kickback = 1*FRACUNIT,
			kickbackcanflip = true,
			firesound = sfx_hl1ar1,
			firesounds = 3,
			firedelay = 4,
		},
		secondary = {
			pickupgift = 2,
			ammo = "argrenade",
			clipsize = WEAPON_NONE,
			shotcost = 1,
			kickback = 10*FRACUNIT,
			firesound = sfx_hlarg1,
			firesounds = 2,
			firedelay = 20,
			firedeny = 30,
		},
		globalfiredelay = {
			ready = 12,
			reload = 53
		},
		realname = "MP5",
	},
	["shotgun"] = 
		{
		viewmodel = "SHOTGUN",
		crosshair = "XHRSHOT",
		selectgraphic = "HL1HUDSHOTGUN",
		autoswitchweight = 15,
		pickupgift = 12, -- why does the shotgun have 12 shells in it? is it stupid?
		weaponslot = 3,
		priority = 2,
		primary = {
			reloadincrement = 1,
			ammo = "buckshot",
			pellets = 6,
			clipsize = 8,
			shotcost = 1,
			damage = 5,
			horizspread = 7*FRACUNIT,
			vertspread = 5*FRACUNIT,
			kickback = 5*FRACUNIT/2,
			firesound = sfx_hl1sg1,
			firedelay = 12,
		},
		autoreload = true,
		secondary = {
			ammo = "none",
			pellets = 12,
			clipsize = WEAPON_NONE,
			shotcost = 2,
			horizspread = 56*FRACUNIT/5,
			vertspread = 71*FRACUNIT/10,
			kickback = 5*FRACUNIT/2,
			firesound = sfx_hl1sg1,
			firedelay = 6,
		},
		altfire = true,
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			["reloadstart"] = 18,
			["reloadloop"] = 20,
		},
		realname = "SPAS-12",
	},
	-- everything past this point has unfinished properties!!
	["crossbow"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHRXBW",
		selectgraphic = "HL1HUDCROSSBOW",
		autoswitchweight = 10,
		pickupgift = 5,
		weaponslot = 3,
		priority = 3,
		ammo = "bolt",
		clipsize = 5,
		shotcost = 1,
		damage = 50,
		kickback = 3*FRACUNIT,
		firesound = sfx_hl1g17,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 16,
			["normal"] = 24,
			reload = 104,
			["reloadpost"] = 48,
		},
		realname = "Crossbow",
	},
	["rpg"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHRRPG",
		selectgraphic = "HL1HUDRPG",
		autoswitchweight = 20,
		pickupgift = 1,
		weaponslot = 4,
		priority = 1,
		ammo = "rocket",
		clipsize = 5,
		shotcost = 1,
		kickback = 5*FRACUNIT/2,
		firesound = sfx_hl1g17,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 15,
			["normal"] = 35,
			reload = 36,
			["reloadpost"] = 24,
		},
		realname = "Rocket Launcher",
	},
	["gauss"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHRGAUS",
		selectgraphic = "HL1HUDTAU",
		autoswitchweight = 20,
		pickupgift = 20,
		weaponslot = 4,
		priority = 2,
		ammo = "uranium",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		kickback = 5*FRACUNIT/2,
		firesound = sfx_hl1g17,
		autoreload = true,
		altfire = false,
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Tau Cannon",
	},
	["egon"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHREGON",
		selectgraphic = "HL1HUDGAUSS",
		autoswitchweight = 20,
		pickupgift = 20,
		weaponslot = 4,
		priority = 3,
		ammo = "uranium",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		kickback = 5*FRACUNIT/2,
		firesound = sfx_hl1g17,
		autoreload = true,
		altfire = false,
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Gluon Gun",
	},
	["hornetgun"] = 
		{
		viewmodel = "PISTOL",
		crosshair = "XHRHNET",
		selectgraphic = "HL1HUDHORNET",
		autoswitchweight = 15,
		weaponslot = 4,
		priority = 4,
		ammo = "hornet",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		kickback = 5*FRACUNIT/2,
		firesound = sfx_hl1g17,
		autoreload = true,
		altfire = false,
		altusesprimaryclip = true,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Hivehand",
	},
	["handgrenade"] = 
		{
		viewmodel = "CROWBAR",
		selectgraphic = "HL1HUDGRENADE",
		autoswitchweight = 5,
		pickupgift = 5,
		weaponslot = 5,
		priority = 1,
		ammo = "grenade",
		clipsize = WEAPON_NONE,
		["shootmobj"] = MT_HL1_HANDGRENADE,
		maxdistance = 3*TICRATE,
		shotcost = 1,
		damage = 1,
		["explosionradius"] = 100,
		firesound = sfx_none,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Grenades",
	},
	["satchel"] = 
		{
		viewmodel = "PISTOL",
		selectgraphic = "HL1HUDSATCHEL",
		autoswitchweight = 5,
		pickupgift = 1,
		weaponslot = 5,
		priority = 2,
		ammo = "satchel",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		firesound = sfx_none,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Satchels",
	},
	["tripmine"] = 
		{
		viewmodel = "PISTOL",
		selectgraphic = "HL1HUDTRIPMINE",
		autoswitchweight = -10, -- VERY unlikely we'll even need to check past here.
		pickupgift = 1,
		weaponslot = 5,
		priority = 3,
		ammo = "tripmine",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		firesound = sfx_none,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Tripmines",
	},
	["snark"] = 
		{
		viewmodel = "PISTOL",
		selectgraphic = "HL1HUDSNARK",
		autoswitchweight = -10,
		pickupgift = 5,
		weaponslot = 5,
		priority = 4,
		ammo = "snark",
		clipsize = WEAPON_NONE,
		shotcost = 1,
		["equipsound"] = sfx_none,
		firesound = sfx_none,
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 12,
			["normal"] = 12,
			["alt"] = 6,
			reload = 54,
		},
		realname = "Snarks",
	},
})

rawset(_G, "HL_AmmoStats", {
	["9mm"] = {
		max = 250, -- How much of an ammo type the player can hold.
		icon = "HUDSELBUCKET1",
		-- shootmobj omitted because the MT_* that'd go here is the last resort, anyway.
	},
	["357"] = {
		max = 36,
		icon = "HUDSELBUCKET1",
	},
	["buckshot"] = {
		max = 125,
		icon = "HUDSELBUCKET1",
	},
	["bolt"] = {
		max = 50,
		icon = "HUDSELBUCKET1",
		shootmobj = MT_HL1_BOLT -- the default mobj to shoot if left unspecified.
	},
	["rocket"] = {
		max = 5,
		shootmobj = MT_HL1_ROCKET,
		icon = "HUDSELBUCKET1",
		safetycatch = true, -- disable autofire so we don't suddenly eat rockets if we autoswitch to the RPG.
		explosionradius = 128
	},
	["grenade"] = {
		max = 10,
		shootmobj = MT_HL1_HANDGRENADE,
		icon = "HUDSELBUCKET1",
		safetycatch = true
	},
	["satchel"] = {
		max = 5,
		icon = "HUDSELBUCKET1",
		shootmobj = MT_HL1_SATCHEL,
		safetycatch = true
	},
	["tripmine"] = {
		max = 5,
		icon = "HUDSELBUCKET1",
		shootmobj = MT_HL1_TRIPMINE,
		safetycatch = true
	},
	["snark"] = {
		max = 15,
		icon = "HUDSELBUCKET1",
		shootmobj = MT_HL1_SNARK,
		safetycatch = true
	},
	["uranium"] = {
		max = 100,
		icon = "HUDSELBUCKET1",
	},
	["hornet"] = {
		max = 8,
		rechargerate = TICRATE/2, -- how long until we get more of this.
		rechargeamount = 1, -- how many of this we get.
		shootmobj = MT_HL1_HORNET
	},
	["argrenade"] = {
		max = 10,
		icon = "HUDSELBUCKET1",
		shootmobj = MT_HL1_ARGRENADE,
		explosionradius = 128
	},
	-- DOOM
	-- shootmobj properties are put in here when the DoomGuy addon gets loaded in. Default to nothing extra for errors' sake.
	["bull"] = {
		max = 200,
		icon = "HUDSELBUCKET1",
	},
	["shel"] = {
		max = 50,
		icon = "HUDSELBUCKET1",
	},
	["rckt"] = {
		max = 50,
		icon = "HUDSELBUCKET1",
		safetycatch = true,
		explosionradius = 128
	},
	["cell"] = {
		max = 300,
		icon = "HUDSELBUCKET1",
	},
})

rawset(_G, "HL_PickupStats", {
})