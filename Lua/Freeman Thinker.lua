local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end
	end
end

local skin = "kombifreeman"
local kombiseentime
local kombilastseen

SafeFreeSlot("SPR2_CRCH", "S_PLAY_FREEMCROUCH", "S_PLAY_FREEMCROUCHMOVE",
"MT_HLRAY",
"sfx_hldeny","sfx_hlflas","sfx_hlspra",
"sfx_pwepst","sfx_pwepsl","sfx_pwepcl","sfx_pwepen",
"sfx_hlfal1","sfx_hlfal2","sfx_hlfal3",
"sfx_frpai1","sfx_frpai2","sfx_frpai3","sfx_frpai4","sfx_frpai5",
"sfx_hlla1","sfx_hlla2","sfx_hlla3","sfx_hlla4")
sfxinfo[sfx_hldeny].caption = "\135Can't Use\x80" -- for SOME reason using the usual hex for this caption turns it cyan and eats the first two proper letters

states[S_PLAY_FREEMCROUCHMOVE] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRCH|FF_ANIMATE,
	tics = -1,
	var1 = 3,
	var2 = 12,
	nextstate = S_PLAY_FREEMCROUCH
}

states[S_PLAY_FREEMCROUCH] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRCH,
	tics = -1,
	var1 = 3,
	var2 = 4,
	nextstate = S_PLAY_FREEMCROUCH
}

spr2defaults[SPR2_CRCH] = SPR2_WALK

rawset(_G, "cv_kombifalldamage", CV_RegisterVar({
	name = "mp_falldamage",
	defaultvalue = "On",
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {On = 1, Fixed = 0, Dont = -1},
}))

rawset(_G, "cv_hldecallimit", CV_RegisterVar({
	name = "mp_decals",
	defaultvalue = 50,
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = CV_Unsigned,
}))

