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

local function HL_GetDamage(inf)
	if not HL1_DMGStats[inf.type].damage print("Aggressor has no associated stats!") return end
	if type(HL1_DMGStats[inf.type].damage) == "number"
		return HL1_DMGStats[inf.type].damage
	elseif type(HL1_DMGStats[inf.type].damage) == "table"
		local objdamage = HL1_DMGStats[inf.type].damage
		if objdamage.min and objdamage.max
			local max = objdamage.max
			local min = objdamage.min
			local increment = objdamage.increments
			print(max, min, increment)
			return (P_RandomByte()%(increment and max/increment or max/min) + 1)*(increment or min)
		else
			return objdamage.dmg
		end
	end
end

addHook("MobjDamage", function(target, inf, src, dmg, dmgType)
	if target.skin == "kombifreeman"
		local inf = inf.target or inf
		HL.valuemodes["HLFreemanHurt"] = HL_LASTFUNC
		local hookeddamage, hookeddamagetype = HL.RunHook("HLFreemanHurt", target, inf, src, dmg, dmgType)
		if not (dmgType & DMG_DEATHMASK) and inf and not (inf.type and inf.type == MT_EGGMAN_ICON)
			if inf.player
				P_AddPlayerScore(inf.player, 50)
			end
		end
		if not inf return end
		local damage = hookeddamage or HL_GetDamage(inf)
		if not HL1_DMGStats[inf.type] print("No DMGStats found for aggressor!") HL1_DMGStats[inf.type] = {damage = 0} end
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