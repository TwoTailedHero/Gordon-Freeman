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

hud.add(function(v,player)
	if not player.mo return end
	if kombilastseen and kombilastseen.valid and kombilastseen.mo.skin == "kombifreeman"
		local splayer = kombilastseen
		local sweapon = splayer.hl1weapon
		local swepstats = HL_WpnStats[sweapon]
		local swepname = swepstats.realname or sweapon
		v.drawString(160,124,"Wielding \$swepname\",V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF,"thin-center") -- Text ~8px
		v.drawString(160,132,"\$splayer.mo.hl1health\%",V_GREENMAP|V_ALLOWLOWERCASE|V_HUDTRANSHALF,"thin-center")
	end
	if player.mo.skin == "kombifreeman"
		hud.disable("score")
		hud.disable("time")
		hud.disable("rings")
		hud.disable("lives")
		hud.disable("weaponrings")
		hud.disable("crosshair")
		if player.playerstate != PST_DEAD and camera.chase == false and player.hl1inventory[player.hl1weapon] -- I think somewhere in this massive heap of code is something that doesn't fall in line with 2.2.13's functions. Not fixing it until I remember to test in that version!
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
					v.cachePatch("VMDL\$kmbivmdl\\$vmdl['overlay']\"),
					vmdlflags,
					v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel))
			else
				v.drawScaled(160*FRACUNIT,
					106*FRACUNIT,
					FRACUNIT+FixedMul(FRACUNIT, FixedMul((player.hl1wepbob or 0)/256, sin(angle))),
					v.cachePatch("VMDL\$kmbivmdl\\$curframe\"),
					vmdlflags,
					v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel))
			end
		end
		if not (HL_WpnStats[player.hl1weapon].ammo == "melee")
			K_DrawHL1Number(v,player.hl1ammo[HL_WpnStats[player.hl1weapon].ammo],315*FRACUNIT,196*FRACUNIT,V_ADD|V_PERPLAYER,v.getColormap(nil, player.skincolor))
		end
		if player.hl1clips[player.hl1weapon] and player.hl1clips[player.hl1weapon][1] >= 0
			v.drawScaled(283*FRACUNIT, 184*FRACUNIT, FRACUNIT/2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
			K_DrawHL1Number(v,player.hl1clips[player.hl1weapon][1],280*FRACUNIT,196*FRACUNIT,V_ADD|V_PERPLAYER,v.getColormap(nil, player.skincolor))
		end
		if HL_WpnStats[player.hl1weapon].crosshair
			v.drawScaled(160*FRACUNIT, 100*FRACUNIT, FRACUNIT/2, v.cachePatch(HL_WpnStats[player.hl1weapon].crosshair), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
		end
		if player.mo.hl1health > 25
			v.drawScaled(5*FRACUNIT, 182*FRACUNIT, FRACUNIT/2, v.cachePatch("HL1HUDCROSS"), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
		else
			v.drawScaled(5*FRACUNIT, 182*FRACUNIT, FRACUNIT/2, v.cachePatch("HL1HUDCROSS"), V_PERPLAYER|V_ADD, v.getColormap(nil, SKINCOLOR_RED))
		end
		K_DrawHL1Number(v,player.mo.hl1health,50*FRACUNIT,196*FRACUNIT,V_ADD|V_PERPLAYER,v.getColormap(nil, player.skincolor),25)
		
		v.drawScaled(50*FRACUNIT, 184*FRACUNIT, FRACUNIT/2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
		local flashcrop = FixedDiv((100-100)*32,100)
		v.drawCropped(
			290*FRACUNIT + flashcrop/2,
			7*FRACUNIT,
			FRACUNIT/2,
			FRACUNIT/2,
			v.cachePatch("HL1HUDFLASHE"),
			V_PERPLAYER|V_ADD,
			v.getColormap(nil, player.skincolor),
			flashcrop,
			0,
			32*FRACUNIT - flashcrop,
			32*FRACUNIT
		)
		v.drawCropped(
			290*FRACUNIT,
			7*FRACUNIT,
			FRACUNIT/2,
			FRACUNIT/2,
			v.cachePatch("HL1HUDFLASHF"),
			V_PERPLAYER|V_ADD,
			v.getColormap(nil, player.skincolor),
			0,
			0,
			32*FRACUNIT - flashcrop,
			32*FRACUNIT
		)
		if player.hl1flashlightuse
			v.drawScaled(306*FRACUNIT, 7*FRACUNIT, FRACUNIT/2, v.cachePatch("HL1HUDFLASHB"), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
		end
		local armor = min(player.mo.hl1armor, 100*FRACUNIT)
		local crop = FixedDiv((100*FRACUNIT-armor)*40,100*FRACUNIT)
		v.drawCropped(
			52*FRACUNIT,
			178*FRACUNIT,
			FRACUNIT/2,
			FRACUNIT/2,
			v.cachePatch("HL1SUITE"),
			V_PERPLAYER|V_ADD,
			v.getColormap(nil, player.skincolor),
			0,
			0,
			40*FRACUNIT,
			crop
		)
		v.drawCropped(
			52*FRACUNIT,
			178*FRACUNIT + crop/2,
			FRACUNIT/2,
			FRACUNIT/2,
			v.cachePatch("HL1SUITF"),
			V_PERPLAYER|V_ADD,
			v.getColormap(nil, player.skincolor),
			0,
			crop,
			40*FRACUNIT,
			40*FRACUNIT-crop
		)
		K_DrawHL1Number(v,player.mo.hl1armor/FRACUNIT,99*FRACUNIT,196*FRACUNIT,V_ADD|V_PERPLAYER,v.getColormap(nil, player.skincolor))
		if player.hl1dmgdir
			if player.hl1dmgdir == 360 or (player.hl1dmgdir >= -70 and player.hl1dmgdir <= 70)
				
			elseif player.hl1dmgdir == 360 or (player.hl1dmgdir >= 20 and player.hl1dmgdir <= 180)
				
			elseif player.hl1dmgdir == 360 or (player.hl1dmgdir < -90 or player.hl1dmgdir > 90)
				
			elseif player.hl1dmgdir == 360 or (player.hl1dmgdir <= -20 and player.hl1dmgdir >= -160)
				
			end
		end
		for pickupid, pickupshit in pairs(player.pickuphistory or {}) do
			if pickupshit.time
				pickupshit.time = pickupshit.time - 1
				if pickupshit.time <= 0
					player.pickuphistory[pickupid] = nil
				end
			end
			if pickupshit.count
				v.drawString(0, pickupid * 8, "\$pickupshit.type\ \$pickupshit.thing\ x\$pickupshit.count\")
			else
				v.drawString(0, pickupid * 8, "\$pickupshit.type\ \$pickupshit.thing\")
			end
		end
		if not player.kombihl1wpn return end
		local weaponamount = player.selectionlist["weaponcount"]
		local weaponlist = player.selectionlist["weapons"]
		local weaponslots = player.selectionlist["wepslotamounts"]
		local colormap = v.getColormap(nil, player.skincolor)
		for i = 1, 7 do
				local drawx = ((i > player.kombihl1category) and weaponlist and 65 or -10)*FRACUNIT+(i*12*FRACUNIT)
				v.drawScaled(drawx, 2*FRACUNIT, FRACUNIT/2, v.cachePatch("HUDSELBUCKET\$i\"), V_PERPLAYER|V_ADD, colormap)
				for d = 1,weaponslots[i] do
					if i == player.kombihl1category break end
					v.drawScaled(drawx, 2*FRACUNIT+(d*12*FRACUNIT), FRACUNIT/2, v.cachePatch("HUDSELBUCKETITEM"), V_PERPLAYER|V_ADD, colormap)
				end
			end
		for i = 1, weaponamount do
			local currentweapon = weaponlist[i]['name']
			local wepproperties = HL_WpnStats[currentweapon]
			local selectgraphic = wepproperties.selectgraphic or "HL1HUD9MM"
			local ammostats = HL_AmmoStats[wepproperties.ammo] or {max = 0}
			if i == player.kombihl1wpn
				selectgraphic = "\$selectgraphic\S"
			end
			if (player.hl1clips[currentweapon] != nil and player.hl1clips[currentweapon][1] <= 0) and player.hl1ammo[wepproperties.ammo] != nil and player.hl1ammo[wepproperties.ammo] <= 0 and not wepproperties["neverdenyuse"]
				colormap = v.getColormap(nil, SKINCOLOR_RED)
			else
				colormap = v.getColormap(nil, player.skincolor)
			end
			v.drawScaled(-10*FRACUNIT+(player.kombihl1category*12*FRACUNIT), (14*FRACUNIT)+((49*(i-1))*FRACUNIT/2), FRACUNIT/2, v.cachePatch(selectgraphic), V_PERPLAYER|V_ADD, colormap)
			if player.hl1ammo[wepproperties.ammo]
				local effectiveMaxAmmo = player.hl1doubleammo 
					and (ammostats.backpackmax or ammostats.max * 2) 
					or ammostats.max

				v.drawStretched(-9 * FRACUNIT + (player.kombihl1category * 12 * FRACUNIT), 
					(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2), 
					FRACUNIT * 10, 
					5 * FRACUNIT / 2, 
					v.cachePatch("HL1HUDSELGRAY"), 
					V_PERPLAYER | V_50TRANS)

				v.drawStretched(-9 * FRACUNIT + (player.kombihl1category * 12 * FRACUNIT), 
					(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2), 
					FixedDiv((player.hl1ammo[wepproperties.ammo] or 0) * 10, effectiveMaxAmmo or 10),
					5 * FRACUNIT / 2, 
					v.cachePatch("HL1HUDSELGREEN"), 
					V_PERPLAYER)
			end
		end
	end
end)