rawset(_G, "cv_hldecaldelay", CV_RegisterVar({
	name = "decalfrequency",
	defaultvalue = 30,
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = CV_Unsigned,
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

local function SpawnSpray(mo)
    local spr  = P_SpawnPlayerMissile(mo, MT_SPRAY)
    spr.pangle = mo.angle
    spr.tracer = mo
	spr.z      = $+(mo.player.viewheight/2)
    return spr
end

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
		player.hl = $ or {}
		player.hl.spraying = true
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

for slot = 0, 9 do
	COM_AddCommand("slot" .. slot, function(player) setSlot(player, slot) end)
end

-- Constants
local CATEGORY_COUNT = 10

-- Returns an empty weapon selection structure
local function emptySelection()
	local ws = {}
	for i = 0, 9 do ws[i] = 0 end
	return {
		weapons = {},
		weaponcount = 0,
		wepslotamounts = ws
	}
end

-- Returns the index of the first usable weapon, or nil if none
local function getFirstUsableIndex(sel)
	if not sel or not sel.weapons then return nil end
	for i, w in ipairs(sel.weapons) do
		if w.usable then return i end
	end
	return nil
end

-- Steps through the current bucket without wrapping
local function cycleWithinCategory(sel, startIndex, step)
	local cnt = sel and sel.weaponcount or 0
	if cnt < 2 then return nil end

	local idx = startIndex + step
	while idx >= 1 and idx <= cnt do
		if sel.weapons[idx].usable then return idx end
		idx = idx + step
	end

	return nil
end

-- Steps through the current bucket with wraparound
local function cycleWithinCategoryWrap(sel, startIndex, step)
	local cnt = sel and sel.weaponcount or 0
	if cnt < 1 then return nil end

	local idx = startIndex
	for _ = 1, cnt do
		idx = ((idx - 1 + step) % cnt) + 1
		if sel.weapons[idx].usable then return idx end
	end

	return nil
end

-- Tries to switch to a new weapon category with at least one usable weapon
local function switchCategory(currentCat, dir, player)
	for i = 1, CATEGORY_COUNT do
		local offset = (dir == 1 and i or -i)
		local newCat = (currentCat + offset + CATEGORY_COUNT) % CATEGORY_COUNT
		local sel = HL_GetWeapons(HL_WpnStats, newCat, player) or emptySelection()
		if getFirstUsableIndex(sel) then
			return newCat, sel
		end
	end
	local fallback = HL_GetWeapons(HL_WpnStats, 11, player)
	return CATEGORY_COUNT + 1, fallback or emptySelection() -- fallback if nothing usable
end

-- Main weapon cycling function (non-wrapping within category)
local function HL_CycleWeapon(player, direction)
	if not player or not player.hl1inventory then return end
	player.kombiaccessinghl1menu = true

	local dirstep = direction == "next" and 1 or -1
	local cat = player.kombihl1category or 0
	local sel = player.selectionlist or HL_GetWeapons(HL_WpnStats, cat, player) or emptySelection()
	local first = getFirstUsableIndex(sel)

	if sel.weaponcount == 0 or not first then
		local nc, ns = switchCategory(cat, dirstep, player)
		player.kombiprevhl1category = cat
		player.kombihl1category = nc
		player.selectionlist = ns
		player.kombihl1wpn = getFirstUsableIndex(ns) or 0
		return
	end

	local cur = player.kombihl1wpn or first
	local newIndex = cycleWithinCategory(sel, cur, dirstep)

	if newIndex then
		player.kombihl1wpn = newIndex
		return
	end

	local nc, ns = switchCategory(cat, dirstep, player)
	player.kombiprevhl1category = cat
	player.kombihl1category = nc
	player.selectionlist = ns

	if direction == "next" then
		player.kombihl1wpn = getFirstUsableIndex(ns) or 0
	else
		for i = #ns.weapons, 1, -1 do
			if ns.weapons[i].usable then
				player.kombihl1wpn = i
				break
			end
		end
		player.kombihl1wpn = player.kombihl1wpn or 0
	end
end

COM_AddCommand("invnext", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "prev")
end)

COM_AddCommand("invprev", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "next")
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

-- Helper function: Get what the command is supposed to be ("+cmd" for dual, "cmd" for normal)
local function getBinding(bind)
	if type(bind) == "string" then
		local dual = false
		local command = bind

		-- Fix inconsistent behavior problems that SOMEHOW pop up for SOME godforsaken reason by removing surrounding double quotes if they exist
		if command:sub(1, 1) == '"' and command:sub(-1) == '"' then
			command = command:sub(2, -2)
		end

		-- If the command starts with "+", we mark it as dual and remove the "+" marker.
		if command:sub(1, 1) == "+" then
			dual = true
			command = command:sub(2)
		end
		return { command = command, dual = dual }
	end
	return bind
end

local function playerHasControl(player)
return not (
  player.exiting
  or player.powers[pw_nocontrol]
  or P_PlayerInPain(player)
  or (player.pflags & PF_STASIS)
  or (player.pflags & PF_FULLSTASIS)
  or (player.powers[pw_carry] > CR_NONE)
  or (player.playerstate ~= PST_LIVE)
) end

-- KeyDown hook function
local function OnKeyDown(keyevent)
	-- print(keyevent.name)
	if not consoleplayer then return end
	if not playerHasControl(consoleplayer) then return end
	if not consoleplayer.mo then return end
	if consoleplayer.mo.skin != skin then return end
	local bindEntry = consoleplayer.keyBinds[keyevent.name]
	if bindEntry then
		local binding = getBinding(bindEntry)
		-- For dual commands we send the "+" command on key down.
		if binding.dual then
			if not keyevent.repeated then	-- avoid re-triggering when the key is held down
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
	return false	-- No binding: allow normal processing.
end

-- KeyUp hook function, only needed for dual commands.
local function OnKeyUp(keyevent)
	if not consoleplayer then return end
	if not playerHasControl(consoleplayer) then return end
	if not consoleplayer.mo then return end
	if consoleplayer.mo.skin != skin then return end
	local bindEntry = consoleplayer.keyBinds[keyevent.name]
	if type(bindEntry) == "string" then
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

local nofalldmgmaps = {
	["12 convoy assault"] = function(player)
		return player.awayviewtics
	end
}

local function HL_GetFallDamage(fallSpeed, player)
	HL.valuemodes["HLFallDamage"] = HL_LASTFUNC

	local damage = HL.RunHook("HLFallDamage", fallSpeed, abs(fallSpeed) <= PLAYER_MAX_SAFE_FALL_SPEED, abs(fallSpeed) >= PLAYER_FATAL_FALL_SPEED)
	if damage ~= nil then
		return {dmg = damage, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	local mapkey = gamemap .. " " .. string.lower(G_BuildMapTitle(gamemap) or "")
	local nofalldmg = nofalldmgmaps[mapkey]

	-- Skip fall damage if map says so, if in water, or player flags it off
	if (nofalldmg and (type(nofalldmg) ~= "function" or nofalldmg(player)))
	or (player.mo.eflags & (MFE_TOUCHWATER|MFE_UNDERWATER) ~= 0)
	or (player.hl and (player.hl.nofalldmg or player.hl.fallcount))
	then
		if player.hl.fallcount then player.hl.fallcount = $-1 end
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	local fallspeed_abs = abs(fallSpeed)

	-- Respect cv_kombifalldamage.value before checking for safe/fatal speed thresholds
	local falldmgmode = cv_kombifalldamage.value
	if falldmgmode == -1 then -- "Dont"
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	elseif falldmgmode == 0 then -- "Fixed"
		return {dmg = 10, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	-- Handle safe fall (no damage) and fatal fall (max damage)
	if fallspeed_abs <= PLAYER_MAX_SAFE_FALL_SPEED then
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	elseif fallspeed_abs >= PLAYER_FATAL_FALL_SPEED then
		-- If not "On", still apply damage based on custom setting.
		if falldmgmode == 1 then -- "On"
			local calcDamage = FixedMul(fallspeed_abs - PLAYER_MAX_SAFE_FALL_SPEED, DAMAGE_FOR_FALL_SPEED)
			return {dmg = min(FixedInt(calcDamage), 100), fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
		else
			return {dmg = 100, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
		end
	end

	-- Handle fall damage between safe and fatal fall
	if falldmgmode == 1 then -- "On"
		local calcDamage = FixedMul(fallspeed_abs - PLAYER_MAX_SAFE_FALL_SPEED, DAMAGE_FOR_FALL_SPEED)
		return {dmg = min(FixedInt(calcDamage), 100), fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	-- Default fixed value
	return {dmg = 10, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
end

addHook("PlayerThink", function(player)
	if not player.mo then return end

	-- Handle impulse 201 call (since SRB2 seems to whine when we do it in the command itself)
	if player.hl and player.hl.spraying then
		SpawnSpray(player.mo)
		player.hl.spraying = false
	end

	-- If Freeman, handle fall damage
	if player.realmo.skin == "kombifreeman" then
		local mapkey = gamemap .. " " .. string.lower(G_BuildMapTitle(gamemap) or "")
		local nofalldmg = nofalldmgmaps[mapkey]
		if player.hl and (nofalldmg and (type(nofalldmg) ~= "function" or nofalldmg(player)))
			player.hl.fallcount = 1
		end
		if player.mo.eflags & MFE_JUSTHITFLOOR then
			local fallhurt = HL_GetFallDamage(abs(player.kombifallz or 0), player)
			if fallhurt.dmg then
				player.mo.hl1health = $-fallhurt.dmg
				S_StartSound(player.mo,P_RandomRange(sfx_hlfal1,sfx_hlfal3))
				if player.mo.hl1health <= 0 then
					player.mo.hl1health = 0
					P_KillMobj(player.mo, player.mo, player.mo, 0)
				end
			end
			if fallhurt.fallpunch then
				player.hl = $ or {}
				player.hl.viewrollpunch = ANG350+ANG2+ANG2+ANG2
			end
		elseif not P_IsObjectOnGround(player.mo) then
			-- Record the fall velocity for future fall damage checks
			player.kombifallz = player.mo.momz
		end
	end

	-- Handle decay of the view roll punch
	local decayRate = ANG1 / 4 -- How much to decay by each tic
	if player.hl and player.hl.viewrollpunch then
		if player.hl.viewrollpunch > 0 then
			player.hl.viewrollpunch = $ - decayRate
			if player.hl.viewrollpunch < 0 then player.hl.viewrollpunch = 0 end
		elseif player.hl.viewrollpunch < 0 then
			player.hl.viewrollpunch = $ + decayRate
			if player.hl.viewrollpunch > 0 then player.hl.viewrollpunch = 0 end
		end
	end
end)

local laddertextures = {
    CUT10   = true,
    LADDER1 = true,
    LADDER2 = true,
	ConL    = true,
}

local function intervalsIntersect(aBottom, aTop, bBottom, bTop)
    -- True if they share *any* non‑zero overlap
    return (aTop  > bBottom)
       and (aBottom < bTop)
end

addHook("MobjMoveBlocked", function(mo, thing, line)
    -- Basic sanity
    if not (mo and mo.valid and mo.player and line) then
        if mo.player then mo.player.hl = mo.player.hl or {} end
        return
    end

    local hl = mo.player.hl or {}
    mo.player.hl = hl

    -- Determine which side of the line we're on
    local sideIndex = P_PointOnLineSide(mo.x, mo.y, line)
    local mysec     = (sideIndex == 0) and line.frontsector or line.backsector
    local oppsec    = (sideIndex == 0) and line.backsector  or line.frontsector
    local sidedef   = (sideIndex == 0) and line.frontside   or line.backside

    local pBot = mo.z
    local pTop = mo.z + mo.height

    -- Prepare texture lookup table
    local ladderTexs = laddertextures

    -- Fast-path: iterate both sectors' ffloors lists in one go
    local sectors = { mysec, oppsec }
    for si = 1, 2 do
        local sec = sectors[si]
        if sec then
            for ff in sec.ffloors() do
                if ff.valid and (ff.flags & FOF_EXISTS) ~= 0 then
                    local fBot = ff.bottomheight
                    local fTop = ff.topheight

                    if intervalsIntersect(fBot, fTop, pBot, pTop) then
                        local ms = ff.master.frontside
                        if ms then
                            -- grab all three texture names once
                            local mid  = R_TextureNameForNum(ms.midtexture)
                            local top  = R_TextureNameForNum(ms.toptexture)
                            local bot  = R_TextureNameForNum(ms.bottomtexture)

                            if ladderTexs[mid] or ladderTexs[top] or ladderTexs[bot] then
                                hl.climb             = true
                                hl.climbing          = line
                                hl.climbing_is_front = sideIndex
                                hl.ladderbottom     = fBot
                                hl.laddertop        = fTop
                                return
                            end
                        end
                    end
                end
            end
        end
    end

    -- No FOF ladder found — fall back on sidedef textures
    if sidedef then
        local mt = R_TextureNameForNum(sidedef.midtexture)
        local tt = R_TextureNameForNum(sidedef.toptexture)
        local bt = R_TextureNameForNum(sidedef.bottomtexture)

        if ladderTexs[mt] or ladderTexs[tt] or ladderTexs[bt] then
            hl.climb             = true
            hl.climbing          = line
            hl.climbing_is_front = sideIndex

            if mysec ~= oppsec then
                -- two different sectors
                hl.ladderbottom = mysec.floorheight
                hl.laddertop    = oppsec.floorheight
            else
                -- single-sided line
                hl.ladderbottom = mysec.floorheight
                hl.laddertop    = mysec.ceilingheight
            end

            return
        end
    end

    -- Not a ladder: clear stored data
    hl.climb        = nil
    hl.climbing     = nil
    hl.ladderbottom = nil
    hl.laddertop    = nil
end, MT_PLAYER)

local function ClosestPointOnSegment_t(px, py, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local denom = FixedMul(dx,dx) + FixedMul(dy,dy)
    if denom == 0 then
        return x1, y1, 0, true
    end

    -- projection numerator
    local num = FixedMul(px - x1, dx) + FixedMul(py - y1, dy)
    -- unclamped t in fixed [0..FRACUNIT] space
    local tUnc = FixedDiv(num, denom)

    local outside = false
    local t = tUnc
    if tUnc < 0 then
        t, outside = 0, true
    elseif tUnc > FRACUNIT then
        t, outside = FRACUNIT, true
    end

    local cx = x1 + FixedMul(t, dx)
    local cy = y1 + FixedMul(t, dy)
    return cx, cy, t, outside
end

addHook("PreThinkFrame", function()
    for player in players.iterate do
        local mo = player.mo
        if not (mo and mo.valid) then
            if mo then mo.flags = mo.flags & ~MF_NOGRAVITY end
            continue
        end

        local cmd = player.cmd
        local hl  = player.hl or {}
        player.hl = hl

        if hl.climb and hl.climbing then
            -- vertical check
            local bottom = min(hl.ladderbottom, hl.laddertop)
            local top    = max(hl.ladderbottom, hl.laddertop)
            if mo.z < bottom or mo.z > top then
				print("Vertical check fail!")
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                cmd.forwardmove, cmd.sidemove = 0,0
                continue
            end

            -- corner-segment detach
            local x1,y1 = hl.climbing.v1.x, hl.climbing.v1.y
            local x2,y2 = hl.climbing.v2.x, hl.climbing.v2.y
            local ladangle = R_PointToAngle2(x1,y1, x2,y2)

            -- ladder-plane normal
            local nx,ny = cos(ladangle+ANGLE_90), sin(ladangle+ANGLE_90)
            if not hl.climbing_is_front then nx,ny = -nx,-ny end

            -- ladder tangent (for horizontal)
            local tx,ty = cos(ladangle), sin(ladangle)

            local radius = mo.radius
            local thr   = FixedMul(radius, abs(nx)+abs(ny))
            local SAFE  = FRACUNIT/8

            local anyOn = false
            for _,off in ipairs({{radius,radius},{radius,-radius},{-radius,radius},{-radius,-radius}}) do
                local px,py = mo.x+off[1], mo.y+off[2]
                local cx,cy,t,out = ClosestPointOnSegment_t(px,py, x1,y1, x2,y2)
                if not out then
                    local dx,dy = px-cx, py-cy
                    local dist  = FixedSqrt(FixedMul(dx,dx)+FixedMul(dy,dy))
                    if dist <= thr+SAFE then
                        anyOn = true
                        break
                    end
                end
            end
            if not anyOn then
				print("Attach fail!")
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                cmd.forwardmove, cmd.sidemove = 0,0
                continue
            end

            -- climb movement + sound
            mo.flags = mo.flags | MF_NOGRAVITY

            -- scale inputs into fixed speeds
            local ZSPEED = 6*FRACUNIT
            local XSPEED = 6*FRACUNIT
            local f = cmd.forwardmove * FRACUNIT
            local s = cmd.sidemove    * FRACUNIT

            -- sound timer (16-tic interval)
            hl.sndtick = hl.sndtick or 0
            if f != 0 or s != 0 then
                hl.sndtick = hl.sndtick + 1
                if hl.sndtick >= 16 then
                    hl.sndtick = 0
                    local sfx = sfx_hlla1 + P_RandomRange(0,3)
                    S_StartSound(mo, sfx)
                end
            end

            -- map into velocities
            local fv = FixedMul(f, FixedDiv(ZSPEED, 50*FRACUNIT))
            -- band-aid invert sidemove so right>0 moves you right
            local rv = FixedMul(-s, FixedDiv(XSPEED, 50*FRACUNIT))

            cmd.forwardmove, cmd.sidemove = 0,0

            -- jump off
            if cmd.buttons & BT_JUMP ~= 0 then
                mo.momx = FixedMul(nx, 12*FRACUNIT)
                mo.momy = FixedMul(ny, 12*FRACUNIT)
				P_SetObjectMomZ(mo, 4*FRACUNIT)
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                continue
            end

            -- build world-space vel exactly like HL
            local a = mo.angle
            local vpnx,vpny = cos(a), sin(a)
            local vrx, vry  = cos(a+ANGLE_90), sin(a+ANGLE_90)
            local vx = FixedMul(vpnx,fv) + FixedMul(vrx,rv)
            local vy = FixedMul(vpny,fv) + FixedMul(vry,rv)

            -- decompose: lateral XY + −normal→Z
            local normal = FixedMul(vx,nx) + FixedMul(vy,ny)
            local lx = vx - FixedMul(nx, normal)
            local ly = vy - FixedMul(ny, normal)

            mo.momx = lx
            mo.momy = ly
            mo.momz = -normal
        else
            mo.flags = mo.flags & ~MF_NOGRAVITY
        end
    end
end)

-- Aliased key binds.
-- Note: By prefixing the command with "+", you automatically mark the command as dual.
local defaultKeyBinds = {
	e				 = "+use",			-- SHIELD (when it exists)
	r				 = "+reload",		-- CUSTOM 1
	lctrl			 = "+duck",			-- SPIN
	lshift			 = "+speed",		-- CUSTOM 3
	f				 = "impulse 100",	-- CUSTOM 2
	t				 = "impulse 201",
	["0"]			 = "slot0",
	["1"]			 = "slot1",			-- WPN SLOT 1
	["2"]			 = "slot2",			-- WPN SLOT 2
	["3"]			 = "slot3",			-- WPN SLOT 3
	["4"]			 = "slot4",			-- WPN SLOT 4
	["5"]			 = "slot5",			-- WPN SLOT 5
	["6"]			 = "slot6",			-- WPN SLOT 6
	["7"]			 = "slot7",			-- WPN SLOT 7
	["8"]			 = "slot8",
	["9"]			 = "slot9",
	["wheel 1 up"]	 = "invprev",
	["wheel 1 down"] = "invnext",
}

-- Constants for battery drain/recharge rates
local DRAIN_RATE = FRACUNIT / 20     -- drain 1/20 battery unit per tick
local RECHARGE_RATE = FRACUNIT / 25  -- recharge 1/25 battery unit per tick
local MAX_BATTERY = 100 * FRACUNIT

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
	player.hlinv = $ or {}
	player.hl1ammo = startammo or $ or {
		buckshot = 125,
		["9mm"] = 68, -- the only value we have set in stone... (def 68)
		["357"] = 36,
		bolt = 50,
		grenade = 10,
		melee = -1, -- these two require values so that any user error with default ammo types won't be pinned on me
		none = -1, -- ^ because yeah of COURSE it'd throw an error at you if you tried to decrement it IT WASN'T EVEN SUPPOSED TO BE DECREMENTED
	}
	player.hlinv.wepclips = startclips or $ or {
		melee = -1
	}
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
	player.hl = $ or {}
	player.hl.flashlightbattery = MAX_BATTERY
	if not player.hlinv.wepclips[player.hl1weapon] then
		local clipsize = HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.clipsize or -1
		local clipsize2 = HL_WpnStats[player.hl1weapon].secondary and HL_WpnStats[player.hl1weapon].secondary.clipsize or -1
		player.hlinv.wepclips[player.hl1weapon] = {primary = clipsize, secondary = clipsize2}
	end
	HL_ChangeViewmodelState(player, "ready", "idle")
end)

addHook("PlayerHeight", function(player)
	local shouldCrouch = (player.cmd.buttons & BT_SPIN) or (player.hlcmds and player.hlcmds.duck) or not (P_CheckPosition(player.mo, player.mo.x, player.mo.y, true) and (player.prevpos and P_CheckPosition(player.mo, player.prevpos.x, player.prevpos.y, true)))
	if shouldCrouch then return player.spinheight end
end)

addHook("PlayerCanEnterSpinGaps", function(player)
	if not player.mo then return end
	local shouldCrouch = (player.cmd.buttons & BT_SPIN) or (player.hlcmds and player.hlcmds.duck) or not (P_CheckPosition(player.mo, player.mo.x, player.mo.y, true) and (player.prevpos and P_CheckPosition(player.mo, player.prevpos.x, player.prevpos.y, true)))
	if shouldCrouch then return true end
end)

local srb2defviewheight = 89 * FRACUNIT -- def == 41

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin ~= skin then return end
	if not player.hl then player.hl = {} end

	local spinHeight = P_GetPlayerSpinHeight(player)
	local normalHeight = P_GetPlayerHeight(player)
	local shouldCrouch = (player.cmd.buttons & BT_SPIN) or (player.hlcmds and player.hlcmds.duck) or not (P_CheckPosition(player.mo, player.mo.x, player.mo.y, true) and (player.prevpos and P_CheckPosition(player.mo, player.prevpos.x, player.prevpos.y, true)))

	player.mo.height = normalHeight

	-- Reset this so div operations don't make us unable to walk
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
		player.mo.height = spinHeight

		local moving = (abs(player.mo.momx) > 0 or abs(player.mo.momy) > 0)

		if not player.hl.crouching then
			-- Adjust vertical position when crouch jumping
			if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then
				if player.mo.eflags & MFE_VERTICALFLIP then
					player.mo.z = $ - abs(normalHeight - spinHeight)
				else
					player.mo.z = $ + abs(normalHeight - spinHeight)
				end
			end
		end

		-- Set the crouching animation depending on movement
		if moving then
			if not player.realmo.state == S_PLAY_FREEMCROUCH
				player.realmo.state = S_PLAY_FREEMCROUCH
			end
		else
			if not player.realmo.state == S_PLAY_FREEMCROUCHMOVE
				player.realmo.state = S_PLAY_FREEMCROUCHMOVE
			end
		end
	elseif player.hl.crouching then
		-- Adjust vertical position when standing up in the air
		player.mo.height = normalHeight
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

	-- Crouch modifiers
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

	-- Automatically set spriteyscale because we don't have sprites for crouching yet
	player.mo.spriteyscale = FixedDiv(player.mo.height, 60*FRACUNIT)

	-- Flashlight thinker
	if player.hl.flashlightbattery <= 0 then
		player.hl.flashlight = false
		S_StartSound(player.mo, sfx_hlflas)
	end

	if player.hl.flashlight then
		if player.hl.flashlightbeam and player.hl.flashlightbeam.valid then
			player.hl.flashlightbeam.flags2 = $&~MF2_DONTDRAW
		end
		player.hl.flashlightbattery = player.hl.flashlightbattery - DRAIN_RATE
		P_SpawnPlayerMissile(player.mo, MT_HLFLASHLIGHTBEAM)
		if player.hl.flashlightbattery < 0 then
			player.hl.flashlightbattery = 0
		end
	else
		if player.hl.flashlightbeam and player.hl.flashlightbeam.valid then
			player.hl.flashlightbeam.flags2 = $|MF2_DONTDRAW
		end
		if player.hl.flashlightbattery < MAX_BATTERY then
			player.hl.flashlightbattery = player.hl.flashlightbattery + RECHARGE_RATE
			if player.hl.flashlightbattery > MAX_BATTERY then
				player.hl.flashlightbattery = MAX_BATTERY
			end
		end
	end

	-- Execute jump if buffered and on ground
	if ((player.cmd.buttons & BT_JUMP) or (player.hlcmds and player.hlcmds.jump)) and P_IsObjectOnGround(player.mo) then
		L_MakeFootstep(player, "jump")
		P_DoJump(player)
	end

	-- Make maps using these at least somewhat playable
	if player.powers[pw_carry] == CR_MACESPIN then
		player.hl = $ or {}
		player.hl.nophys = true
	end

	-- Disable falling damage under these conditions (maybe because of script breaks, or whatever may occur)
	-- Functionally different from nofalldmgmaps, as this is checked for no matter what map we're on (so we don't have to add every map in existence)
	if player.powers[pw_carry] == CR_MACESPIN
	   or player.charaswap
	then
		player.hl = $ or {}
		player.hl.nofalldmg = true
	end

	-- ...But clear the associated variables when we don't need them anymore.
	if player.hl and player.hl.nophys and P_IsObjectOnGround(player.mo) then
		player.hl = $ or {}
		player.hl.nophys = false
		player.hl.nofalldmg = false
	end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	player.hl1kickback = $ or 0
	if player.mo.skin != skin then return end
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

local function hasUsableWeapons(sel)
	return getFirstUsableIndex(sel) ~= nil
end

addHook("PlayerThink", function(player)
    if not player.mo then return end
	if player.mo.skin != skin then return end

    -- Selection via BT_WEAPONNEXT/PREV
    if not player.kombipressingselkeys then
        if player.cmd.buttons & BT_WEAPONNEXT then
            HL_CycleWeapon(player, "prev")
            player.kombipressingselkeys = true
        elseif player.cmd.buttons & BT_WEAPONPREV then
            HL_CycleWeapon(player, "next")
            player.kombipressingselkeys = true
        end
    else
        player.kombipressingselkeys = false
    end

    -- Selection via slot keys
    local slotKey = player.desiredSlot
    local mask = player.cmd.buttons & BT_WEAPONMASK
    if mask ~= 0 then
        slotKey = mask
    end

    if slotKey ~= nil and not player.kombipressingwpnkeys then
        -- remember if this really is the “first open”
        local firstOpen = not player.kombiaccessinghl1menu

        local prevCat = player.kombihl1category or -1
        local newCat  = slotKey
        player.kombiprevhl1category = prevCat
        player.kombihl1category     = newCat

        -- get the new selection list
        local sel = HL_GetWeapons(HL_WpnStats, newCat, player) or emptySelection()
        player.selectionlist = sel

        if sel.weaponcount > 0 and hasUsableWeapons(sel) then
            if firstOpen then
                -- on first open always pick the first slot
                player.kombihl1wpn = 1
            else
                -- same-category wrap or new-category default
                if newCat ~= prevCat then
                    player.kombihl1wpn = getFirstUsableIndex(sel) or 0
                else
                    local cur = player.kombihl1wpn or 1
                    player.kombihl1wpn = cycleWithinCategoryWrap(sel, cur, 1) or cur
                end
            end
        else
            player.kombihl1wpn = 0
        end

        -- play sound, mark state
        player.kombiaccessinghl1menu = true
        S_StartSound(player.mo,
            (newCat ~= prevCat or firstOpen)
              and sfx_pwepst or sfx_pwepsl
        )
        player.kombipressingwpnkeys = true
        player.desiredSlot = nil
    elseif player.kombipressingwpnkeys then
        player.kombipressingwpnkeys = false
    end

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
	if not (src and src.valid) then return true end
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

		if player.hl1frame > highestIndex then
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
	if not player.hlinv.wepclips[player.hl1weapon]
		player.hlinv.wepclips[player.hl1weapon] = {
			HL_WpnStats[player.hl1weapon].primary and HL_WpnStats[player.hl1weapon].primary.clipsize or -1,
			HL_WpnStats[player.hl1weapon].secondary and HL_WpnStats[player.hl1weapon].secondary.clipsize or -1
		}
	end

	-- Set-up reloading
	local weapon_stats = HL_WpnStats[player.hl1weapon]
	local weapon_clips = player.hlinv.wepclips[player.hl1weapon]
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
				local wasempty = weapon_clips.primary <= 0
				local to_reload = min(max_reload, available_ammo)
				player.hl1ammo[ammo_type] = $ - to_reload
				weapon_clips.primary = $ + to_reload
				local wepstats = weapon_stats or HL_WpnStats["9mmhandgun"]
				player.kombireloading = 0
				player.hl1weapondelay = wasempty and wepstats.globalfiredelay.reloadpost or 0
			end
		else
			print("Weapon " .. player.hl1weapon .. " missing necessary stats! Check 'clipsize' and 'ammo'.")
		end
	end
end)