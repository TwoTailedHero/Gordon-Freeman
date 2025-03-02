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
	if not HL1_DMGStats[inf.type] print("Aggressor has no associated stats!") return end
	local objdamage = HL1_DMGStats[inf.type].damage
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
		local inf = (not HL1_DMGStats[src.type].damage.preferaggressor and src) or hurter
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