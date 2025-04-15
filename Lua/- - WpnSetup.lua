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

SafeFreeSlot("sfx_hl1wpn",
"sfx_hlcbar","sfx_hlcbb1","sfx_hlcbb2","sfx_hlcbb3","sfx_hlcbh1","sfx_hlcbh2",
"sfx_hl1g17","sfx_hl1pr1","sfx_hl1pr2",
"sfx_hl3571","sfx_hl3572","sfx_hl357r",
"sfx_hl1sr1","sfx_hl1sr2","sfx_hl1sr3",
"sfx_hl1ar1","sfx_hl1ar2","sfx_hl1ar3","sfx_hlarr1","sfx_hlarr2","sfx_hlarg1","sfx_hlarg2",
"sfx_hl1sg1","sfx_hl1sgc","sfx_hldsht",
"sfx_hlrckt","sfx_hlexp1","sfx_hlexp2","sfx_hlexp3",
"sfx_hlgrn1","sfx_hlgrn2","sfx_hlgrn3",
"sfx_hltpdp","sfx_hltpch","sfx_hltpac",
"SPR_HLHITEFFECT","S_HL1_HIT",
"SPR_HL1EXPLOSION","S_HL1_EXPLODE","S_HL1_EXPLOSION",
"S_HL1_ROCKET","S_HL1_ROCKETACTIVE",
"S_HL1_TRIPMINETHROWN","S_HL1_INACTIVETRIPMINE","S_HL1_ACTIVETRIPMINE","MT_HL1_TRIPLASER")
sfxinfo[sfx_hlcbar].caption = "Crowbar Swing"
sfxinfo[sfx_hlcbh1].caption = "Crowbar Impact"
sfxinfo[sfx_hlcbh2].caption = "Crowbar Impact"
sfxinfo[sfx_hlcbb1].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hlcbb2].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hlcbb3].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hl1sg1].caption = "Shotgun Firing"
sfxinfo[sfx_hldsht].caption = "Double Shotgun Action"
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
sfxinfo[sfx_hlrckt].caption = "Rocket Launched"
sfxinfo[sfx_hlexp1].caption = "Royalty Free Explosion"
sfxinfo[sfx_hlexp2].caption = "Royalty Cheap Explosion"
sfxinfo[sfx_hlexp3].caption = "Royalty Expensive Explosion"

-- for some DOG ASS REASON, I HAVE TO PUT THESE HERE. fuck this dumbass game vro
if not duke_roboinfo
	rawset(_G, "duke_roboinfo", {})
end

duke_roboinfo[MT_HL1_BULLET] = {unshrinkable = true, damage = 9001, ringslingerdamage = true} -- pre-define our properties
-- ^ for some reason the property to disable hurt invulnerability is labelled "ringslingerdamage"??

