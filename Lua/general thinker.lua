local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

local skin = "kombifreeman"
local fire = BT_ATTACK
local altfire = BT_FIRENORMAL

SafeFreeSlot("sfx_hldeny",
"sfx_hlfal1","sfx_hlfal2","sfx_hlfal3")
sfxinfo[sfx_hldeny].caption = "\135Can't Use\x80" -- for SOME reason using the usual hex for this caption turns it cyan and eats the first two proper letters

rawset(_G, "cv_kombifalldamage", CV_RegisterVar({
	name = "mp_falldamage",
	defaultvalue = "On",
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {On = 1, Off = 0, Dont = 0},
}))

local PLAYER_FATAL_FALL_SPEED = 45*FRACUNIT
local PLAYER_MAX_SAFE_FALL_SPEED = 26*FRACUNIT
local DAMAGE_FOR_FALL_SPEED = FixedDiv(100*FRACUNIT,(PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED))
local PLAYER_FALL_PUNCH_THRESHOLD = 18*FRACUNIT

local function HL_GetFallDamage(fallSpeed)
	HL.valuemodes["HLFallDamage"] = HL_LASTFUNC
	local damage = HL.RunHook("HLFallDamage", fallSpeed, abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED, abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED)
	if damage == nil
		if abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED then
			return 0
		elseif abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED then
			return 100
		else
			if cv_kombifalldamage.value > -1
				if cv_kombifalldamage.value
					local damage = FixedMul((abs(fallSpeed) - PLAYER_MAX_SAFE_FALL_SPEED), DAMAGE_FOR_FALL_SPEED)
					return min(FixedInt(damage), 100)
				else
					return 10
				end
			else
				return 0
			end
		end
	else
		return damage
	end
end

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.realmo.skin == "kombifreeman"
		if (player.mo.eflags & MFE_JUSTHITFLOOR)
			local fallhurt = HL_GetFallDamage(player.kombifallz)
			player.mo.hl1health = $-fallhurt
			if player.mo.hl1health <= 0
				player.mo.hl1health = 0
				P_KillMobj(player.mo, player.mo, player.mo, 0)
			elseif fallhurt > 0
				S_StartSound(player.mo,P_RandomRange(sfx_hlfal1,sfx_hlfal3))
			end
		elseif not P_IsObjectOnGround(player.mo)
			player.kombifallz = player.mo.momz
		end
	end
end)

COM_AddCommand("impulse", function(player, arg1)
	if gamestate ~= GS_LEVEL
		CONS_Printf(player,"I don't think you can use this command at the current moment...")
		return
	end
	if arg1 == "101"
		for wepname, wepstats in pairs(HL_WpnStats) do
			HL_AddWeapon(player, wepname, false, false)
		end
	elseif arg1 == "100"
		-- TODO: Create a flashlight (otherwise known as illuminate the sector we're in) when this is ran!!
	end
end)

local theproj = MT_NULL

local function HL1DecrementAmmo(player,secondary)
	if secondary
		if HL_WpnStats[player.hl1weapon]["altusesprimaryammo"]
			if HL_WpnStats[player.hl1weapon].shotcost
				if HL_WpnStats[player.hl1weapon].clipsize > 0
					player.hl1clips[player.hl1weapon][1] = $-HL_WpnStats[player.hl1weapon].shotcost
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon].ammo] = $-HL_WpnStats[player.hl1weapon].shotcost
				end
			end
		else
			if HL_WpnStats[player.hl1weapon]["shotcost2"]
				if HL_WpnStats[player.hl1weapon].clipsize > 0
					player.hl1clips[player.hl1weapon][2] = $-HL_WpnStats[player.hl1weapon]["shotcost2"]
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon]["ammo2"]] = $-HL_WpnStats[player.hl1weapon]["shotcost2"]
				end
			end
		end
	else
		if HL_WpnStats[player.hl1weapon].shotcost
			if HL_WpnStats[player.hl1weapon].clipsize > 0
				player.hl1clips[player.hl1weapon][1] = $-HL_WpnStats[player.hl1weapon].shotcost
			else
				player.hl1ammo[HL_WpnStats[player.hl1weapon].ammo] = $-HL_WpnStats[player.hl1weapon].shotcost
			end
		end
	end
