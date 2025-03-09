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
local frameSound = sfx_hl1g17

rawset(_G, "VMDL_FLIP", 1)
rawset(_G, "VBOB_NONE", 1)
rawset(_G, "VBOB_DOOM", 2)
rawset(_G, "WEAPON_NONE", -1)

rawset(_G, "kombihl1viewmodels", {
	["CROWBAR"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				sentinel = "HLCBARREADY1",
						frameDurations = {
							[1] = 3,
							[4] = 3,
						},
			},
			primaryfire = {
				normal = {
					{
						sentinel = "HLCBARFIRE1-1",
						frameDurations = {
							[1] = 2,
							[2] = 4,
							[3] = 3,
							[4] = 4,
							[5] = 3,
							[6] = 2,
						},
					},
					{
						sentinel = "HLCBARFIRE2-1",
						frameDurations = {
							[1] = 3,
							[6] = 3,
						},
					},
					{
						sentinel = "HLCBARFIRE3-1",
						frameDurations = {
							[1] = 3,
							[6] = 3,
						},
					},
				},
				hit = {
					{
						sentinel = "HLCBARHIT3-1",
						frameDurations = {
							[1] = 3,
							[5] = 3,
						},
					},
					{
						sentinel = "HLCBARHIT2-1",
						frameDurations = {
							[1] = 1,
							[2] = 2,
							[3] = 3,
							[7] = 3,
						},
					},
					{
						sentinel = "HLCBARHIT3-1",
						frameDurations = {
							[1] = 1,
							[2] = 2,
							[3] = 3,
							[7] = 3,
						},
					},
				},
			},
			idle = {
				{
					sentinel = "HLCBARIDLE1-1",
					frameDurations = {
						[1] = 10,
						[11] = 10,
					},
				},
				{
					sentinel = "HLCBARIDLE2-1",
					frameDurations = {
						[1] = 8,
						[20] = 8,
					},
				},
				{
					sentinel = "HLCBARIDLE3-1",
					frameDurations = {
						[1] = 8,
						[20] = 8,
					},
				},
			},
		},
	},
	["PISTOL"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				sentinel = "PISTOLREADY1",
				frameDurations = {
					[1] = 3,
					[7] = 3,
				},
			},
			primaryfire = {
				normal = {
					sentinel = "PISTOLFIRE1",
					frameDurations = {
						[1] = 2,
						[9] = 2,
					},
				},
				empty = {
					sentinel = "PISTOLFIREEMPT1",
					frameDurations = {
						[1] = 2,
						[9] = 2,
					},
				}
			},
			secondaryfire = {
				normal = {
					sentinel = "PISTOLALTFIRE1",
					frameDurations = {
						[1] = 1,
						[2] = 2,
						[9] = 2,
					},
				},
				empty = {
					sentinel = "PISTOLALTFIREEMPT1",
					frameDurations = {
						[1] = 1,
						[2] = 2,
						[9] = 2,
					},
				}
			},
			reload = {
					sentinel = "PISTOLRELOAD1",
					frameDurations = {
						[1] = 6,
						[13] = 6,
					},
					frameSounds = {
						[3] = sfx_hl1pr1,
						[9] = sfx_hl1pr2
					},
			},
			idle = {
				{
					sentinel = "PISTOLIDLE1-1",
					frameDurations = {
						[1] = 8,
						[21] = 8,
					},
				},
				{
					sentinel = "PISTOLIDLE2-1",
					frameDurations = {
						[1] = 8,
						[2] = 12,
						[10] = 12,
					},
				},
				{
					sentinel = "PISTOLIDLE3-1",
					frameDurations = {
						[1] = 8,
						[2] = 10,
						[16] = 10,
					},
				},
			},
		},
	},
	["357-"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				{sentinel = "357READY1", frameDuration = 3, frameStepCount = 6},
			},
			primaryfire = {
				{sentinel = "357FIRE1", frameDuration = 2},
				{frameDuration = 3, frameStepCount = 8},
			},
			reload = {
				{sentinel = "357RELOAD1", frameDuration = 6},
				{frameDuration = 4, frameStepCount = 2},
				{frameDuration = 3, frameStepCount = 18},
				{frameDuration = 3, frameSound = sfx_hl357r, frameStepCount = 3},
				{frameDuration = 8},
			},
			idle = {
				{
					{sentinel = "357IDLE1-1", frameDuration = 6, frameStepCount = 18},
					{frameDuration = 5},
				},
				{
					{sentinel = "357IDLE2-1", frameDuration = 6, frameStepCount = 18},
					{frameDuration = 5},
				},
				{
					{sentinel = "357IDLE3-1", frameDuration = 6, frameStepCount = 24},
					{frameDuration = 15},
				},
				{
					{sentinel = "357IDLE4-1", frameDuration = 6, frameStepCount = 46},
					{frameDuration = 10},
				},
			},
		},
	},
	["SHOTGUN"] = {
		idleanims = 3,
		flags = VMDL_FLIP,
		ready = {
			{baseFrameIndex = 0, frameDuration = 3, frameStepCount = 4},
		},
		animations = {
			ready = {
				{baseFrameIndex = 0, frameDuration = 3, frameStepCount = 4},
			},
			primaryfire = {
				{baseFrameIndex = 5, frameDuration = 3},
				{baseFrameIndex = 43, frameDuration = 3, frameStepCount = 4},
				{baseFrameIndex = 48, frameDuration = 3, frameSound = sfx_hl1sgc, frameStepCount = 6},
			},
			reload = {
				start = {
					{baseFrameIndex = 5, frameDuration = 3},
					{baseFrameIndex = 75, frameDuration = 3, frameStepCount = 5},
				},
				loop = {
					{baseFrameIndex = 81, frameDuration = 4, frameStepCount = 2},
					{baseFrameIndex = 83, frameDuration = 4, frameSound = sfx_hl1sr1, frameSounds = 3},
					{baseFrameIndex = 84, frameDuration = 4, frameStepCount = 2},
				},
				stop = {
					{baseFrameIndex = 80, frameDuration = 4},
					{baseFrameIndex = 86, frameDuration = 4, frameStepCount = 2},
					{baseFrameIndex = 88, frameDuration = 4, frameSound = sfx_hl1sgc},
					{baseFrameIndex = 89, frameDuration = 4, frameStepCount = 4},
				},
			},
			idle = {
				{
					{baseFrameIndex = 5, frameDuration = 8, frameStepCount = 7},
					{baseFrameIndex = 12, frameDuration = 8},
				},
				{
					{baseFrameIndex = 5, frameDuration = 8},
					{baseFrameIndex = 32, frameDuration = 8, frameStepCount = 10},
					{baseFrameIndex = 42, frameDuration = 5},
				},
				{
					{baseFrameIndex = 5, frameDuration = 8},
					{baseFrameIndex = 15, frameDuration = 10, frameStepCount = 15},
					{baseFrameIndex = 31, frameDuration = 16},
				},
			},
		}
	},
	["DOOMWP2-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{baseFrameIndex = 1, frameDuration = 3},
			},
			fire = {
				{baseFrameIndex = 4, frameDuration = 6},
				{baseFrameIndex = 3, frameDuration = 4},
				{baseFrameIndex = 2, frameDuration = 5},
			},
			reload = { -- compatibility layer
				{baseFrameIndex = 2, frameDuration = 6},
			},
			idle = {
				{baseFrameIndex = 1, frameDuration = INT32_MAX},
			},
		},
	},
	["DOOMWP3-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
			animations = {
			ready = {
				{baseFrameIndex = 1, frameDuration = 3},
			},
			fire = {
				{baseFrameIndex = 1, frameDuration = 4, frameOverlayIndex = 5},
				{baseFrameIndex = 1, frameDuration = 3, frameOverlayIndex = 6},
				{baseFrameIndex = 2, frameDuration = 5, frameStepCount = 1},
				{baseFrameIndex = 4, frameDuration = 4},
				{baseFrameIndex = 3, frameDuration = 5},
				{baseFrameIndex = 2, frameDuration = 5},
				{baseFrameIndex = 1, frameDuration = 3},
				{baseFrameIndex = 1, frameDuration = 7},
			},
			reload = {
				{baseFrameIndex = 2, frameDuration = 6},
			},
			idle1 = {
				{baseFrameIndex = 1, frameDuration = INT32_MAX},
			},
		},
	},
	["DOOMWP3A-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{baseFrameIndex = 1,3},
			},
			fire = {
				{baseFrameIndex = 1, frameDuration = 3, frameOverlayIndex = 9},
				{baseFrameIndex = 1, frameDuration = 4, frameOverlayIndex = 10},
				{baseFrameIndex = 2, frameDuration = 7, frameStepCount = 1},
				{baseFrameIndex = 4, frameDuration = 7, frameSound = sfx_dbopn, frameStepCount = 1},
				{baseFrameIndex = 6, frameDuration = 7, frameSound = sfx_dbload},
				{baseFrameIndex = 7, frameDuration = 6},
				{baseFrameIndex = 8, frameDuration = 6, frameSound = sfx_dbcls},
			},
			reload = {
				{baseFrameIndex = 2, frameDuration = 6},
			},
			idle1 = {
				{baseFrameIndex = 1, frameDuration = INT32_MAX},
			},
		},
	},
	["DOOMWP4-"] = {
		idleanims = 1,
		bobtype = VBOB_DOOM,
		animations = {
			ready = {
				{baseFrameIndex = 1, frameDuration = 4},
			},
			fire = {
				{baseFrameIndex = 1, frameDuration = 4, frameOverlayIndex = 3},
				{baseFrameIndex = 2, frameDuration = 4, frameOverlayIndex = 4},
			},
			reload = {
				{baseFrameIndex = 2, frameDuration = 6},
			},
			idle1 = {
				{baseFrameIndex = 1, frameDuration = INT32_MAX},
			},
		},
	},
})

rawset(_G, "HL_WpnStats", {
	["crowbar"] =
	{
		israycaster = true, -- the rest probably don't need this property. determines if the bullet object takes the guy with the lightning's advice if it doesn't hit anything.
		viewmodel = "CROWBAR", -- the graphic we'll use for the weapon. Graphic format is VMDL[vmdlkey][baseFrameIndex]!!
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
			ammo = "none",
			clipsize = WEAPON_NONE,
			shotcost = 1,
			horizspread = 5,
			vertspread = 5,
			kickback = 5*FRACUNIT/2,
			firesound = sfx_hl1g17,
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
			firesounds = 2,
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
		["equipframeSound"] = sfx_none,
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