rawset(_G, "kombiHL1SpecialHandlers", { -- rawset to _G to open up modding environment. Ya wanna add your own entry? Go on right ahead! Anybody who doesn't follow this logic are lame asf and they should be shamed for it
-- praying none of these people push an update that breaks our code
	["doomguy"] = function(tmthing,thing)
		P_DamageMobj(thing, tmthing, tmthing.target, tmthing.hl1damage, 0) -- Lugent forgot that projectiles lobbed by players take priority over the damage argument!! lmao
	end,
	["bj"] = function(tmthing,thing)
		if not thing.player.wolfenstein return end
		thing.player.wolfenstein.health = $-tmthing.hl1damage
		P_DamageMobj(thing, tmthing, tmthing.target, 0, 0) -- THANK YOU, BJ, for not forcing me to find a way to manage your wack-ass damage system!!
		if thing.player.wolfenstein.health < 0 -- 
			P_KillMobj(thing, tmthing, tmthing.target, 0)
		end
	end,
	["duke"] = function(tmthing,thing)
		duke_roboinfo[MT_HL1_BULLET].damage = tmthing.hl1damage -- modify our damage variable just before we hurt Dick Kickem, WAY better than whatever shit i was doing before
		P_DamageMobj(thing, tmthing, tmthing.target, 1, 0) -- this and the one below it don't utilize the last two arguments sadly
	end,
	["tailsguy"] = function(tmthing,thing)
		local damage = tmthing.hl1damage or 1
		thing.player.tgvars.health = $-tmthing.hl1damage+10
		P_DamageMobj(thing, tmthing, tmthing.target, 100, 0)
		if thing.player.tgvars.health < 0
			P_KillMobj(thing, tmthing, tmthing.target, 0)
		end
		thing.player.powers[pw_flashing] = 0 -- please don't be invulnerable kthxbai
	end,
	["samus"] = function(tmthing,thing)
		TakeSamusEnergy(thing.player,tmthing.hl1damage,true,tmthing,tmthing.target) -- Golden Shine being based as ever and allowing us easy and direct access to necessary damage functions
	end,
	["basesamus"] = function(tmthing,thing)
		TakeSamusEnergy(thing.player,tmthing.hl1damage,true,tmthing,tmthing.target) -- Golden Shine being based as ever and allowing us easy and direct access to necessary damage functions
	end,
	["mcsteve"] = function(tmthing,thing)
		if not stevehelper return end
		stevehelper.damage(thing.player, inflictor, tmthing.hl1damage/5)
	end,
})

rawset(_G, "HL_DamageGordon", function(thing, tmthing, dmg) -- damage something, respecting HL1's logic
	-- Get damage direction relative to the player
	local damageDir = -FRACUNIT
	if tmthing then
		local source = tmthing and tmthing.target or tmthing -- unused, for some reason this makes PointToAngle fuck up
		damageDir = abs(AngleFixed(R_PointToAngle2(thing.x, thing.y, tmthing.x, tmthing.y)) - AngleFixed(thing.angle))
	end
	thing.hl1dmgdir = damageDir
	if thing.player
		thing.player.hl1damagetics = 0
	end
	
	local hldamage = dmg or (tmthing and tmthing.hl1damage)
	if not thing.hl1health then
		HL_InitHealth(thing)
	end
	if hldamage then
		if thing.hl1armor then
			thing.hl1armor = $ - (2 * (hldamage * FRACUNIT) / 5)
			thing.hl1health = $ - hldamage / 5 + min(thing.hl1armor / FRACUNIT, 0)
			thing.hl1health = max($, 0)
			thing.hl1armor = max($, 0)
		else
			thing.hl1health = ($ or 0) - hldamage
		end
		if thing.hl1health <= 0 then -- get killed idiot
			P_KillMobj(thing, tmthing, (tmthing and tmthing.target) or tmthing, 0)
		end
	end
end)

rawset(_G, "HL_HurtMobj", function(tmthing, thing, customDamage, customDamageType) -- damage something depending on its health logic
	-- Use the provided damage override if given, otherwise default to tmthing.hl1damage
	local damage = customDamage or tmthing.hl1damage
	if not (thing.flags & MF_SHOOTABLE) return end -- Return early if we're not supposed to get shot.
	if damage and not tmthing.hitenemy -- Don't double tap
		if kombiHL1SpecialHandlers[thing.skin] -- already has its own health system?
			kombiHL1SpecialHandlers[thing.skin](tmthing, thing)
		elseif thing.skin == "kombifreeman"
			P_DamageMobj(thing, tmthing, tmthing.target, damage, customDamageType or 0) -- custom damage type if provided
		else
			HL_DamageGordon(thing, tmthing, damage)
		end
	end
end)

rawset(_G, "HL_GetDistance", function(obj1, obj2) -- get distance between two objects; useful for things like explosion damage calculation
	if not obj1 or not obj2 then return nil end -- Ensure both objects exist

	local dx = obj1.x - obj2.x
	local dy = obj1.y - obj2.y
	local dz = obj1.z - obj2.z

	return FixedHypot(FixedHypot(dx, dy), dz) -- 3D distance calculationd
end)

