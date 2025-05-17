local function warn(str)
	print("\130WARNING: \128"..str);
end

local function notice(str)
	print("\x82NOTICE: \x80"..str);
end

local skin = "kombifreeman"
local fire = BT_ATTACK
local altfire = BT_FIRENORMAL

local theproj = MT_NULL

local function HL1DecrementAmmo(player,secondary)
	if secondary
		if HL_WpnStats[player.hl1weapon].altusesprimaryclip
			if HL_WpnStats[player.hl1weapon].secondary.shotcost
				if HL_WpnStats[player.hl1weapon].primary.clipsize > 0
					player.hlinv.wepclips[player.hl1weapon].primary = $-HL_WpnStats[player.hl1weapon].secondary.shotcost
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon].primary.ammo] = $-HL_WpnStats[player.hl1weapon].secondary.shotcost
				end
			end
		else
			if HL_WpnStats[player.hl1weapon].secondary.shotcost
				if HL_WpnStats[player.hl1weapon].secondary.clipsize > 0
					player.hlinv.wepclips[player.hl1weapon].secondary = $-HL_WpnStats[player.hl1weapon].secondary.shotcost
				else
					player.hl1ammo[HL_WpnStats[player.hl1weapon].secondary.ammo] = ($ or 0)-HL_WpnStats[player.hl1weapon].secondary.shotcost
				end
			end
		end
	else
		if HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.shotcost
			if HL_WpnStats[player.hl1weapon].primary.clipsize > 0
				player.hlinv.wepclips[player.hl1weapon].primary = $-HL_WpnStats[player.hl1weapon].primary.shotcost
			else
				player.hl1ammo[HL_WpnStats[player.hl1weapon].primary.ammo] = $-HL_WpnStats[player.hl1weapon].primary.shotcost
			end
		end
	end
end

local kombilastseen
local kombiseentime
local kombilocalplayer

