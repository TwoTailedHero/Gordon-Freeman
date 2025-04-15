local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end
	end
end

local skin = "kombifreeman"
local kombiseentime
local kombilastseen

SafeFreeSlot("SPR2_CRCH", "S_PLAY_FREEMCROUCH",
"MT_HLRAY",
"sfx_hldeny","sfx_hlflas",
"sfx_pwepst","sfx_pwepsl","sfx_pwepcl","sfx_pwepen",
"sfx_hlfal1","sfx_hlfal2","sfx_hlfal3",
"sfx_frpai1","sfx_frpai2","sfx_frpai3","sfx_frpai4","sfx_frpai5")
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

local HL_KEYBINDS_PATH = "client/halflife/keybinds.dat"

-- Custom command that basically lets us have certain commands on any button
COM_AddCommand("hlbind", function(player, key, command)
	if not command then
		CONS_Printf(player, "Usage: hlbind <key> <command>", "Example: hlbind e +use")
	end
	player.keyBinds = player.keyBinds or {}
	player.keyBinds[key] = command
	saveTableToFile(HL_KEYBINDS_PATH, player.keyBinds)
	CONS_Printf(player, "Bound key '" .. key .. "' to command '" .. command .. "'")
end)

COM_AddCommand("impulse", function(player, impulse)
	if gamestate ~= GS_LEVEL
		return
	end
	if impulse == "101"
		for wepname, wepstats in pairs(HL_WpnStats) do
			HL_AddWeapon(player, wepname, false, false)
		end
	elseif impulse == "100"
		player.hl = $ or {}
		player.hl.flashlight = not $
		S_StartSound(player.mo, sfx_hlflas)
	elseif impulse == "201"
	end
end)

-- suicide
COM_AddCommand("kill", function(player, victim)
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
	-- kill runner as a placeholder
	P_KillMobj(player.mo, player.mo, player.mo, DMG_SPECTATOR|DMG_CANHURTSELF)
end)

-- gib
COM_AddCommand("explode", function(player, victim)
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
	-- kill runner as a placeholder
	P_KillMobj(player.mo, player.mo, player.mo, DMG_SPECTATOR|DMG_CANHURTSELF|DMG_NUKE)
end)

-- Weapon slot commands (for key binding)
local function setSlot(player, slot)
	if not (player and player.mo) then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	player.desiredSlot = slot
end

COM_AddCommand("slot0", function(player) setSlot(player, 0) end)
COM_AddCommand("slot1", function(player) setSlot(player, 1) end)
COM_AddCommand("slot2", function(player) setSlot(player, 2) end)
COM_AddCommand("slot3", function(player) setSlot(player, 3) end)
COM_AddCommand("slot4", function(player) setSlot(player, 4) end)
COM_AddCommand("slot5", function(player) setSlot(player, 5) end)
COM_AddCommand("slot6", function(player) setSlot(player, 6) end)
COM_AddCommand("slot7", function(player) setSlot(player, 7) end)
COM_AddCommand("slot8", function(player) setSlot(player, 8) end)
COM_AddCommand("slot9", function(player) setSlot(player, 9) end)

-- Helper function for cycling weapons.
local function HL_CycleWeapon(player, direction)
	-- Ensure we have a valid player and selection list
	if not player or not player.hl1inventory then
		return
	end

	-- Set this to true so the menu appears
	player.kombiaccessinghl1menu = true

	-- Retrieve the current selection list for the player's current category.
	local cat = player.kombihl1category or 0
	local selection = player.selectionlist or HL_GetWeapons(HL_WpnStats, cat, player)
	local wpnCount = selection.weaponcount or 0
	
	print(selection.weaponcount)

	if wpnCount == 0 then
		return
	end

	if direction == "next" then
		if player.kombihl1wpn > 1 then
			player.kombihl1wpn = player.kombihl1wpn - 1
		else
			-- At the top of the list; wrap around to the previous category.
			local newCat = cat - 1
			
			-- Obtain the selection list for the new category.
			local iterations = 0
			repeat
				newCat = selection.weaponcount > 0 and $ or $ - 1
				if newCat < 0 then newCat = 9 end
				selection = HL_GetWeapons(HL_WpnStats, newCat, player)
				iterations = $+1
			until iterations > 64 or selection.weaponcount > 0
			player.kombiprevhl1category = cat
			player.kombihl1category = newCat
			player.selectionlist = selection

			-- Start at the last weapon, if available.
			player.kombihl1wpn = (selection.weaponcount > 0) and selection.weaponcount or 0
		end
	elseif direction == "prev" then
		if player.kombihl1wpn < wpnCount then
			player.kombihl1wpn = player.kombihl1wpn + 1
		else
			-- At bottom of list; wrap around to the next category.
			local newCat = cat + 1

			-- Obtain the selection list for the new category.
			local iterations = 0
			repeat
				newCat = selection.weaponcount > 0 and $ or $ + 1
				if newCat > 9 then newCat = 0 end
				selection = HL_GetWeapons(HL_WpnStats, newCat, player)
				iterations = $+1
			until iterations > 64 or selection.weaponcount > 0
			player.kombiprevhl1category = cat
			player.kombihl1category = newCat
			player.selectionlist = selection

			-- Start at the first weapon, if available.
			player.kombihl1wpn = (selection.weaponcount > 0) and 1 or 0
		end
	end