function A_StopMomentum(actor)
	if actor.momx and actor.momy and actor.momz
		actor.angle = R_PointToAngle2(0, 0, actor.momx, actor.momy)
		local horizontalSpeed = R_PointToDist2(0, 0, actor.momx, actor.momy)
		actor.pitch = -R_PointToAngle2(0, 0, horizontalSpeed, actor.momz)
	end
	actor.momx = 0
	actor.momy = 0
	actor.momz = 0
	actor.flags = $|MF_NOGRAVITY
end

function A_HLRocketThinker(actor, speed)
	actor.momx = FixedMul(speed, cos(actor.angle)) * cos(actor.pitch)
	actor.momy = FixedMul(speed, sin(actor.angle)) * cos(actor.pitch)
	actor.momz = -FixedMul(speed, sin(actor.pitch))
end

function A_HLExplode(actor, range, baseDamage)
	if not (actor and actor.valid) then return end -- Ensure the actor exists

	local function DamageAndBoostNearby(refmobj, foundmobj)
		if not foundmobj or foundmobj == refmobj then return end -- Skip if no object or self
		if not P_CheckSight(refmobj, foundmobj) then return end -- Skip if we don't have a clear view
		if not (foundmobj.flags & MF_SHOOTABLE) then return end -- Don't attempt to hurt things that shouldn't be hurt in the first place

		local dist = HL_GetDistance(refmobj, foundmobj)
		if dist > range then return end -- Only affect objects within range

		-- Calculate and apply damage
		local damage = max(1, FixedMul(baseDamage, FixedDiv(range - dist, range)))
		HL_HurtMobj(refmobj, foundmobj, damage, DMG.BLAST)

		-- Damage Boosting: apply shockwave momentum to boost objects
		local impulseFactor = FixedDiv(range - dist, range) -- Closer objects get a stronger boost
		local boostFactor = FRACUNIT * 36 -- Base multiplier for force
		if P_IsObjectOnGround(foundmobj) then boostFactor = $/2 end -- Bad rocket jump "multiplier"

		-- Compute horizontal direction and thrust
		local angle = R_PointToAngle2(refmobj.x, refmobj.y, foundmobj.x, foundmobj.y)
		local thrustPower = FixedMul(boostFactor, impulseFactor)
		P_Thrust(foundmobj, angle, thrustPower)

		-- Get the vertical thrust that we'll use later
		local heightDiff = foundmobj.z - refmobj.z
		local heightFactor = FixedDiv(abs(heightDiff), range + FRACUNIT) -- Normalize height effect
		local verticalBoost = FixedMul(boostFactor, impulseFactor) -- Base scaling
		verticalBoost = FixedMul(verticalBoost, (FRACUNIT - heightFactor)) -- Reduce if higher up

		P_SetObjectMomZ(foundmobj, verticalBoost, true)
	end

	-- Process nearby objects for damage and boosting
	searchBlockmap("objects", DamageAndBoostNearby, actor, actor.x - range, actor.x + range, actor.y - range, actor.y + range)

	-- Process breakable FOFs in affected sectors
	local function ProcessFOFs(sector)
		if sector then
			for rover in sector.ffloors() do
				if (rover.flags & FOF_BUSTUP) and (rover.flags & FOF_EXISTS) then  -- Check if the FOF is real and is breakable
					EV_CrumbleChain(sector, rover)
				end
			end
		end
	end

	local function ProcessSectorLines(refmobj, line)
		-- Check both front and back sectors of the line
		ProcessFOFs(line.frontsector)
		ProcessFOFs(line.backsector)
	end

	-- Search for lines in the affected area
	searchBlockmap("lines", ProcessSectorLines, actor, actor.x - (range/2), actor.x + (range/2), actor.y - (range/2), actor.y + (range/2))

	-- Stop momentum and play a random explosion sound
	A_StopMomentum(actor)
	actor.scale = FRACUNIT * 3
	S_StartSound(actor, P_RandomRange(sfx_hlexp1, sfx_hlexp3))
