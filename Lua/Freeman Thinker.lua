local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end
	end
end

local skin = "kombifreeman"

SafeFreeSlot("SPR2_CRCH", "S_PLAY_FREEMCROUCH")

states[S_PLAY_FREEMCROUCH] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRCH,
	tics = -1,
	var1 = 3,
	var2 = 4,
	nextstate = S_PLAY_FREEMCROUCH
}

addHook("PlayerHeight", function(player)
	if not player.mo return end
	if player.realmo.state == S_PLAY_FREEMCROUCH return player.spinheight end
end)

addHook("PlayerCanEnterSpinGaps", function(player) -- just let us use PlayerHeight and be done with it dude
	if not player.mo return end
	if player.realmo.state == S_PLAY_FREEMCROUCH return true end
end)

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin return end
	if (player.cmd.buttons & BT_SPIN)
		player.realmo.state = S_PLAY_FREEMCROUCH
	elseif player.realmo.state == S_PLAY_FREEMCROUCH
		player.realmo.state = S_PLAY_STND
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
end)