end

-- Example of adding commands via impulse.
COM_AddCommand("invnext", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "next")
end)

COM_AddCommand("invprev", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "prev")
end)

COM_AddCommand("use", function(player, wep)
	/*
	auto-switch to weapon, like "use weapon_9mmhandgun"
	(internally, all weapons don't use the weapon_ prefix,
	but for accuracy's sake we'll do it here.)
	*/
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
end)

rawset(_G, "cv_centerid", CV_RegisterVar({
	name = "hud_centerid",
	defaultvalue = 0,
	flags = CV_SAVE|CV_SHOWMODIF,
	PossibleValue = {Off = 0, On = 1},
}))

rawset(_G, "cv_autowepswitch", CV_RegisterVar({
	name = "cl_autowepswitch",
	defaultvalue = 0,
	flags = CV_SAVE|CV_SHOWMODIF,
	PossibleValue = {Off = 0, On = 1},
}))
/*
violence_ablood 1	enable blood (0 will improve perfomance some, but you won't see any blood)
violence_agibs 1	enable gibs (0 will improve performance some, but you won't see body chunks)
violence_hblood 1	enable more blood (0 will improve perfomance some, but you won't see as much blood)
violence_hgibs 1	enable more gibs (0 will improve performance some, but you won't see as many body chunks)
*/
local function printTable(data, prefix)
	prefix = prefix or ""
	if type(data) == "table"
		for k, v in pairs(data or {}) do
			local key = prefix .. k
			if type(v) == "table" then
				print("key " .. key .. " = a table:")
				printTable(v, key .. ".")
			else
				print("key " .. key .. " = " .. tostring(v))
			end
		end
	else
		print(data)
	end
end

-- Define a helper that takes the base command name, and two functions: one for the '+' variant and one for the '-' variant.
local function RegisterDualCommand(cmd, onPress, onRelease)
	-- Create the press command ("+<cmd>")
	COM_AddCommand("+" .. cmd, function(player, ...)
		if not player.mo then
			CONS_Printf(player, "I don't think you can use this command at the current moment...")
			return
		end
		-- Register that the player is holding the command
		player.hlcmds = player.hlcmds or {}
		player.hlcmds[cmd] = true
		-- Execute the onPress behavior if provided
		if onPress then onPress(player, ...) end
	end)

	-- Create the release command ("-<cmd>")
	COM_AddCommand("-" .. cmd, function(player, ...)
		if not player.mo then
			CONS_Printf(player, "I don't think you can use this command at the current moment...")
			return
		end
		-- Mark the command as released
		player.hlcmds = player.hlcmds or {}
		player.hlcmds[cmd] = false
		-- Execute the onRelease behavior if provided
		if onRelease then onRelease(player, ...) end
	end)
end

local MAX_USE_ANGLE = ANGLE_45 -- how wide of a horizontal angle we can search
local MAX_USE_DIST = USERANGE -- How far the check can go before it's too far
RegisterDualCommand("use",
	function(player)
		S_StartSound(player.mo, sfx_hldeny)
		HL.RunHook("HLObjectUsed", victimmobj, victimline, freeman)
	end
)

RegisterDualCommand("duck")
RegisterDualCommand("jump")
RegisterDualCommand("reload")
RegisterDualCommand("attack")
RegisterDualCommand("attack2")
RegisterDualCommand("speed")

-- Helper function: Normalize binding entry so both table and string forms are handled.
local function getBinding(bind)
	if type(bind) == "string" then
		local dual = false
		local command = bind
		-- If the command starts with "+", we mark it as dual and remove the "+" marker.
		if command:sub(2, 2) == "+" then
			dual = true
			command = command:sub(3)
		end
		return { command = command, dual = dual }
	end
	return bind
end