local function FireWeapon(player, mode)
	mode = mode or "primary" -- Default to primary if not specified

	-- If we aren't supposed to be shooting, don't. (world peace solved!)
	if player.hl and ((player.hl.holdyourfire and mode == "primary") or player.hl.noshoot) then return end

	-- Weapon selection and preparation
	if player.selectionlist and player.selectionlist["weapons"] and player.kombiaccessinghl1menu and mode == "primary" then
		local selectedWeapon = player.selectionlist["weapons"][player.kombihl1wpn]

		-- Check if the selected weapon is unselectable
		if not selectedWeapon or not HL_WpnStats[selectedWeapon.name] then
			-- If the weapon is unselectable, close the menu
			player.kombiaccessinghl1menu = false
			player.hl.holdyourfire = true
			S_StartSound(player.mo, sfx_pwepen)
			return
		end

		-- Determine the viewmodel based on the current weapon
		local viewmodel = kombihl1viewmodels[HL_WpnStats[selectedWeapon.name].viewmodel or "PISTOL"]
		if player.hl1weapon ~= selectedWeapon.name then
			-- Switch weapon and set delays
			player.hl1weapon = selectedWeapon.name
			player.hl1weapondelay = HL_WpnStats[player.hl1weapon].globalfiredelay.ready

			-- Set animation
			HL_ChangeViewmodelState(player, "ready", "idle 1")
			player.kombireloading = 0

			-- Set clips if necessary
			if not player.hlinv.wepclips[player.hl1weapon] then
				print("No clips for weapon! Building...")
				local clipsize = HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.clipsize or -1
				local clipsize2 = HL_WpnStats[player.hl1weapon].secondary and HL_WpnStats[player.hl1weapon].secondary.clipsize or -1
				player.hlinv.wepclips[player.hl1weapon] = {primary = clipsize, secondary = clipsize2}
			end
		end

		-- Play the corresponding sound and close the menu, now that we selected something.
		S_StartSound(player.mo, sfx_pwepen)
		player.kombiaccessinghl1menu = false
		player.hl.holdyourfire = true

		return
	end

	-- Use the current weapon's stats if available; otherwise, fall back to our trusty 9mm... Only if primary fire, though.
	local weaponID = player.hl1weapon
	local mystats = HL_WpnStats[weaponID] and HL_WpnStats[weaponID][mode]
	if not mystats and not secondary then
		weaponID = "9mmhandgun"
		mystats = HL_WpnStats[weaponID] and HL_WpnStats[weaponID][mode]
	end

	-- Exit early if we still don't have valid stats
	if not mystats then return end

	-- Check if the weapon is available in inventory and has clips
    if not player.hlinv.wepclips[weaponID] then return end

	-- Either use clip or reserve depending on if clipsize is nil or -1
    local useClip
	local stats = HL_WpnStats[player.hl1weapon]
	local clipMode = (mode == "secondary" and stats.altusesprimaryclip) and "primary" or mode
	local curModeStats = HL_WpnStats[weaponID][clipMode]
    local clipSize = curModeStats.clipsize or -1
    local ammoType = mystats.ammo
    local reserveCount = player.hl1ammo[ammoType] or 0

    -- If the weapon defines a clip (> -1), draw from it; else if ammo pool exists (> -1), draw from reserve; otherwise infinite
    if clipSize > -1 then
        useClip = true
    elseif clipSize == -1 and (HL_WpnStats[weaponID][clipMode].ammo and reserveCount >= 0) then
        useClip = false
    else
        useClip = nil -- infinite ammo
    end

	local clip
	if useClip then
		clip = player.hlinv.wepclips[weaponID][clipMode]
	elseif useClip == false then
		clip = player.hl1ammo[curModeStats.ammo]
	else
		clip = INT32_MAX
	end
	if clip == nil then clip = 0 end

    -- Block firing if no inventory or out of ammo (unless infinite)
    if not player.hl1inventory[weaponID] then
        return
    end
    if (clip < 1) and not mystats.neverdenyuse then
		S_StartSound(player.mo, sfx_hdryfi)
		player.hl = $ or {}
		player.hl.noshoot = true
        return
    end

	-- Break if we're in the weapon selection menu
	if player.kombipressingwpnkeys then return end

	-- Interrupt reloading if we're in one
	if player.kombireloading
		player.kombireloading = 0
		player.hl1weapondelay = 0
		player.weaponaltdelay = 0
	end

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
		if weaponID == "doomchaingun" and not player.hl1weapondelay then
			HL_ChangeViewmodelState(player, "primaryfire normal", "idle 1")
		end
	end

	-- Set-up necessary variables
	local ammotype = mystats.ammo
	if not HL_AmmoStats[tostring(ammotype)] then
		warn("Ammo type " .. tostring(ammotype) .. " has no stats associated with it!")
		HL_AmmoStats[tostring(ammotype)] = {}
	end
	local projectile = mystats.shootmobj or (HL_AmmoStats[ammotype] and HL_AmmoStats[ammotype].shootmobj) or MT_HL1_BULLET
	kombilocalplayer = player
	kombilocalplayer.mode = mode

	-- Fire the weapon, handling multiple pellets if necessary
	for i = 1, (mystats.pellets or 1) do
		local theproj

		-- Apply spread if refire does not negate it
		if not mystats.refireusesspread or player.refire then
			local ogangle, ogaiming = player.mo.angle, player.cmd.aiming << 16
			player.mo.angle = player.mo.angle + FixedAngle(FixedMul(P_RandomFixed() - (FRACUNIT / 2), (mystats.horizspread or 0) * 2))
			player.aiming = player.aiming + FixedAngle(FixedMul(P_RandomFixed() - (FRACUNIT / 2), (mystats.vertspread or 0) * 2))
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
			player.mo.angle, player.aiming = ogangle, ogaiming
		else
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
		end
		if not (theproj and theproj.valid) continue end
		if HL.DoDoomguyAccomodations then
			theproj.dmomx, theproj.dmomy, theproj.dmomz = theproj.momx, theproj.momy, theproj.momz
		end
		if mystats.carrymomentum
			theproj.momx = $+player.mo.momx
			theproj.momy = $+player.mo.momy
			theproj.momz = $+player.mo.momz
		end
	end

	-- Handle firing and ammo consumption
	if (theproj and theproj.valid) or (not mystats.firehitsound) then
		local anim = (clip-mystats.shotcost == 0) and (mode .. "fire" .. " empty") or (mode .. "fire" .. " normal")
		if weaponID != "doomchaingun" then -- Hack!! pretty sure there's a better way to do this
			HL_ChangeViewmodelState(player, anim, anim)
		end
		local firesound = mystats.firesound
		if firesound then
			local sound_offset = (mystats.firesounds and mystats.firesounds > 1) and (P_RandomRange(1, mystats.firesounds) - 1) or 0
			S_StartSound(player.mo, firesound + sound_offset)
		end

		player.refire = true
		if player.currentvolley then player.currentvolley = $ - 1 end

		-- Set weapon delay and decrement ammo
		if mode == "primary" then
			player.hl1weapondelay = mystats.firedelay
		else
			player.weaponaltdelay = mystats.firedelay
		end
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

	if player.hl and player.hl.holdyourfire then
		if not (player.cmd.buttons & fire) then
			player.hl.holdyourfire = false
		end
	end

	if player.hl and player.hl.noshoot then
		if not ((player.cmd.buttons & altfire) or (player.cmd.buttons & fire)) then
			player.hl.noshoot = false
		end
	end

	-- Handle primary and secondary fire inputs
	if (player.cmd.buttons & fire) or player.currentvolley
		FireWeapon(player, "primary")
	elseif (player.cmd.buttons & altfire)
		FireWeapon(player, "secondary")
	end