end

local function SetState(player)

end
local kombilastseen
local kombiseentime
local kombilocalplayer


addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	player.hl1kickback = $ or 0
	if player.mo.skin != "kombifreeman" return end
	-- P_TryMove(player.mo, 0, 0)
	if player.mo.hl1health == nil
		if (player.mo.skin == "scieinstein" or player.mo.skin == "scinerd" or player.mo.skin == "sciluther" or player.mo.skin == "scislick")
			player.mo.hl1health = 20 -- 20 HP for scientist users.
		else
			player.mo.hl1health = 100
		end
	end
	if not kombiseentime
		kombilastseen = nil
	end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	-- Handle kickback decay
	if player.hl1kickback > 0
		player.hl1kickback = $ - ((ANG1 / 4)>>16)
		if player.hl1kickback < 0 player.hl1kickback = 0 end
	elseif player.hl1kickback < 0
		player.hl1kickback = $ + ((ANG1 / 4)>>16)
		if player.hl1kickback > 0 player.hl1kickback = 0 end
	end
	if not player.hl1weapon player.hl1weapon = "crowbar" end
	-- Handle weapon and animation delays
	local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
	if player.hl1frameclock
		player.hl1frameclock = $ - 1
	else
		
		local current_action = viewmodel["\$player.hl1viewmdaction\frames"] or viewmodel["idle1frames"]
		
		if current_action[player.hl1frameindex]
			local frame = current_action[player.hl1frameindex]
			local rlelength = frame['rlelength']
			player.hl1frame = $ or frame["frame"] or 1
			if rlelength and player.hl1frame <= frame['frame'] + rlelength - 1
				if player.hl1frame == frame['frame'] and frame["sound"] S_StartSound(player.mo, frame["sound"]) end
				if player.hl1frame < frame['frame']
					player.hl1frame = frame['frame']
					player.hl1frameclock = frame["duration"]
				else
					player.hl1frame = $+1
					player.hl1frameclock = frame["duration"]
				end
			else
				player.hl1frameindex = ($ or 0)+1
				if not rlelength
					player.hl1frameclock = frame["duration"]
					player.hl1frame = frame["frame"]
					if frame["sound"] S_StartSound(player.mo, frame["sound"]) end
				end
			end

		else
			-- Handle idle animations
			if viewmodel["idleanims"] > 1
				local idle_count = viewmodel["idleanims"]
				player.hl1viewmdaction = "idle\$P_RandomRange(1, idle_count)\"
			else
				player.hl1viewmdaction = "idle1"
			end
			current_action = viewmodel["\$player.hl1viewmdaction\frames"] or viewmodel["idle1frames"]
			player.hl1frameindex = 1
			local frame = current_action[1]
			player.hl1frame = frame["frame"]
			player.hl1frameclock = frame["duration"]
		end
	end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
	if not player.hl1clips[player.hl1weapon]
		player.hl1clips[player.hl1weapon] = {
			HL_WpnStats[player.hl1weapon].clipsize or -1,
			HL_WpnStats[player.hl1weapon]["clipsize2"] or -1
		}
	end

	-- Handle reloading
	local weapon_stats = HL_WpnStats[player.hl1weapon]
	local weapon_clips = player.hl1clips[player.hl1weapon]
	local ammo_type = weapon_stats.ammo

	if (not weapon_clips[1]
		or ((player.cmd.buttons & BT_CUSTOM1) and weapon_clips[1] < weapon_stats.clipsize))
		and not player.kombireloading
		and player.hl1weapondelay == 0
		and (player.hl1ammo[ammo_type] or 0) > 0

		player.kombireloading = 1
		player.hl1weapondelay = weapon_stats["firedelay"]["reload"]
		player.hl1viewmdaction = "reload"
		player.hl1frameindex = 1
		player.hl1frame = viewmodel["reloadframes"][1][1]
		player.hl1frameclock = viewmodel["reloadframes"][1][2]
	end

	-- Finalize reloading
	if player.kombireloading == 1 and player.hl1weapondelay == 0
		if weapon_stats.clipsize and ammo_type
			local max_reload = weapon_stats.clipsize - weapon_clips[1]
			local available_ammo = player.hl1ammo[ammo_type]
			local to_reload = min(max_reload, available_ammo)

			player.hl1ammo[ammo_type] = $ - to_reload
			weapon_clips[1] = $ + to_reload
		else
			print("Weapon \$player.hl1weapon\ missing necessary stats! Check 'clipsize' and 'ammo'.")
		end
		player.kombireloading = 0
	end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
	if player.weaponaltdelay player.weaponaltdelay = $ - 1 end
	if player.hl1weapondelay player.hl1weapondelay = $ - 1 end
	
	player.weapondelay = INT32_MAX -- don't use ringslinger rings.

	-- Handle weapon refire logic
	if not (player.hl1weapondelay or (player.cmd.buttons & fire)) and player.refire
		player.refire = false
	end
	if not player.hl1inventory[player.hl1weapon] return end
	if (player.cmd.buttons & fire) or player.currentvolley
		if player.kombihl1wpn and player.selectionlist["weapons"][player.kombihl1wpn] and not player.currentvolley
			if viewmodel["readyframes"] and player.hl1weapon != player.selectionlist["weapons"][player.kombihl1wpn]["name"]
				player.hl1viewmdaction = "ready"
				player.hl1frameindex = 1
				player.hl1frame = viewmodel["readyframes"][player.hl1frameindex]["frames"]
				player.hl1frameclock = viewmodel["readyframes"][player.hl1frameindex]["duration"]
				player.kombireloading = 0
			else
				player.hl1viewmdaction = "idle1"
				player.hl1frameindex = 1
				player.hl1frame = viewmodel["idle1frames"][player.hl1frameindex]["frames"]
				player.hl1frameclock = viewmodel["idle1frames"][player.hl1frameindex]["duration"]
				player.kombireloading = 0
			end
			player.hl1weapon = player.selectionlist["weapons"][player.kombihl1wpn]["name"]
			player.hl1weapondelay = HL_WpnStats[player.hl1weapon]["firedelay"]["ready"]

			player.kombihl1wpn = 0

			if not player.hl1clips[player.hl1weapon]
				local clipsize = HL_WpnStats[player.hl1weapon].clipsize or -1
				local clipsize2 = HL_WpnStats[player.hl1weapon]["clipsize2"] or -1
				player.hl1clips[player.hl1weapon] = {clipsize, clipsize2}
			end
		elseif (player.hl1clips[player.hl1weapon] and player.hl1clips[player.hl1weapon][1] >= HL_WpnStats[player.hl1weapon].shotcost) 
			or (HL_WpnStats[player.hl1weapon].clipsize < 0 
			and (player.hl1ammo[HL_WpnStats[player.hl1weapon].ammo] != nil
			and player.hl1ammo[HL_WpnStats[player.hl1weapon].ammo] > 0)
			or HL_WpnStats[player.hl1weapon]["neverdenyuse"])
			if player.hl1weapondelay return end -- Hacky!! Bad!!!
			if not player.currentvolley
				player.currentvolley = HL_WpnStats[player.hl1weapon].volley
			end
			kombilocalplayer = player
			
			for i = 1, (HL_WpnStats[player.hl1weapon].pellets or 1) do
				local projectile = HL_WpnStats[player.hl1weapon]["shootmobj"] or MT_HL1_BULLET
				if not HL_WpnStats[player.hl1weapon].refireusesspread or player.refire
					local ogangle, ogaiming = player.mo.angle, player.cmd.aiming<<16
					player.mo.angle = $ + FixedAngle(FixedMul(P_RandomRange(-32768, 32768), (HL_WpnStats[player.hl1weapon].horizspread or 0) * 2))
					player.aiming = $ + FixedAngle(FixedMul(P_RandomRange(-32768, 32768), (HL_WpnStats[player.hl1weapon].vertspread or 0) * 2))
					theproj = P_SpawnPlayerMissile(player.mo, projectile)
					player.mo.angle, player.aiming = ogangle, ogaiming
					else
						theproj = P_SpawnPlayerMissile(player.mo, projectile)
					end
				end
			
			if theproj and theproj.valid or not HL_WpnStats[player.hl1weapon]["firehitsound"]

				local firesound = HL_WpnStats[player.hl1weapon].firesound
				if firesound
					if HL_WpnStats[player.hl1weapon]["firesounds"] and HL_WpnStats[player.hl1weapon]["firesounds"] > 1
						S_StartSound(player.mo, firesound + (P_RandomRange(1, HL_WpnStats[player.hl1weapon]["firesounds"]) - 1))
					else
						S_StartSound(player.mo, firesound)
					end
				end

				player.hl1weapondelay = HL_WpnStats[player.hl1weapon]["firedelay"]["normal"]
				HL1DecrementAmmo(player, false)
				if player.currentvolley == HL_WpnStats[player.hl1weapon].volley
					local firenum = ((viewmodel["fireanims"] or 0) > 1) and P_RandomRange(1, viewmodel["fireanims"]) or 1
					local fireframes = viewmodel["fireframes"] or viewmodel["fire\$firenum\frames"]
					if fireframes
						player.hl1viewmdaction = viewmodel["fire\$firenum\frames"] and "fire\$firenum\" or "fire"
						player.hl1frameindex = 1
						player.hl1frame = fireframes[player.hl1frameindex]["frames"]
						player.hl1frameclock = fireframes[player.hl1frameindex]["duration"]
					end
				end
			else
				local firehitsound = HL_WpnStats[player.hl1weapon]["firehitsound"]
				if firehitsound
					if HL_WpnStats[player.hl1weapon]["firehitsounds"] > 1
						S_StartSound(player.mo, firehitsound + (P_RandomRange(1, HL_WpnStats[player.hl1weapon]["firehitsounds"]) - 1))
					else
						S_StartSound(player.mo, firehitsound)
					end
				end
				
				if player.currentvolley == HL_WpnStats[player.hl1weapon].volley
					local firehitnum = ((viewmodel["firehitanims"] or 0) > 1) and P_RandomRange(1, viewmodel["firehitanims"]) or 1
					local firehitframes = (viewmodel["firehitframes"] or viewmodel["fireframes"]) or (viewmodel["firehit\$firehitnum\frames"] or viewmodel["fire\$firehitnum\frames"])
					if firehitframes
						player.hl1viewmdaction = (viewmodel["firehit\$firehitnum\frames"] and "firehit\$firehitnum\" or "fire\$firehitnum\") or (viewmodel["firehitframes"] and "firehit" or "fire")
						player.hl1frameindex = 1
						player.hl1frame = firehitframes[player.hl1frameindex]["frames"]
						player.hl1frameclock = firehitframes[player.hl1frameindex]["duration"]
					end
				end

				player.hl1weapondelay = HL_WpnStats[player.hl1weapon]["firedelay"]["hit"]
				HL1DecrementAmmo(player, false)

			end
			player.currentvolley = ($ or 1)-1
			if not player.currentvolley
				player.refire = true
			end
			if HL_WpnStats[player.hl1weapon].kickback
				local kickback = HL_WpnStats[player.hl1weapon].kickback
				player.hl1kickback = (HL_WpnStats[player.hl1weapon]["kickbackcanflip"] and P_RandomChance(FRACUNIT / 2)) and -1 * (FixedAngle(kickback)>>16) or (FixedAngle(kickback)>>16)
			end
		end
	elseif (player.cmd.buttons & altfire) and HL_WpnStats[player.hl1weapon].altfire and not player.weaponaltdelay
		-- TODO: Refine Fire And Import To Altfire
	end
end)

