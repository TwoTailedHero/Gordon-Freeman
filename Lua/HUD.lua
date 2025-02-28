local function K_DrawHL1Number(v,num,x,y,flags,colormap,redtintingmin)
	local donum = tostring(abs(num or 0))
	local xpos = (x or 0) - 10*FRACUNIT
	local ypos = (y or 0) - 12*FRACUNIT
	local textflags = flags or 0
	local cmap
	if redtintingmin == nil or num > redtintingmin
		cmap = colormap or v.getColormap(nil, SKINCOLOR_ORANGE)
	else
		cmap = v.getColormap(nil, SKINCOLOR_RED)
	end
	for i = 0,#donum-1 do
		local dothis = (donum or 0)/(10^i)%10 or 0
		v.drawCropped(xpos, ypos, FRACUNIT/2, FRACUNIT/2, v.cachePatch("HL1NUMS"), textflags, cmap, (24*FRACUNIT)*dothis, 0, 20*FRACUNIT, 24*FRACUNIT)
		xpos = $-(10*FRACUNIT)
	end
end

hud.add(function(v, player)
	if not player.mo return end
	if kombilastseen and kombilastseen.valid and kombilastseen.mo.skin == "kombifreeman"
		-- display the freeman's status if we're hovering over him
		-- aesthetic taken from GMod at least that's where i first saw the username/health display thing from :3
		-- TODO: How can I check for teams, here?
		local splayer = kombilastseen
		local sweapon = splayer.hl1weapon
		local swepstats = HL_WpnStats[sweapon]
		local swepname = swepstats.realname or sweapon
		v.drawString(160,124,"Wielding \$swepname\",V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF,"thin-center")
		v.drawString(160,132,"\$splayer.mo.hl1health\%",V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF,"thin-center")
	end
	if player.mo.skin != "kombifreeman" return end
	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	hud.disable("lives")
	hud.disable("weaponrings")
	hud.disable("crosshair")

	-- Viewmodel
	pcall(function()
		if player.playerstate != PST_DEAD and camera.chase == false and player.hl1inventory[player.hl1weapon]
			local angle = FixedAngle((leveltime*12)*FRACUNIT)
			local kmbivmdl = HL_WpnStats[player.hl1weapon].viewmodel or "PISTOL"
			local curvmdl = kombihl1viewmodels[kmbivmdl]
			local vmdl = kombihl1viewmodels[kmbivmdl]["\$player.hl1viewmdaction\frames"][player.hl1frameindex]
			local curframe = player.hl1frame or 1
			local vmdlflags = V_PERPLAYER
			if curvmdl["flags"] and (curvmdl["flags"] & VMDL_FLIP)
				vmdlflags = $|V_FLIP
			end
			if HL_WpnStats[player.hl1weapon].doombob
				local angle = ((128*leveltime)&8191)<<19
				local bobx = FixedMul((player.hl1wepbob or 0), cos(angle))
				angle = ((128*leveltime)&4095)<<19
				local boby = FixedMul((player.hl1wepbob or 0), sin(angle))
				v.drawScaled((160*FRACUNIT)+bobx,
					(106*FRACUNIT)+boby,
					FRACUNIT,
					v.cachePatch("VMDL\$kmbivmdl\\$curframe\"),
					vmdlflags,
					v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel))
				if vmdl and vmdl['overlay']
				v.drawScaled((160*FRACUNIT)+bobx,
					(106*FRACUNIT)+boby,
					FRACUNIT,
					v.cachePatch("VMDL\$kmbivmdl\\$vmdl['overlay']\"),
					vmdlflags,
					v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel))
				end
			else
				v.drawScaled(160*FRACUNIT,
					106*FRACUNIT,
					FRACUNIT+FixedMul(FRACUNIT, FixedMul((player.hl1wepbob or 0)/256, sin(angle))),
					v.cachePatch("VMDL\$kmbivmdl\\$curframe\"),
					vmdlflags,
					v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel))
			end
		end
	end)

	-- Ammo
	pcall(function()
		local weaponStats = HL_WpnStats[player.hl1weapon]
		if weaponStats.ammo ~= "melee" then
			K_DrawHL1Number(v, player.hl1ammo[weaponStats.ammo], 315 * FRACUNIT, 196 * FRACUNIT, V_ADD | V_PERPLAYER, v.getColormap(nil, player.skincolor))
		end
		if player.hl1clips[player.hl1weapon] and player.hl1clips[player.hl1weapon][1] >= 0 then
			v.drawScaled(283 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor))
			K_DrawHL1Number(v, player.hl1clips[player.hl1weapon][1], 280 * FRACUNIT, 196 * FRACUNIT, V_ADD | V_PERPLAYER, v.getColormap(nil, player.skincolor))
		end
	end)

	-- Crosshair
	pcall(function()
		local weaponStats = HL_WpnStats[player.hl1weapon]
		if weaponStats.crosshair then
			v.drawScaled(160 * FRACUNIT, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch(weaponStats.crosshair), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor))
		end
	end)

	-- Health
	pcall(function()
		local healthColor = (player.mo.hl1health > 25) and player.skincolor or SKINCOLOR_RED
		v.drawScaled(5 * FRACUNIT, 182 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDCROSS"), V_PERPLAYER | V_ADD, v.getColormap(nil, healthColor))
		K_DrawHL1Number(v, player.mo.hl1health, 50 * FRACUNIT, 196 * FRACUNIT, V_ADD | V_PERPLAYER, v.getColormap(nil, player.skincolor), 25)
		v.drawScaled(50 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor))
	end)

	-- Flashlight
	pcall(function()
		if player.hl1flashlightuse then
			v.drawScaled(306 * FRACUNIT, 7 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDFLASHB"), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor))
		end
	end)

	-- Armor
	pcall(function()
		local armor = min(player.mo.hl1armor, 100 * FRACUNIT)
		local crop = FixedDiv((100 * FRACUNIT - armor) * 40, 100 * FRACUNIT)
		v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITE"), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor), 0, 0, 40 * FRACUNIT, crop)
		v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT + crop / 2, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITF"), V_PERPLAYER | V_ADD, v.getColormap(nil, player.skincolor), 0, crop, 40 * FRACUNIT, 40 * FRACUNIT - crop)
		K_DrawHL1Number(v, player.mo.hl1armor / FRACUNIT, 99 * FRACUNIT, 196 * FRACUNIT, V_ADD | V_PERPLAYER, v.getColormap(nil, player.skincolor))
	end)

	-- Damage Direction Indicator (Currently Empty)
	pcall(function()
		if player.hl1dmgdir then
			-- You may want to add visual feedback for different damage directions here
		end
	end)

	-- Pickup History Display
	pcall(function()
		for pickupid, pickupshit in pairs(player.pickuphistory or {}) do
			if pickupshit.time then
				pickupshit.time = pickupshit.time - 1
				if pickupshit.time <= 0 then
					player.pickuphistory[pickupid] = nil
				end
			end
			local displayText = pickupshit.count and string.format("%s %s x%s", pickupshit.type, pickupshit.thing, pickupshit.count) or string.format("%s %s", pickupshit.type, pickupshit.thing)
			v.drawString(0, pickupid * 8, displayText)
		end
	end)

	-- Weapon Selection Menu
	pcall(function()
		if not player.kombihl1wpn then return end
		local weaponamount = player.selectionlist["weaponcount"]
		local weaponlist = player.selectionlist["weapons"]
		local weaponslots = player.selectionlist["wepslotamounts"]
		local colormap = v.getColormap(nil, player.skincolor)

		-- Weapon Category Buckets
		for i = 1, 7 do
			local drawx = ((i > player.kombihl1category) and weaponlist and 65 or -10) * FRACUNIT + (i * 12 * FRACUNIT)
			v.drawScaled(drawx, 2 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HUDSELBUCKET" .. i), V_PERPLAYER | V_ADD, colormap)
			for d = 1, weaponslots[i] do
				if i == player.kombihl1category then break end
				v.drawScaled(drawx, 2 * FRACUNIT + (d * 12 * FRACUNIT), FRACUNIT / 2, v.cachePatch("HUDSELBUCKETITEM"), V_PERPLAYER | V_ADD, colormap)
			end
		end

		-- Individual Weapon Selection
		for i = 1, weaponamount do
			local currentweapon = weaponlist[i]['name']
			local wepproperties = HL_WpnStats[currentweapon]
			local selectgraphic = wepproperties.selectgraphic or "HL1HUD9MM"
			local ammostats = HL_AmmoStats[wepproperties.ammo] or { max = 0 }

			-- Highlight Selected Weapon
			if i == player.kombihl1wpn then
				selectgraphic = selectgraphic .. "S"
			end

			-- Determine Ammo Availability
			if (player.hl1clips[currentweapon] and player.hl1clips[currentweapon][1] <= 0) and player.hl1ammo[wepproperties.ammo] and player.hl1ammo[wepproperties.ammo] <= 0 and not wepproperties["neverdenyuse"] then
				colormap = v.getColormap(nil, SKINCOLOR_RED)
			else
				colormap = v.getColormap(nil, player.skincolor)
			end

			-- Draw Weapon Icon
			v.drawScaled(-10 * FRACUNIT + (player.kombihl1category * 12 * FRACUNIT), (14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2), FRACUNIT / 2, v.cachePatch(selectgraphic), V_PERPLAYER | V_ADD, colormap)

			-- Draw Ammo Bar
			if player.hl1ammo[wepproperties.ammo] then
				local effectiveMaxAmmo = player.hl1doubleammo and (ammostats.backpackmax or ammostats.max * 2) or ammostats.max

				v.drawStretched(-9 * FRACUNIT + (player.kombihl1category * 12 * FRACUNIT), (15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2), FRACUNIT * 10, 5 * FRACUNIT / 2, v.cachePatch("HL1HUDSELGRAY"), V_PERPLAYER | V_50TRANS)
				v.drawStretched(-9 * FRACUNIT + (player.kombihl1category * 12 * FRACUNIT), (15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2), FixedDiv((player.hl1ammo[wepproperties.ammo] or 0) * 10, effectiveMaxAmmo or 10), 5 * FRACUNIT / 2, v.cachePatch("HL1HUDSELGREEN"), V_PERPLAYER)
			end
		end
	end)
end, "game")