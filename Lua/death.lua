-- Utility function for safe slot freeing
local function SafeFreeSlot(...)
	for _, slot in ipairs({...}) do
		if not rawget(_G, slot) then
			freeslot(slot) -- Ensure we don't accidentally overlap existing freeslots
		end
	end
end

SafeFreeSlot("sfx_frbeep", "sfx_frflat")

-- Fix some other chuckler's code
if not customdeaths then
	rawset(_G, "customdeaths", {})
end

customdeaths["kombifreeman"] = true

-- Hook for handling player death
addHook("MobjDeath", function(mobj, inflictor, source, damageType)
	if mobj.skin ~= "kombifreeman" then return end

	mobj.height = mobj.player.spinheight
	mobj.kombixvel = mobj.momx
	mobj.kombiyvel = mobj.momy
	mobj.kombizvel = mobj.momz
	mobj.player.viewrollangle = ANGLE_90
	mobj.player.hl1nopostflat = false

	return true
end, MT_PLAYER)

-- Helper function for handling death sounds and timers
local function HandleDeathSounds(player, mobj)
	local timer = player.hl1deadtimer or 0

	local sound_schedule = {
		[0] = function()
			if P_RandomChance(FRACUNIT / 6) then
				S_StartSound(mobj, sfx_frflat)
				timer = 107
			else
				S_StartSound(mobj, sfx_frbeep)
			end
		end,
		[8] = function() S_StartSound(mobj, sfx_frbeep) end,
		[26] = function() S_StartSound(mobj, sfx_frbeep) end,
		[34] = function() S_StartSound(mobj, sfx_frbeep) end,
		[52] = function() S_StartSound(mobj, sfx_frbeep) end,
		[70] = function()
			if P_RandomChance(FRACUNIT / 2) then
				S_StartSound(mobj, sfx_frbeep)
			else
				S_StartSound(mobj, sfx_frflat)
				timer = 107
			end
		end,
		[88] = function()
			if P_RandomChance(FRACUNIT / 2) then
				S_StartSound(mobj, sfx_frbeep)
			else
				S_StartSound(mobj, sfx_frflat)
				timer = 107
			end
		end,
		[106] = function() S_StartSound(mobj, sfx_frflat) end
	}

	if sound_schedule[timer] then
		sound_schedule[timer]()
	elseif timer > 106 then
		player.deadtimer = timer - (107 + TICRATE)
	end

	player.hl1deadtimer = (timer + 1)
end

-- ThinkFrame Hook
addHook("ThinkFrame", function()
	for player in players.iterate do
		if player.playerstate == PST_DEAD and player.mo.skin == "kombifreeman" then
			local camera_to_update = (splitscreen and secondarydisplayplayer == player) and camera2 or camera

			if camera_to_update then
				camera_to_update.momz = camera_to_update.momz + player.mo.kombizvel
			end

			player.mo.kombizvel = player.mo.kombizvel + (P_GetMobjGravity(player.mo) or -FRACUNIT)
			player.viewrollangle = ANGLE_90
			player.deadtimer = 0

			HandleDeathSounds(player, player.mo)
		end
	end
end)

-- Hook for handling damage direction
addHook("MobjDamage", function(target, inflictor, source, damage, damageType)
	if inflictor then
		target.player.hl1dmgdir = FixedInt(AngleFixed(R_PointToDist2(target.x, target.y, inflictor.x, inflictor.y)))
	end
end, MT_PLAYER)