local function HL_InitBullet(mobj) -- Does the setting up for our HL1 Projctiles.
	if kombilocalplayer
		mobj.target = kombilocalplayer.mo
		mobj.stats = HL_WpnStats[kombilocalplayer.hl1weapon]
		mobj.hl1damage = HL_WpnStats[kombilocalplayer.hl1weapon].damage or 0
		if HL_WpnStats[kombilocalplayer.hl1weapon].ismelee and kombilocalplayer.doom and kombilocalplayer.doom.powers[POWERS_BERSERK]
			mobj.hl1damage = $*10
		end
		mobj.fuse = HL_WpnStats[kombilocalplayer.hl1weapon].maxdistance or 512
	end
end
addHook("MobjSpawn", HL_InitBullet, MT_HL1_BULLET)
addHook("MobjSpawn", HL_InitBullet, MT_HL1_HANDGRENADE)

local function HL_InitHealth(mobj) -- Sets up mobjs.
	HL.valuemodes["HLGetObjectHealth"] = HL_LASTFUNC
	local health = HL.RunHook("HLGetObjectHealth", mobj)
	if health == nil
	if (mobj.skin == "scieinstein" or mobj.skin == "scinerd" or mobj.skin == "sciluther" or mobj.skin == "scislick")
		mobj.hl1health = 20 -- 20 HP for scientist users.
	else
		mobj.hl1health = $ or (HL1_DMGStats[mobj.type] and HL1_DMGStats[mobj.type].health) or max(1, FixedInt(FixedSqrt(FixedDiv(FixedMul(mobj.radius * 2, mobj.height),4*FRACUNIT/3))))
		if mobj.type == MT_PLAYER
			mobj.hl1armor = 100*FRACUNIT
		end
	end
	end
	HL.valuemodes["HLGetObjectMaxStats"] = HL_LASTFUNC
	local maxhealth, maxarmor = HL.RunHook("HLGetObjectMaxStats", mobj)
	mobj.hl1maxhealth = maxhealth or 100
	mobj.hl1maxarmor = (maxarmor or 100)*FRACUNIT