-- KeyDown hook function
local function OnKeyDown(keyevent)
	print(keyevent.name)
	if not consoleplayer then return end
	local bindEntry = consoleplayer.keyBinds[keyevent.name]
	if bindEntry then
		local binding = getBinding(bindEntry)
		-- For dual commands we send the "+" command on key down.
		if binding.dual then
			if not keyevent.repeated then  -- avoid re-triggering when the key is held down
				COM_BufInsertText(consoleplayer, "+" .. binding.command)
			end
		else
			if not keyevent.repeated then
				COM_BufInsertText(consoleplayer, binding.command)
			end
		end
		-- Return true to override default behavior.
		return true
	end
	return false  -- No binding: allow normal processing.
end

-- KeyUp hook function, only needed for dual commands.
local function OnKeyUp(keyevent)
	if not consoleplayer then return end
	local bindEntry = consoleplayer.keyBinds[keyevent.name]
	if bindEntry then
		local binding = getBinding(bindEntry)
		if binding.dual then
			COM_BufInsertText(consoleplayer, "-" .. binding.command)
			return true
		end
	end
	return false
end

-- Register the hooks.
addHook("KeyDown", OnKeyDown)
addHook("KeyUp", OnKeyUp)

local PLAYER_FATAL_FALL_SPEED = 45*FRACUNIT
local PLAYER_MAX_SAFE_FALL_SPEED = 26*FRACUNIT
local DAMAGE_FOR_FALL_SPEED = FixedDiv(100*FRACUNIT,(PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED))
local PLAYER_FALL_PUNCH_THRESHOLD = 18*FRACUNIT

