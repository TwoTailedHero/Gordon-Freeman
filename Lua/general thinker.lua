local function warn(str)
	print("\130WARNING: \128"..str);
end

local function notice(str)
	print("\x82NOTICE: \x80"..str);
end

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
		if abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED
			return 0
		elseif abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED
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
		if HL_WpnStats[player.hl1weapon].altusesprimaryclip
			if HL_WpnStats[player.hl1weapon].shotcost
				if HL_WpnStats[player.hl1weapon].primary.clipsize > 0
					player.hl1clips[player.hl1weapon].primary = $-HL_WpnStats[player.hl1weapon].primary.shotcost
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon].primary.ammo] = $-HL_WpnStats[player.hl1weapon].primary.shotcost
				end
			end
		else
			if HL_WpnStats[player.hl1weapon].secondary.shotcost
				if HL_WpnStats[player.hl1weapon].secondary.clipsize > 0
					player.hl1clips[player.hl1weapon].secondary = $-HL_WpnStats[player.hl1weapon].secondary.shotcost
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon].secondary.ammo] = ($ or 0)-HL_WpnStats[player.hl1weapon].secondary.shotcost
				end
			end
		end
	else
		if HL_WpnStats[player.hl1weapon].primary.shotcost
			if HL_WpnStats[player.hl1weapon].primary.clipsize > 0
				player.hl1clips[player.hl1weapon].primary = $-HL_WpnStats[player.hl1weapon].primary.shotcost
			else
				player.hl1ammo[HL_WpnStats[player.hl1weapon].primary.ammo] = $-HL_WpnStats[player.hl1weapon].primary.shotcost
			end
		end
	end
end

local kombilastseen
local kombiseentime
local kombilocalplayer


addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	player.hl1kickback = $ or 0
	if player.mo.skin != "kombifreeman" return end
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