end

addHook("MobjSpawn", function(mobj)
	HL_InitHealth(mobj)
end)

if not duke_roboinfo
	rawset(_G, "duke_roboinfo", {})
end

duke_roboinfo[MT_HL1_BULLET] = {unshrinkable = true, damage = 1, ringslingerdamage = true}

if not duke_roboinfo
	rawset(_G, "duke_roboinfo", {})
end

duke_roboinfo[MT_HL1_BULLET] = {unshrinkable = true, damage = 100, ringslingerdamage = true} -- pre-define our properties
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

addHook("MobjMoveCollide", function(tmthing,thing)
	if tmthing.z + tmthing.height > thing.z and tmthing.z < thing.z + thing.height
		if (thing.flags & MF_SHOOTABLE) and tmthing.target != thing
			if tmthing.hl1damage and not tmthing.hitenemy -- Don't double tap
				if kombiHL1SpecialHandlers[thing.skin] -- are we someone who already has their own health systems to manage?
					kombiHL1SpecialHandlers[thing.skin](tmthing,thing)
				elseif thing.skin == "kombifreeman"
					P_DamageMobj(thing, tmthing, tmthing.target, tmthing.hl1damage, 0) -- Hell, why NOT have our cake and eat it too?
				else
					HL.valuemodes["HLBulletHit"] = HL_ANYTRUE
					if not HL.RunHook("HLBulletHit", tmthing, thing)
						HL_DamageGordon(thing, tmthing, tmthing.hl1damage)
					end
				end
				tmthing.fuse = 9 -- modify our bullet so we know we hit something
				tmthing.state = S_HL1_HIT
				tmthing.scale = FRACUNIT/2
				tmthing.momx = 0
				tmthing.momy = 0
				tmthing.momz = 0
				tmthing.hitenemy = true
			end
		end
		return false
	end
end, MT_HL1_BULLET)

