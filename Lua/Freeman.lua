local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end
	end
end

local skin = "kombifreeman"
local kombiseentime
local kombilastseen

SafeFreeSlot("SPR2_CRCH", "S_PLAY_FREEMCROUCH",
"sfx_hldeny",
"sfx_hlfal1","sfx_hlfal2","sfx_hlfal3")
sfxinfo[sfx_hldeny].caption = "\135Can't Use\x80" -- for SOME reason using the usual hex for this caption turns it cyan and eats the first two proper letters

states[S_PLAY_FREEMCROUCH] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRCH,
	tics = -1,
	var1 = 3,
	var2 = 4,
	nextstate = S_PLAY_FREEMCROUCH
}

rawset(_G, "cv_kombifalldamage", CV_RegisterVar({
	name = "mp_falldamage",
	defaultvalue = "On",
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {On = 1, Off = 0, Dont = 0},
}))

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

local freemanMaxAngle = ANGLE_45 -- how wide of a horizontal angle we can search
local freemanMaxDist = 64*FRACUNIT -- How far the check can go before it's too far
COM_AddCommand("+use", function(player, arg1)
	if not player.mo
		CONS_Printf(player,"I don't think you can use this command at the current moment...")
		return
	end
	-- TODO: this.
	HL.RunHook("HLObjectUsed", victimmobj, victimline, freeman)
end)

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
	HL_ChangeViewmodelState(player, "ready", "idle")
end)

addHook("PlayerHeight", function(player)
	if not player.mo then return end
	if player.realmo.state == S_PLAY_FREEMCROUCH then return player.spinheight end
end)

addHook("PlayerCanEnterSpinGaps", function(player)
	if not player.mo then return end
	if player.realmo.state == S_PLAY_FREEMCROUCH then return true end
end)

local srb2defviewheight = 41 * FRACUNIT

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin ~= skin then return end

	local spinHeight = P_GetPlayerSpinHeight(player)
	local normalHeight = P_GetPlayerHeight(player)
	local oldHeight = player.mo.height -- get our current height for this tic
	
	player.mo.height = normalHeight
	-- If SPIN is held or there's not enough space, enter crouch mode
	if (player.cmd.buttons & BT_SPIN) or not P_TryMove(player.mo, player.mo.x, player.mo.y, true) then
		if player.realmo.state ~= S_PLAY_FREEMCROUCH then
			-- Adjust vertical position when entering crouch mode in the air
			if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then
				if player.mo.eflags & MFE_VERTICALFLIP then
					player.mo.z = $ - abs(normalHeight - spinHeight)
				else
					player.mo.z = $ + abs(normalHeight - spinHeight)
				end
			end
			player.realmo.state = S_PLAY_FREEMCROUCH
			player.normalspeed = skins[player.realmo.skin].normalspeed / 4
		end
	-- If SPIN isn't held and there's enough space for standing, stand back up
	elseif player.realmo.state == S_PLAY_FREEMCROUCH then
		-- Adjust vertical position when standing up in the air
		if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then
			if player.mo.eflags & MFE_VERTICALFLIP then
				player.mo.z = $ + abs(normalHeight - spinHeight)
			else
				player.mo.z = $ - abs(normalHeight - spinHeight)
			end
		end
		player.realmo.state = S_PLAY_STND
		player.normalspeed = skins[player.realmo.skin].normalspeed
	end
	player.mo.height = oldHeight

	-- Adjust view height based on crouch state
	player.viewheight = (player.realmo.state == S_PLAY_FREEMCROUCH) and (srb2defviewheight / 2) or srb2defviewheight
end)

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

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	if (player.cmd.buttons & BT_WEAPONMASK)
		if not player.kombipressingwpnkeys
			player.kombiaccessinghl1menu = true
			player.kombiprevhl1category = player.kombihl1category
			player.kombihl1category = (player.cmd.buttons & BT_WEAPONMASK)

			if player.kombiprevhl1category ~= player.kombihl1category
				player.selectionlist = HL_GetWeapons(HL_WpnStats, player.kombihl1category, player)
				player.kombihl1wpn = 1
			else
				player.kombihl1wpn = player.kombihl1wpn == player.selectionlist["weaponcount"] and 1 or player.kombihl1wpn + 1
			end

			player.kombipressingwpnkeys = true
		end
	elseif player.kombipressingwpnkeys
		player.kombipressingwpnkeys = false
	end
	if player.powers[pw_shield] then
		if (player.mo.hl1armor < (player.mo.hl1maxarmor * 2)) then
			local amount = 15
			if (player.powers[pw_shield] == SH_PINK) then
				amount = 5
			elseif (player.powers[pw_shield] == SH_PITY) then
				amount = 10
			elseif (player.powers[pw_shield] == SH_WHIRLWIND) then
				amount = 20
			elseif (player.powers[pw_shield] == SH_ARMAGEDDON) then
				amount = 50
			end
			
			if (player.powers[pw_shield] & SH_FORCE) then
				amount = $ + (30 * ((player.powers[pw_shield] & SH_FORCEHP) + 1))
			end
			
			if (player.powers[pw_shield] & SH_FIREFLOWER) then
				amount = $ + 25
			end
			player.mo.hl1armor = min($ + (amount * FU), player.mo.hl1maxarmor * 2)
		end
		player.powers[pw_shield] = 0
	end