end

function A_HLSetupLaserMine(actor, var1, var2)
    A_PlayAttackSound(actor)

    local angle = actor.angle
    local x, y, z = actor.x, actor.y, actor.z + (actor.height / 2) -- Start from the tripmine's center
    local lasertype = MT_HL1_TRIPLASER -- Define the laser object type
    local lastlaser = nil

    -- Keep casting until hitting a wall
    while true do
        local laser = P_SpawnMobj(x, y, z, lasertype)
        laser.angle = angle
        laser.target = actor -- Keep track of the tripmine that spawned it

        -- Check if this laser clips through a wall
        if P_RailThinker(laser) then
            break -- Stop if a wall was hit
        end

        lastlaser = laser
        x = x + cos(angle) * laser.radius
        y = y + sin(angle) * laser.radius
    end
end

states[S_HL1_HIT] = {
	sprite = SPR_HLHITEFFECT,
	frame = A|FF_ANIMATE,
	tics = 9,
	var1 = 9,
	var2 = 1,
	nextstate = S_NULL
}

states[S_HL1_EXPLODE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLExplode,
	tics = 0,
	var1 = 256*FRACUNIT, -- range
	var2 = 192, -- damage
	nextstate = S_HL1_EXPLOSION
}

states[S_HL1_EXPLOSION] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A|FF_ADD|FF_ANIMATE,
	tics = 13*3,
	var1 = 13,
	var2 = 3,
	nextstate = S_NULL
}

states[S_HL1_TRIPMINETHROWN] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_PlayActiveSound,
	tics = 105,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_ACTIVETRIPMINE
}

states[S_HL1_INACTIVETRIPMINE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_PlaySeeSound,
	tics = 105,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_ACTIVETRIPMINE
}

states[S_HL1_ACTIVETRIPMINE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLSetupLaserMine,
	tics = -1,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_EXPLODE
}

states[S_HL1_ROCKET] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_StopMomentum,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_ROCKETACTIVE
}

states[S_HL1_ROCKETACTIVE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLRocketThinker,
	tics = -1,
	var1 = 30*FRACUNIT,
	var2 = 0,
	nextstate = S_HL1_EXPLODE
}

mobjinfo[MT_HL1_ROCKET] = {
spawnstate = S_HL1_ROCKET,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
reactiontime = 18,
activesound = sfx_hlrckt,
speed = 6*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE|MF_NOGRAVITY,
}

mobjinfo[MT_HL1_ARGRENADE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
speed = 20*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE,
}

mobjinfo[MT_HL1_HANDGRENADE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
xdeathstate = S_HL1_EXPLODE,
activesound = sfx_hlgrn1,
speed = 12*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE|MF_BOUNCE|MF_GRENADEBOUNCE,
}

mobjinfo[MT_HL1_SATCHEL] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
speed = 12*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_SLIDEME,
}

mobjinfo[MT_HL1_TRIPMINE] = {
	spawnstate = S_HL1_TRIPMINETHROWN,
	spawnhealth = 100,
	deathstate = S_HL1_EXPLODE,
	speed = FRACUNIT,
	radius = FRACUNIT/2,
	height = FRACUNIT/2,
	dispoffset = 4,
	flags = MF_NOGRAVITY,
	activesound = sfx_hltmdp,
	seesound = sfx_hlthch,
	attacksound = sfx_hltmac,
	missilestate = S_HL1_INACTIVETRIPMINE
}

mobjinfo[MT_HL1_TRIPLASER] = {
	spawnstate = S_KOMBI_SHURIKEN,
	spawnhealth = 100,
	speed = FRACUNIT,
	radius = FRACUNIT/2,
	height = FRACUNIT/2,
	dispoffset = 4,
	flags = MF_NOGRAVITY,
}