addHook("MobjDamage", function(target, inf, src, dmg, dmgType)
	if target.skin == "kombifreeman"
		HL.valuemodes["HLFreemanHurt"] = HL_LASTFUNC
		local hookeddamage, hookeddamagetype = HL.RunHook("HLFreemanHurt", target, inf, src, dmg, dmgType)
		if not (dmgType & DMG_DEATHMASK) and inf and not (inf.type and inf.type == MT_EGGMAN_ICON)
			if inf.player
				P_AddPlayerScore(inf.player, 50)
			end
		end
		if not inf return end
		local damage = hookeddamage or (HL1_DMGStats[inf.type] and HL1_DMGStats[inf.type].damage) or dmg or 0
		local damagetype = hookeddamagetype or HL1_DMGStats[inf.type] and HL1_DMGStats[inf.type].damagetype
		target.player.powers[pw_flashing] = 18
		target.player.timeshit = $+1
		P_PlayerEmeraldBurst(target.player,false)
		P_PlayerWeaponAmmoBurst(target.player)
		P_PlayerFlagBurst(target.player,false)
		HL_DamageGordon(target, inf, damage, damagetype)
		return true
	end
end, MT_PLAYER)

/*
addHook("MobjMoveBlocked", function(mobj, thing, line)
	if line
		mobj.angle = line.angle
		mobj.momx = 0
		mobj.momy = 0
		mobj.momz = 0
		mobj.state = S_KOMBI_BULLETHOLE
	end
end, MT_HL1_BULLET)
*/
addHook("PreThinkFrame", function()
	kombiseentime = ($ or 0)-1
	for player in players.iterate do
		if not player.mo continue end
		if player.hl1kickback
			player.cmd.aiming = player.cmd.aiming - player.hl1kickback
			player.aiming = (player.cmd.aiming - player.hl1kickback)<<16
		end
	end
end)