end)

local function HL_GetBulletDamage(mobj, stats)
	if stats.damagemin and stats.damagemax then
		local max = stats.damagemax
		local min = stats.damagemin
		local increment = stats.damageincs
		local divisor = increment or min
		return (P_RandomByte() % (max / divisor) + 1) * divisor
	else
		return stats.damage or 0
	end
end

local function HL_InitBullet(mobj) -- Does the setting up for our HL1 Projctiles.
	if kombilocalplayer.mo.skin != "kombifreeman" then return end
	if kombilocalplayer
		local mode = kombilocalplayer.mode
		mobj.target = kombilocalplayer.mo
		mobj.stats = HL_WpnStats[kombilocalplayer.hl1weapon][mode]
		mobj.hl1damage = HL_GetBulletDamage(mobj, mobj.stats)
		mobj.z = $+(kombilocalplayer.viewheight/2)
		if mobj.stats.ismelee and kombilocalplayer.doom and kombilocalplayer.doom.powers[POWERS_BERSERK]
			mobj.hl1damage = $*10
		end
		mobj.fuse = mobj.stats.maxdistance or 512
	end
end
addHook("MobjSpawn", HL_InitBullet, MT_HL1_BULLET)
addHook("MobjSpawn", HL_InitBullet, MT_HL1_HANDGRENADE)
addHook("MobjSpawn", HL_InitBullet, MT_HL1_TRIPMINE)
addHook("MobjSpawn", HL_InitBullet, MT_HL1_ARGRENADE)

addHook("MobjMoveCollide", function(tmthing, thing)
	if tmthing.z + tmthing.height > thing.z and tmthing.z < thing.z + thing.height
		if (thing.flags & MF_SHOOTABLE) and tmthing.target != thing
			HL.valuemodes["HLBulletHit"] = HL_ANYTRUE
			if not HL.RunHook("HLBulletHit", tmthing, thing)
				HL_HurtMobj(tmthing, thing)
				-- modify how the bullet object looks for visual feedback
				tmthing.fuse  = 9
				tmthing.state = S_HL1_HIT
				tmthing.scale = FRACUNIT/2
				tmthing.momx  = 0
				tmthing.momy  = 0
				tmthing.momz  = 0
				tmthing.hitenemy = true
			end
		end
		return false
	end
end, MT_HL1_BULLET)

addHook("MobjMoveBlocked", function(mobj, thing, line)
	if line
		mobj.angle = line.angle
		mobj.state = S_MISSILESTATE
		mobj.momx = 0
		mobj.momy = 0
		mobj.momz = 0
	end
end, MT_HL1_TRIPMINE)

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

local function HL_TheRaycastingAtHome(mobj)
	local shooter = mobj.target
	local didathing = false
	shooter.flags = $|MF_NOCLIP -- No touchie.
	for i = 1, mobj.fuse do
		if not mobj and not mobj.valid break end
		if P_RailThinker(mobj) didathing = true break end
	end
	if not didathing and mobj.stats and mobj.stats.israycaster
		P_KillMobj(mobj, nil, nil, DMG_INSTAKILL)
	end
	shooter.flags = $&~MF_NOCLIP
end

addHook("MobjThinker", HL_TheRaycastingAtHome, MT_HL1_BULLET)

addHook("MobjThinker", HL_TheRaycastingAtHome, MT_HL1_TRIPMINE)

addHook("MobjThinker", function(mobj)
	mobj.info.activesound = sfx_hlgrn1 + leveltime%3
end, MT_HL1_HANDGRENADE)

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

-- DOOM Raise speed ~6 pixels
addHook("SeenPlayer", function(player,splayer)
	kombilastseen = splayer -- "Do not alter player_t in HUD rendering code!" - ☝️🤓
	kombiseentime = 7
end)

hud.add(function(v, player)
    if not player.mo then return end
    if kombilastseen and kombilastseen.valid and kombilastseen.mo.skin == "kombifreeman" then
        -- Display Freeman's status when hovered over
        local splayer = kombilastseen
        local sweapon = splayer.hl1weapon
        local swepstats = HL_WpnStats[sweapon]
        local swepname = swepstats.realname or sweapon
        v.drawString(160, 124, "Wielding " .. swepname, V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF, "thin-center")
        v.drawString(160, 132, tostring(splayer.mo.hl1health) .. "%", V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF, "thin-center")
    end
end, "game")