rawset(_G, "VMDL_FLIP", 1)
rawset(_G, "VBOB_DOOM", 1)
rawset(_G, "VBOB_NONE", 2)
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
						[8] = 2,
					},
				},
				empty = {
					sentinel = "PISTOLALTFIREEMPT1",
					frameDurations = {
						[1] = 1,
						[2] = 2,
						[10] = 2,
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
				sentinel = "357READY1",
				frameDurations = {
					[1] = 3,
					[7] = 3,
				},
			},
			primaryfire = {
				sentinel = "357FIRE1",
				frameDurations = {
					[1] = 2,
					[2] = 3,
					[8] = 3,
				},
			},
			reload = {
				sentinel = "357RELOAD1",
				frameDurations = {
					[1] = 6,
					[2] = 4,
					[4] = 3,
					[22] = 3,
					[25] = 8,
					[28] = 8,
				},
				frameSounds = {
					[22] = sfx_hl357r,
				}
			},
			idle = {
				{
					sentinel = "357IDLE1-1",
					frameDurations = {
						[1] = 6,
						[2] = 5,
						[19] = 5,
					},
				},
				{
					sentinel = "357IDLE2-1",
					frameDurations = {
						[1] = 6,
						[2] = 5,
						[20] = 5,
					},
				},
				{
					sentinel = "357IDLE3-1",
					frameDurations = {
						[1] = 6,
						[2] = 15,
						[26] = 15,
					},
				},
				{
					sentinel = "357IDLE4-1",
					frameDurations = {
						[1] = 6,
						[2] = 10,
						[48] = 10,
					},
				},
			},
		},
	},
	["SHOTGUN"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				sentinel = "SHOTGUNREADY1",
				frameDurations = {
					[1] = 3,
					[5] = 3,
				},
			},
			primaryfire = {
				sentinel = "SHOTGUNFIRE1",
				frameDurations = {
					[1] = 3,
					[12] = 3,
				},
				frameSounds = {
					[6] = sfx_hl1sgc
				}
			},
			secondaryfire = {
				sentinel = "SHOTGUNAFIRE1",
				frameDurations = {
					[1] = 3,
					[2] = 2,
					[3] = 3,
					[4] = 2,
					[5] = 3,
					[6] = 2,
					[7] = 3,
					[8] = 2,
					[9] = 3,
					[10] = 2,
					[11] = 3,
					[12] = 2,
					[13] = 3,
					[14] = 2,
					[15] = 3,
					[16] = 2,
					[17] = 3,
					[18] = 2,
					[19] = 3,
					[20] = 6,
				},
				frameSounds = {
					[13] = sfx_hl1sgc,
				}
			},
			reload = {
				start = {
					sentinel = "SHOTGUNRELOADS1",
					frameDurations = {
						[1] = 3,
						[7] = 3,
					},
				},
				loop = {
					sentinel = "SHOTGUNRELOADL1",
					frameDurations = {
						[1] = 4,
						[6] = 4,
					},
					frameSounds = {
						[3] = {sound = sfx_hl1sr1, sounds = 3},
					}
				},
				stop = {
					sentinel = "SHOTGUNRELOADE1",
					frameDurations = {
						[1] = 4,
						[8] = 4,
					},
					frameSounds = {
						[4] = sfx_hl1sgc,
					}
				},
			},
			idle = {
				{
					sentinel = "SHOTGUNIDLE1-1",
					frameDurations = {
						[1] = 8,
						[10] = 8,
					},
				},
				{
					sentinel = "SHOTGUNIDLE2-1",
					frameDurations = {
						[1] = 8,
						[12] = 5,
					},
				},
				{
					sentinel = "SHOTGUNIDLE3-1",
					frameDurations = {
						[1] = 8,
						[2] = 10,
						[18] = 16,
					},
				},
			},
		}
	},
	["MP5-"] = {
		flags = VMDL_FLIP,
		animations = {
			ready = {
				sentinel = "MP5READY1",
				frameDurations = {
					[1] = 5,
					[3] = 8,
				},
			},
			primaryfire = {
				{
					sentinel = "MP5FIRE1-1",
					frameDurations = {
						[1] = 5,
						[5] = 5,
					},
				},
				{
					sentinel = "MP5FIRE2-1",
					frameDurations = {
						[1] = 5,
						[2] = 4,
						[5] = 4,
					},
				},
				{
					sentinel = "MP5FIRE3-1",
					frameDurations = {
						[1] = 5,
						[2] = 4,
						[5] = 4,
					},
				},
			},
			secondaryfire = {
				sentinel = "MPARGRENADE1",
				frameDurations = {
					[1] = 5,
					[6] = 5,
				}
			},
			reload = {
				sentinel = "SHOTGUNRELOADE1",
				frameDurations = {
					[1] = 4,
					[8] = 4,
				},
				frameSounds = {
					[4] = sfx_hl1sgc,
				}
			},
			idle = {
				{
					sentinel = "MP5IDLE1-1",
					frameDurations = {
						[1] = 10,
						[11] = 10,
					},
				},
				{
					sentinel = "MP5IDLE2-1",
					frameDurations = {
						[1] = 5,
						[2] = 6,
						[30] = 6,
					},
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
		viewmodel = "CROWBAR", -- the graphic we'll use for the weapon. Graphic format is VMDL[vmdlkey][baseFrameIndex]!!
		vmdlflip = true,
		selectgraphic = "HL1HUDCROWBAR",
		autoswitchweight = 0,
		weaponslot = 1,
		priority = 1,
		primary = {
			israycaster = true, -- the rest probably don't need this property. determines if the bullet object takes the guy with the lightning's advice if it doesn't hit anything.
			ammo = "melee",
			ismelee = true, -- Gets affected by DoomGuy's berserk if set to true.
			clipsize = WEAPON_NONE,
			neverdenyuse = true,
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
			reloadpost = 18,
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
		viewmodel = "MP5-",
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
			carrymomentum = true,
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
		weaponslot = 3,
		priority = 2,
		primary = {
			reloadincrement = 1,
			ammo = "buckshot",
			pellets = 6,
			clipsize = 8,
			shotcost = 1,
			pickupgift = 12, -- why does the shotgun have 12 shells in it? is it stupid?
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
			firesound = sfx_hldsht,
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
		weaponslot = 4,
		priority = 1,
		primary = {
			pickupgift = 1,
			ammo = "rocket",
			clipsize = 5,
			shotcost = 1,
			kickback = 5*FRACUNIT/2,
			firesound = sfx_hl1g17,
			firedelay = 35,
		},
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
		weaponslot = 5,
		priority = 1,
		primary = {
			carrymomentum = true,
			pickupgift = 5,
			ammo = "grenade",
			clipsize = WEAPON_NONE,
			maxdistance = 3*TICRATE,
			shotcost = 1,
			damage = 1,
			firesound = sfx_none,
			firedelay = 12,
		},
		autoreload = true,
		altfire = false,
		globalfiredelay = {
			ready = 12,
			reload = 54,
		},
		realname = "Grenades",
	},
	["satchel"] = 
		{
		viewmodel = "PISTOL",
		selectgraphic = "HL1HUDSATCHEL",
		autoswitchweight = 5,
		weaponslot = 5,
		priority = 2,
		primary = {
			pickupgift = 1,
			ammo = "satchel",
			clipsize = WEAPON_NONE,
			maxdistance = 5*TICRATE,
			shotcost = 1,
			firesound = sfx_none,
		},
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
		weaponslot = 5,
		priority = 3,
		primary = {
			pickupgift = 1,
			ammo = "tripmine",
			clipsize = WEAPON_NONE,
			shotcost = 1,
			firesound = sfx_none,
			firedelay = 12,
			maxdistance = 128,
		},
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