addHook("MobjThinker", function(mobj)
	local shooter = mobj.target
	local didathing = false
	shooter.flags = $|MF_NOCLIP -- No touchie.
	for i = 1, mobj.fuse do
		if not mobj and not mobj.valid break end
		if P_RailThinker(mobj) didathing = true break end
	end
	if not didathing and mobj.stats.israycaster
		P_KillMobj(mobj, nil, nil, DMG_INSTAKILL)
	end
	shooter.flags = $&~MF_NOCLIP
end, MT_HL1_BULLET)

addHook("PostThinkFrame", function()
	for player in players.iterate do
		if not player.mo continue end
		if player.hl1kickback
			player.aiming = (player.cmd.aiming + player.hl1kickback)<<16
		end
	end
end)

addHook("PlayerSpawn",function(player)
	if not player.mo return end
	if secondarydisplayplayer == player
	and splitscreen
	and player.mo.skin == "kombifreeman"
		camera2.chase = false
	elseif player.mo.skin == "kombifreeman"
		camera.chase = false
	end
	HL.valuemodes["HLInitInventory"] = HL_LASTFUNC
	local startammo, startclips, startinv, startweapon = HL.RunHook("HLInitInventory", player)
	player.hl1ammo = startammo or $ or {
		["buckshot"] = 125,
		["9mm"] = 68, -- the only value we have set in stone...
		["357"] = 36,
		["bolt"] = 10,
		["grenade"] = 999,
		["melee"] = 0, -- these two require values so that any user error with default ammo types won't be pinned on me
		["none"] = 0, -- ^ because yeah of COURSE it'd throw an error at you if you tried to decrement it IT WASN'T EVEN SUPPOSED TO BE DECREMENTED
	}
	player.hl1clips = startclips or $ or {}
	player.hl1inventory = startinv or $ or {
		["crowbar"] = true,
		["9mmhandgun"] = true,
		["357"] = true,
		["mp5"] = true,
		["shotgun"] = true,
		["crossbow"] = true,
		["handgrenade"] = true,
	}
	player.pickuphistory = {}
	player.hl1deadtimer = 0
	player.hl1weapon = startweapon or "crowbar"
	player.hl1viewmdaction = "ready"
	player.hl1frameindex = 1
	local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
	local current_action = viewmodel["\$player.hl1viewmdaction\frames"] or viewmodel["idle1frames"]
	local frame = current_action[1]
	player.hl1frame = frame["frame"]
	player.hl1frameclock = frame["duration"]
end)
-- DOOM Raise speed ~6 pixels
addHook("SeenPlayer", function(player,splayer)
	kombilastseen = splayer -- "Do not alter player_t in HUD rendering code!" - ☝️🤓
	kombiseentime = 7
end)