local function HL_GetFallDamage(fallSpeed, eflags)
	HL.valuemodes["HLFallDamage"] = HL_LASTFUNC
	local damage = HL.RunHook("HLFallDamage", fallSpeed, abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED, abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED)
	if damage == nil
		if (eflags & MFE_TOUCHWATER) then return {dmg = 0, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD} end
		if abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED
			return {dmg = 0, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
		elseif abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED
			return {dmg = 100, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
		else
			if cv_kombifalldamage.value > -1
				if cv_kombifalldamage.value
					local damage = FixedMul((abs(fallSpeed) - PLAYER_MAX_SAFE_FALL_SPEED), DAMAGE_FOR_FALL_SPEED)
					return {dmg = min(FixedInt(damage), 100), fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
				else
					return {dmg = 10, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
				end
			else
				return {dmg = 0, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
			end
		end
	else
		return {dmg = damage, fallpunch = fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD}
	end
end

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.realmo.skin == "kombifreeman"
		if (player.mo.eflags & MFE_JUSTHITFLOOR)
			local fallhurt = HL_GetFallDamage(player.kombifallz, player.mo.eflags)
			player.mo.hl1health = $-fallhurt.dmg
			if player.mo.hl1health <= 0
				player.mo.hl1health = 0
				P_KillMobj(player.mo, player.mo, player.mo, 0)
			elseif fallhurt.dmg > 0
				S_StartSound(player.mo,P_RandomRange(sfx_hlfal1,sfx_hlfal3))
			end
		elseif not P_IsObjectOnGround(player.mo)
			player.kombifallz = player.mo.momz
		end
	end
end)

-- Aliased key binds.
-- Note: By prefixing the command with "+", you automatically mark the command as dual.
local defaultKeyBinds = {
	e				= "+use",			-- SHIELD (when it exists)
	r				= "+reload",		-- CUSTOM 1
	lctrl			= "+duck",			-- SPIN
	lshift		   = "+speed",			-- CUSTOM 3
	f				= "impulse 100",	-- CUSTOM 2
	["0"]			= "slot0",
	["1"]			= "slot1",			-- WPN SLOT 1
	["2"]			= "slot2",			-- WPN SLOT 2
	["3"]			= "slot3",			-- WPN SLOT 3
	["4"]			= "slot4",			-- WPN SLOT 4
	["5"]			= "slot5",			-- WPN SLOT 5
	["6"]			= "slot6",			-- WPN SLOT 6
	["7"]			= "slot7",			-- WPN SLOT 7
	["8"]			= "slot8",
	["9"]			= "slot9",
	["wheel 1 up"]   = "invnext",
	["wheel 1 down"] = "invprev",
}

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
	player.keyBinds = loadTableFromFile(HL_KEYBINDS_PATH, defaultKeyBinds)
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

local srb2defviewheight = 89 * FRACUNIT -- def == 41

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin ~= skin then return end
	if not player.hl then player.hl = {} end
	
	local spinHeight = P_GetPlayerSpinHeight(player)
	local normalHeight = P_GetPlayerHeight(player)
	local oldHeight = player.mo.height -- get our current height for this tic
	local shouldCrouch = (player.cmd.buttons & BT_SPIN) or (player.hlcmds and player.hlcmds.duck) or not (P_CheckPosition(player.mo, player.mo.x, player.mo.y, true) and (player.prevpos and P_CheckPosition(player.mo, player.prevpos.x, player.prevpos.y, true)))
	
	player.mo.height = normalHeight

	if player.hlcmds and player.hlcmds.use == true then
		player.mo.momx, player.mo.momy = -$/2, -$/2
	end
	
	player.normalspeed = skins[player.realmo.skin].normalspeed
	
	-- +speed's walk modifier
	if player.hlcmds and player.hlcmds.speed then
		player.normalspeed = $ / 2
	end

	-- If SPIN is held or there's not enough space, crouch down
	-- SRB2, in its infinite wisdom, also checks the previous tic when considering
	-- To put the player in their roll state, so we have to fight its stupidity.
	-- (we will still lose despite that however)
	if shouldCrouch then
		if not player.hl.crouching then
			-- Adjust vertical position when crouch jumping
			if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then
				if player.mo.eflags & MFE_VERTICALFLIP then
					player.mo.z = $ - abs(normalHeight - spinHeight)
				else
					player.mo.z = $ + abs(normalHeight - spinHeight)
				end
			end
			player.realmo.state = S_PLAY_FREEMCROUCH
		end
	-- If SPIN isn't held and there's enough space for standing, stand back up
	elseif player.hl.crouching then
		-- Adjust vertical position when standing up in the air
		if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then
			if player.mo.eflags & MFE_VERTICALFLIP then
				player.mo.z = $ + abs(normalHeight - spinHeight)
			else
				player.mo.z = $ - abs(normalHeight - spinHeight)
			end
		end
		player.realmo.state = S_PLAY_STND
	end
	
	player.prevpos = {x = player.mo.x, y = player.mo.y}
	
	-- Crouch modifier for normalspeed
	if shouldCrouch then
		player.normalspeed = $ / 4
		player.viewheight = spinHeight - 8*FRACUNIT
		player.hl = $ or {}
		player.hl.crouching = true
	else
		player.viewheight = normalHeight - 8*FRACUNIT
		player.hl = $ or {}
		player.hl.crouching = false
	end

	player.mo.height = oldHeight

	-- Execute jump if buffered and conditions are met
	if ((player.cmd.buttons & BT_JUMP) or (player.hlcmds and player.hlcmds.jump)) and P_IsObjectOnGround(player.mo) then
		L_MakeFootstep(player, "jump")
		P_DoJump(player)
	end
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
	if not player.mo then 
		return 
	end
	
	if not player.kombipressingselkeys
		if player.cmd.buttons & BT_WEAPONNEXT then
			-- Call our helper to cycle to the next weapon.
			HL_CycleWeapon(player, "next")
			player.kombipressingselkeys = true
		elseif player.cmd.buttons & BT_WEAPONPREV then
			HL_CycleWeapon(player, "prev")
			player.kombipressingselkeys = true
		end
	else
		player.kombipressingselkeys = false
	end

	-- Check if a slot command was executed
	if player.desiredSlot ~= nil then
			player.kombiprevhl1category = player.kombihl1category
			player.kombihl1category = player.desiredSlot
			
			if player.kombiprevhl1category ~= player.kombihl1category or not player.kombiaccessinghl1menu then
				player.selectionlist = HL_GetWeapons(HL_WpnStats, player.kombihl1category, player)
				player.kombihl1wpn = 1
				S_StartSound(player.mo, sfx_pwepst)
			else
				player.kombihl1wpn = player.kombihl1wpn == player.selectionlist["weaponcount"] and 1 or player.kombihl1wpn + 1
				S_StartSound(player.mo, sfx_pwepsl)
			end
			
			player.kombiaccessinghl1menu = true
			player.kombipressingwpnkeys = true
			player.desiredSlot = nil
	end

	-- If there's additional filtering based on skin, etc.
	if player.mo.skin ~= skin then 
		return
	end

	-- Existing logic for button presses, etc.
	if (player.cmd.buttons & BT_WEAPONMASK) then
		if not player.kombipressingwpnkeys then
			player.kombiprevhl1category = player.kombihl1category
			player.kombihl1category = (player.cmd.buttons & BT_WEAPONMASK)
			
			if player.kombiprevhl1category ~= player.kombihl1category or not player.kombiaccessinghl1menu then
				player.selectionlist = HL_GetWeapons(HL_WpnStats, player.kombihl1category, player)
				player.kombihl1wpn = 1
			else
				player.kombihl1wpn = player.kombihl1wpn == player.selectionlist["weaponcount"] and 1 or player.kombihl1wpn + 1
			end
			
			player.kombiaccessinghl1menu = true
			player.kombipressingwpnkeys = true
		end
	elseif player.kombipressingwpnkeys then
		player.kombipressingwpnkeys = false
	end

	-- The rest of the PlayerThink hook, for instance the shield/armor block:
	if player.powers[pw_shield] then
		if (player.mo.hl1armor < player.mo.hl1maxarmor) then
			local amount = 20  
			if (player.powers[pw_shield] == SH_PINK) then
				amount = 25  
			elseif (player.powers[pw_shield] == SH_PITY) then
				amount = 15  
			elseif (player.powers[pw_shield] == SH_WHIRLWIND) then
				amount = 25  
			elseif (player.powers[pw_shield] == SH_ARMAGEDDON) then
				amount = 30  
			elseif (player.powers[pw_shield] == SH_ELEMENTAL) then
				amount = 18  
			elseif (player.powers[pw_shield] == SH_ATTRACT) then
				amount = 10  
			elseif (player.powers[pw_shield] == SH_FLAMEAURA) then
				amount = 35  
			elseif (player.powers[pw_shield] == SH_BUBBLEWRAP) then
				amount = 28  
			elseif (player.powers[pw_shield] == SH_THUNDERCOIN) then
				amount = 40  
			end

			if (player.powers[pw_shield] & SH_FORCE) then
				amount = amount + (5 * ((player.powers[pw_shield] & SH_FORCEHP) + 1))
			end
			if (player.powers[pw_shield] & SH_FIREFLOWER) then
				amount = amount + 10
			end

			player.mo.hl1armor = min(player.mo.hl1armor + (amount * FRACUNIT), player.mo.hl1maxarmor)
		end
		player.powers[pw_shield] = 0
	end
end)

local function HL_GetDamage(inf)
	if not HL1_DMGStats[inf.type] then return end
	local dmgstats = HL1_DMGStats[inf.type]
	local objdamage = dmgstats and dmgstats.damage or {}

	if objdamage.min and objdamage.max then
		local max = objdamage.max
		local min = objdamage.min
		local increment = objdamage.increments
		local divisor = increment or min
		return (P_RandomByte() % (max / divisor) + 1) * divisor
	else
		return objdamage.dmg
	end
end

addHook("MobjDamage", function(target, inf, src, dmg, dmgType)
	if target.skin ~= "kombifreeman" then return end
	if not inf and not src then
		HL_DamageGordon(target, nil, 15)
		target.player.powers[pw_flashing] = 18
		return true
	end
	local inf = (HL1_DMGStats[src.type] and HL1_DMGStats[src.type].damage and HL1_DMGStats[src.type].damage.preferaggressor) and inf or src
	HL.valuemodes["HLFreemanHurt"] = HL_LASTFUNC
	S_StartSound(target,P_RandomRange(sfx_frpai1,sfx_frpai5))
	local hookeddamage, hookeddamagetype = HL.RunHook("HLFreemanHurt", target, inf, src, dmg, dmgType)

	if not (dmgType & DMG_DEATHMASK) and inf and inf.type ~= MT_EGGMAN_ICON then
		if inf.player then
			P_AddPlayerScore(inf.player, 50)
		end
	end

	if not inf then return end

	local damage = hookeddamage or HL_GetDamage(inf) or dmg

	if not HL1_DMGStats[inf.type] then
		print("No DMGStats found for aggressor!")
		HL1_DMGStats[inf.type] = { damage = { dmg = 0 } }
	end

	local damagetype = hookeddamagetype or (HL1_DMGStats[inf.type] and HL1_DMGStats[inf.type].damagetype)

	if not inf.stats then target.player.powers[pw_flashing] = 18 end
	target.player.timeshit = target.player.timeshit + 1
	P_PlayerEmeraldBurst(target.player, false)
	P_PlayerWeaponAmmoBurst(target.player)
	P_PlayerFlagBurst(target.player, false)
	
	HL_DamageGordon(target, inf, damage, damagetype)
	return true
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

	-- Increment Damage Tics Clock
	player.hl1damagetics = ($ or 0)+1

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
		or (((player.cmd.buttons & BT_CUSTOM1) or (player.hlcmds and player.hlcmds.reload)) and weapon_clips.primary < primary.clipsize))) and contains(player.hl1viewmdaction, "idle")
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