end)

local function HL_GetDamage(inf)
	if not HL1_DMGStats[inf.type] return end
	local dmgstats = HL1_DMGStats[inf.type]
	local objdamage = dmgstats and dmgstats.damage or {}
	if objdamage.min and objdamage.max
		local max = objdamage.max
		local min = objdamage.min
		local increment = objdamage.increments
		return (P_RandomByte()%(increment and max/increment or max/min) + 1)*(increment or min)
	else
		return objdamage.dmg
	end
end

addHook("MobjDamage", function(target, hurter, src, dmg, dmgType)
	if target.skin == "kombifreeman"
		local inf = (not (HL1_DMGStats[src.type] and HL1_DMGStats[src.type].damage and HL1_DMGStats[src.type].damage.preferaggressor) and src) or hurter
		HL.valuemodes["HLFreemanHurt"] = HL_LASTFUNC
		local hookeddamage, hookeddamagetype = HL.RunHook("HLFreemanHurt", target, inf, src, dmg, dmgType)
		if not (dmgType & DMG_DEATHMASK) and inf and not (inf.type and inf.type == MT_EGGMAN_ICON)
			if inf.player
				P_AddPlayerScore(inf.player, 50)
			end
		end
		if not inf return end
		local damage = hookeddamage or HL_GetDamage(inf) or dmg
		if not HL1_DMGStats[inf.type] print("No DMGStats found for aggressor!") HL1_DMGStats[inf.type] = {damage = {dmg = 0}} end
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



-- Helper to extract the numeric suffix from a sentinel string, e.g. "CROWBAR_SWING_1" => 1
local function getSentinelNumber(s)
    local num = s:match("(%d+)$")
    return tonumber(num) or 0
end

addHook("PlayerThink", function(player)
    if not player.mo or player.mo.skin ~= skin then return end

    -- Handle kickback decay
    if player.hl1kickback
		if player.hl1kickback > 0 then
			player.hl1kickback = player.hl1kickback - ((ANG1 / 4) >> 16)
			if player.hl1kickback < 0 then player.hl1kickback = 0 end
		elseif player.hl1kickback < 0 then
			player.hl1kickback = player.hl1kickback + ((ANG1 / 4) >> 16)
			if player.hl1kickback > 0 then player.hl1kickback = 0 end
		end
	end

	if not player.hl1weapon then player.hl1weapon = "crowbar" end
end)

local function printTable(data, prefix)
    prefix = prefix or ""
	if type(data) == "table"
		for k, v in pairs(data or {}) do
			local key = prefix .. k
			if type(v) == "table" then
				print("key " .. key .. " = a table:")
				printTable(v, key .. ".")
			else
				print("key " .. key .. " = " .. v)
			end
		end
	else
		print(data)
	end
end

addHook("PlayerThink", function(player)
    if not player.mo or player.mo.skin ~= skin then return end
    local currentAnim = player.hl1currentAnimation
    if not currentAnim then
        switchToIdle(player)
        return
    end

    if player.hl1frameclock > 0 then
        player.hl1frameclock = player.hl1frameclock - 1
    else
        -- Increment frame counter
        player.hl1frame = $ + 1

        -- Determine current frame duration based on the highest index less than or equal to player.hl1frame
        local frameDuration = 1 -- Default duration
        for index, duration in ipairs(currentAnim.frameDurations) do
            if index < player.hl1frame then
                frameDuration = duration
            else
                break
            end
        end
        player.hl1frameclock = frameDuration
        
        -- Play frame sound if defined
        local frameSound = currentAnim.frameSounds and currentAnim.frameSounds[player.hl1frame]
        if frameSound then
            if type(frameSound) == "table" then
                -- Play a random sound from the range if multiple sounds are defined
                S_StartSound(player.mo, frameSound.sound + P_RandomRange(0, frameSound.sounds - 1))
            else
                S_StartSound(player.mo, frameSound)
            end
        end

        -- Check if animation has finished
        local highestIndex = 0
        for index in pairs(currentAnim.frameDurations) do
            if index > highestIndex then
                highestIndex = index
            end
        end
        
        if player.hl1frame >= highestIndex then
            HL_ChangeViewmodelState(player, "idle", "idle")
            return
        end
    end
end)

local function contains(mainStr, subStr)
  return string.find(mainStr, subStr) ~= nil
end

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

	if ((not weapon_clips.primary
		or ((player.cmd.buttons & BT_CUSTOM1) and weapon_clips.primary < primary.clipsize))) and contains(player.hl1viewmdaction, "idle")
		and not player.kombireloading
		and player.hl1weapondelay == 0
		and (player.hl1ammo[ammo_type] or 0) > 0

		player.kombireloading = 1
		player.hl1weapondelay = weapon_stats.globalfiredelay.reloadstart or weapon_stats.globalfiredelay.reload
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