-- Switches the current animation to idle
local function switchToIdle(player)
    local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
    local idle_list = viewmodel.animations["idle"]
    if idle_list then
        local idle_state = (#idle_list > 1) and ("idle " .. P_RandomRange(1, #idle_list)) or "idle"
        HL_ChangeViewmodelState(player, idle_state, "primaryfire normal")
    end
end

addHook("PlayerThink", function(player)
    if not player.mo or player.mo.skin ~= skin then return end

    -- Handle kickback decay
    if player.hl1kickback > 0 then
        player.hl1kickback = player.hl1kickback - ((ANG1 / 4) >> 16)
        if player.hl1kickback < 0 then player.hl1kickback = 0 end
    elseif player.hl1kickback < 0 then
        player.hl1kickback = player.hl1kickback + ((ANG1 / 4) >> 16)
        if player.hl1kickback > 0 then player.hl1kickback = 0 end
    end

    if not player.hl1weapon then player.hl1weapon = "crowbar" end

    local currentAnimation = player.hl1currentAnimation
    if not currentAnimation then
        switchToIdle(player)
        return
    end

    if player.hl1frameclock and player.hl1frameclock > 0 then
        player.hl1frameclock = player.hl1frameclock - 1
    else
        local frame = currentAnimation[player.hl1frameindex]
        if frame then
            -- Play sound, if this frame has it
            if player.hl1frame == frame.frame and frame.sound then
                local soundToPlay = frame.sound
                if frame.sounds then
                    soundToPlay = $ + P_RandomRange(0, frame.sounds-1)
                end
				print(soundToPlay)
                S_StartSound(player.mo, soundToPlay)
            end

            -- Use rlelength to Run-Length encode how many more frames we have
            if frame.rlelength and player.hl1frame < frame.frame + frame.rlelength - 1 then
                player.hl1frame = player.hl1frame + 1
                player.hl1frameclock = frame.duration
            else
                -- Move to the next frame in the sequence
                player.hl1frameindex = player.hl1frameindex + 1
                local nextFrame = currentAnimation[player.hl1frameindex]
                if nextFrame then
                    player.hl1frame = nextFrame.frame
                    player.hl1frameclock = nextFrame.duration
                else
                    switchToIdle(player)
                end
            end
        else
            switchToIdle(player)
        end
    end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	local viewmodel = kombihl1viewmodels[HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"]
	if not player.hl1clips[player.hl1weapon]
		player.hl1clips[player.hl1weapon] = {
			HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.clipsize or -1,
			HL_WpnStats[player.hl1weapon].secondary and HL_WpnStats[player.hl1weapon].secondary.clipsize or -1
		}
	end

	-- Set-up reloading
	local weapon_stats = HL_WpnStats[player.hl1weapon]
	local weapon_clips = player.hl1clips[player.hl1weapon]
	local primary = weapon_stats.primary or HL_WpnStats["9mmhandgun"].primary
	local ammo_type = primary.ammo
	local reload_increment = primary.reloadincrement

	if (not weapon_clips.primary
		or ((player.cmd.buttons & BT_CUSTOM1) and weapon_clips.primary < primary.clipsize))
		and not player.kombireloading
		and player.hl1weapondelay == 0
		and (player.hl1ammo[ammo_type] or 0) > 0

		player.kombireloading = 1
		player.hl1weapondelay = weapon_stats["globalfiredelay"]["reloadstart"] or weapon_stats["globalfiredelay"]["reload"]
		HL_ChangeViewmodelState(player, "reload start", "idle 1")
	end

	-- Now do the reloading
	if player.kombireloading == 1 and player.hl1weapondelay == 0
		if primary.clipsize and ammo_type
			if not weapon_clips.primary weapon_clips.primary = 0 end
			local max_reload = primary.clipsize - weapon_clips.primary
			local available_ammo = player.hl1ammo[ammo_type]
			
			if reload_increment
				if player.hl1doreload
					local to_reload = min(reload_increment, max_reload, available_ammo)
					weapon_clips.primary = $ + to_reload
					player.hl1ammo[ammo_type] = $ - to_reload
				end
				
				if weapon_clips.primary >= weapon_stats.primary.clipsize or player.hl1ammo[ammo_type] <= 0
					HL_ChangeViewmodelState(player, "reload stop", "idle 1")
					player.kombireloading = 0 -- Stop reloading if full or out of ammo
					player.hl1doreload = nil -- de-init this variable.
				else
					HL_ChangeViewmodelState(player, "reload loop", "idle 1")
					player.hl1weapondelay = weapon_stats.globalfiredelay.reloadloop or weapon_stats.globalfiredelay.reload -- Continue reloading incrementally
					player.hl1doreload = true -- allow reloading to start
				end
			else
				local to_reload = min(max_reload, available_ammo)
				player.hl1ammo[ammo_type] = $ - to_reload
				weapon_clips.primary = $ + to_reload
				player.kombireloading = 0
			end
		else
			print("Weapon \$player.hl1weapon\ missing necessary stats! Check 'clipsize' and 'ammo'.")
		end
	end
end)

local function FireWeapon(player, mode)
	mode = mode or "primary" -- Default to primary if not specified

	-- Handle weapon selection and preparation
	if player.selectionlist and player.selectionlist["weapons"] and player.kombihl1wpn then
		-- Determine the viewmodel based on the current weapon
		local viewmodel = kombihl1viewmodels[HL_WpnStats[player.selectionlist["weapons"][player.kombihl1wpn]["name"]].viewmodel or "PISTOL"]
		if player.hl1weapon ~= player.selectionlist["weapons"][player.kombihl1wpn]["name"] then
			HL_ChangeViewmodelState(player, "ready", "idle 1")
			player.kombireloading = 0

			-- Switch weapon and set delays
			player.hl1weapon = player.selectionlist["weapons"][player.kombihl1wpn]["name"]
			player.hl1weapondelay = HL_WpnStats[player.hl1weapon].globalfiredelay.ready
			player.kombihl1wpn = 0

			-- Set clips if necessary
			if not player.hl1clips[player.hl1weapon] then
				local clipsize = HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.clipsize or -1
				local clipsize2 = HL_WpnStats[player.hl1weapon].secondary and HL_WpnStats[player.hl1weapon].secondary.clipsize or -1
				player.hl1clips[player.hl1weapon] = {primary = clipsize, secondary = clipsize2}
			end
		end
		return
	end
	
	-- Use the current weapon's stats if available; otherwise, fall back to our trusty 9mm.
	local weaponID = player.hl1weapon
	local mystats = HL_WpnStats[weaponID] and HL_WpnStats[weaponID][mode]
	if not mystats then
		weaponID = "9mmhandgun"
		mystats = HL_WpnStats[weaponID] and HL_WpnStats[weaponID][mode]
	end
	
	-- Exit early if we still don't have valid stats
	if not mystats then return end
	
	-- Check if the weapon is available in inventory and has clips
	if not player.hl1inventory[weaponID]
	or (not (player.hl1clips[weaponID] and player.hl1clips[weaponID][mode]) and not mystats.neverdenyuse) then
		return
	end
	
	-- Break if we're in the weapon selection menu
	if player.kombipressingwpnkeys then return end
	
	player.kombireloading = 0 -- Reset reload state
	
	-- Use the viewmodel from the weapon whose stats we are using
	local viewmodel = kombihl1viewmodels[HL_WpnStats[weaponID].viewmodel or "PISTOL"]
	
	-- Prevent firing if there is an active weapon delay
	if mode == "primary" and player.hl1weapondelay then return end
	if mode == "secondary" and player.weaponaltdelay then return end
	
	-- Run firing function, if available
	local firefunc = mystats.firefunc
	if firefunc and firefunc(player, mystats) then
		return -- Exit without firing if firefunc returns true
	end
	
	-- Initialize volley count if not already set
	if not player.currentvolley then
		player.currentvolley = mystats.volley
	end
	
	-- Set-up necessary variables
	local ammotype = mystats.ammo
	if not HL_AmmoStats[tostring(ammotype)] then
		warn("Ammo type " .. tostring(ammotype) .. " has no stats associated with it!")
		HL_AmmoStats[tostring(ammotype)] = {}
	end
	local projectile = mystats.shootmobj
	or (HL_AmmoStats[ammotype] and HL_AmmoStats[ammotype].shootmobj)
	or MT_HL1_BULLET
	kombilocalplayer = player
	kombilocalplayer.mode = mode
	
	-- Fire the weapon, handling multiple pellets if necessary
	for i = 1, (mystats.pellets or 1) do
		local theproj
		
		-- Apply spread if refire does not negate it
		if not mystats.refireusesspread or player.refire then
			local ogangle, ogaiming = player.mo.angle, player.cmd.aiming << 16
			player.mo.angle = player.mo.angle + FixedAngle(FixedMul(P_RandomRange(-32768, 32768), (mystats.horizspread or 0) * 2))
			player.aiming = player.aiming + FixedAngle(FixedMul(P_RandomRange(-32768, 32768), (mystats.vertspread or 0) * 2))
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
			player.mo.angle, player.aiming = ogangle, ogaiming
		else
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
		end
	end
	
	-- Handle firing and ammo consumption
	if (theproj and theproj.valid) or (not mystats.firehitsound) then
		HL_ChangeViewmodelState(player, "primaryfire normal", "primaryfire normal")
		local firesound = mystats.firesound
		if firesound then
			local sound_offset = (mystats.firesounds and mystats.firesounds > 1) and (P_RandomRange(1, mystats.firesounds) - 1) or 0
			S_StartSound(player.mo, firesound + sound_offset)
		end
		
		-- Set weapon delay and decrement ammo
		player.hl1weapondelay = mystats.firedelay
		HL1DecrementAmmo(player, mode == "secondary")
	end
end

addHook("PlayerThink", function(player)
	if not player.mo or player.mo.skin ~= skin return end

	-- Decrease weapon delay timers
	if player.weaponaltdelay player.weaponaltdelay = $ - 1 end
	if player.hl1weapondelay player.hl1weapondelay = $ - 1 end
	
	-- Prevent Freeman from using vanilla firing mechanics by setting a very high delay
	player.weapondelay = INT32_MAX 
	
	-- Reset refire flag if the fire button is released
	if not player.hl1weapondelay and not (player.cmd.buttons & fire) and player.refire
		player.refire = false
	end
	
	-- Handle primary and secondary fire inputs
	if (player.cmd.buttons & fire) or player.currentvolley
		FireWeapon(player, "primary")
	elseif (player.cmd.buttons & altfire)
		FireWeapon(player, "secondary")
	end
end)

local function HL_InitBullet(mobj) -- Does the setting up for our HL1 Projctiles.
	if kombilocalplayer
		local mode = kombilocalplayer.mode
		mobj.target = kombilocalplayer.mo
		mobj.stats = HL_WpnStats[kombilocalplayer.hl1weapon][mode]
		mobj.hl1damage = mobj.stats.damage or 0
		mobj.z = $+(kombilocalplayer.viewheight/2)
		if mobj.stats.ismelee and kombilocalplayer.doom and kombilocalplayer.doom.powers[POWERS_BERSERK]
			mobj.hl1damage = $*10
		end
		mobj.fuse = mobj.stats.maxdistance or 512
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
		mobj.hl1health = $ or (HL1_DMGStats[mobj.type] and HL1_DMGStats[mobj.type].health) or max(1, FixedInt(FixedSqrt(max(1, FixedDiv(FixedMul(mobj.radius * 2, mobj.height),4*FRACUNIT/3)))))
		if type(mobj.hl1health) == "table"
			mobj.hl1health = $.health
		end
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
		player.bob = 0
		player.deltaviewheight = 0
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
	HL_ChangeViewmodelState(player, "ready", "idle1")
end)
-- DOOM Raise speed ~6 pixels
addHook("SeenPlayer", function(player,splayer)
	kombilastseen = splayer -- "Do not alter player_t in HUD rendering code!" - ☝️🤓
	kombiseentime = 7
end)