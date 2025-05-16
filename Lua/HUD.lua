local drawflags = V_ADD | V_PERPLAYER

local function K_DrawHL1Number(v,num,x,y,flags,colormap,redtintingmin,scale)
	local donum = tostring(abs(num or 0))
	local xpos = (x or 0) - FixedMul(scale or FRACUNIT/2, 20*FRACUNIT)
	local ypos = (y or 0) - FixedMul(scale or FRACUNIT/2, 24*FRACUNIT)
	local textflags = flags or 0
	local cmap
	if redtintingmin == nil or num > redtintingmin
		cmap = colormap or v.getColormap(nil, SKINCOLOR_ORANGE)
	else
		cmap = v.getColormap(nil, SKINCOLOR_RED)
	end
	for i = 0,#donum-1 do
		local dothis = (donum or 0)/(10^i)%10 or 0
		v.drawCropped(xpos, ypos, scale or FRACUNIT/2, scale or FRACUNIT/2, v.cachePatch("HL1NUMS"), textflags, cmap, (24*FRACUNIT)*dothis, 0, 20*FRACUNIT, 24*FRACUNIT)
		xpos = $-(FixedMul(scale or FRACUNIT/2, 20*FRACUNIT))
	end
end

local function IsAboveVersion(major, sub)
	return (VERSION > major) or (VERSION == major and SUBVERSION >= sub)
end

local function dummy()
end

local function drawCount(v, x, y, count, ammostats, flags, colormap)
	if not count or count < 0 then return end
	K_DrawHL1Number(v, count, x, y, flags, colormap)
	if ammostats and ammostats.icon then
		v.drawScaled(
			x, y - 12 * FRACUNIT,
			FRACUNIT / 2,
			v.cachePatch(ammostats.icon),
			flags,
			colormap
		)
	end
end

local function shouldDraw(mode, player)
	local weapon   = player.hl1weapon
	local wpnStats = HL_WpnStats[weapon] or {}
	local modeStats = wpnStats[mode]
	if not modeStats then return false end

	-- figure out which clip stats to use (secondary may use primary clip)
	local clipMode = (mode == "secondary" and modeStats.altusesprimaryclip) and "primary" or mode
	local curStats = wpnStats[clipMode]
	if not curStats then return false end

	local clipSize	= curStats.clipsize or -1
	local ammoType	= curStats.ammo
	local reserveCnt  = (ammoType and player.hl1ammo[ammoType]) or 0
	local clipCnt	 = (player.hl1clips[weapon] and player.hl1clips[weapon][clipMode]) or 0
	local neverDeny   = curStats.neverdenyuse

	-- infinite ammo / no-clip weapons: clipsize < 0 AND no ammo type
	if clipSize < 0 and (not ammoType or reserveCnt < 0) then
		return { drawReserve = false, drawClip = false }
	end

	-- clip-based weapons
	if clipSize > -1 then
		return {
			drawReserve = (reserveCnt >= 0 or neverDeny),
			drawClip	= (clipCnt >= 0 or neverDeny),
			reserveCnt  = reserveCnt,
			clipCnt	 = clipCnt,
			ammostats   = HL_AmmoStats[ammoType] or {}
		}
	end

	-- pure reserve only (no clip)
	if ammoType then
		return {
			drawReserve = (reserveCnt >= 0 or neverDeny),
			drawClip	= false,
			reserveCnt  = reserveCnt,
			ammostats   = HL_AmmoStats[ammoType] or {}
		}
	end

	return { drawReserve = false, drawClip = false }
end

local function warn(str)
	print("\130WARNING: \128"..str);
end

local function notice(str)
	print("\x82NOTICE: \x80"..str);
end

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

-- Viewmodel
hud.add(function(v, player)
	if not player.mo or player.mo.skin ~= "kombifreeman" then return end

	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	hud.disable("lives")
	hud.disable("weaponrings")
	hud.disable("crosshair")

	-- Skip rendering if player is dead, in third person, or something has taken control of the camera
	if player.playerstate == PST_DEAD or camera.chase or not player.hl1inventory[player.hl1weapon] or player.awayviewtics then return end

	local weaponStats = HL_WpnStats[player.hl1weapon]
	local curvmdl = kombihl1viewmodels[weaponStats.viewmodel or "PISTOL"]
	local curframe = player.hl1frame or 1
	local vmdlflags = V_PERPLAYER

	if curvmdl.flags and (curvmdl.flags & VMDL_FLIP) ~= 0 then
		vmdlflags = $ | V_FLIP
	end

	-- Fetch animation
	local animationDef = player.hl1currentAnimation
	local sentinel = animationDef and animationDef.sentinel or "PISTOLIDLE1-1"
	local prefix, baseNum = sentinel:match("^(.-)(%d+)$")
	local patchName = prefix .. (tonumber(baseNum) + (curframe - tonumber(baseNum)))

	-- Viewbobbing
	local bobx, boby = 0, 0
	local angle = FixedAngle(leveltime * 12 * FRACUNIT)
	local bobOffset = 0

	if curvmdl.bobtype == VBOB_DOOM then
		local bobAngle = ((128 * leveltime) & 8191) << 19
		bobx = FixedMul((player.hl1wepbob or 0), cos(bobAngle))
		bobAngle = ((128 * leveltime) & 4095) << 19
		boby = FixedMul((player.hl1wepbob or 0), sin(bobAngle))
	else
		bobOffset = FixedMul(FRACUNIT, FixedMul((player.hl1wepbob or 0) / 256, sin(angle)))
	end

	-- Cache patch and colormap lookup
	local patch = v.cachePatch(patchName)
	local colormap = IsAboveVersion(202, 13) and v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel) or nil

	v.drawScaled(
		(160 * FRACUNIT) + bobx,
		(106 * FRACUNIT) + boby,
		FRACUNIT + bobOffset,
		patch,
		vmdlflags | V_SNAPTOBOTTOM,
		colormap
	)
	if not v.patchExists(patchName) then
		warn("Patch " .. tostring(patchName) .. " either doesn't exist, or we fucked up BADLY! Make sure it's the former!")
	end
end, "game")

-- Pickup History Display
hud.add(function(v, player)
    -- only for our kombifreeman skin
    if not player.mo or player.mo.skin ~= "kombifreeman" then
        return
    end

    -- constants
    local FRAC = FRACUNIT
    local ICON_SCALE   = FRAC / 2
    local SPACING_Y    = 45 * ICON_SCALE      -- same spacing whether weapon or ammo
    local MARGIN_X     = 8 * FRAC             -- distance from right screen edge
    local MARGIN_Y     = SPACING_Y + FRAC * 3 -- extra distance from bottom screen edge (unhoomed from SPACING_Y)
    local BASE_FLAGS   = drawflags | V_SNAPTORIGHT | V_SNAPTOBOTTOM | V_40TRANS
    local colormap     = v.getColormap(nil, player.mo.color)

    -- fetch viewport dimensions (in fixed‑point)
    local viewW, viewH = 320 * FRACUNIT, 200 * FRACUNIT

    -- starting Y: a bit up from the bottom of the screen
    local yOffset = viewH - SPACING_Y - MARGIN_X - MARGIN_Y

    -- iterate in numerical order (so first pickup is closest to bottom)
    local pickups = {}
    for id, info in pairs(player.pickuphistory or {}) do
        table.insert(pickups, {id = id, data = info})
    end
    table.sort(pickups, function(a, b) return a.id < b.id end)

    for _, entry in ipairs(pickups) do
        local info = entry.data

        -- countdown timer
        if info.time then
            info.time = info.time - 1
            if info.time <= 0 then
                player.pickuphistory[entry.id] = nil
                -- skip drawing
                continue
            end
        end

        if info.type == "weapon" then
            local iconName = HL_WpnStats[info.thing].selectgraphic or "HL1HUD9MM"
            local iconW, iconH = 170 * FRAC, 45 * FRAC
            local xPos = viewW - MARGIN_X - (FixedMul(iconW, ICON_SCALE))
            -- center vertically on this slot
            local yPos = yOffset - (iconH * ICON_SCALE / (2 * FRAC))
            v.drawScaled(xPos, yPos, ICON_SCALE, v.cachePatch(iconName), BASE_FLAGS, colormap)

        elseif info.type == "ammo" then
            local iconName = HL_AmmoStats[info.thing].icon
            local iconSize = 24 * FRAC
            local xPos = viewW - MARGIN_X - (FixedMul(iconSize, ICON_SCALE))
            local yPos = yOffset + 7 * FRAC
            v.drawScaled(xPos, yPos, ICON_SCALE, v.cachePatch(iconName), BASE_FLAGS, colormap)

            -- count: right‑aligned just to the left of the ammo icon
            local countStr = tostring(info.count or 0)
			local scale = FRACUNIT / 4
            local digitWidth = FixedMul(scale or FRACUNIT/2, 20*FRACUNIT)
            local textX = xPos - (#countStr - 1) * digitWidth - (2 * FRAC)
            local textY = yPos + (7 * FRAC)
            K_DrawHL1Number(v, info.count, textX, textY, BASE_FLAGS, colormap, nil, scale)

            -- warn if icon missing
            if not v.patchExists(iconName) then
                warn("Missing patch: " .. iconName .. " for ammo '" .. info.thing .. "'")
            end
        end

        -- move up for next icon
        yOffset = yOffset - SPACING_Y
    end
end, "game")

-- Ammo
hud.add(function(v, player)
	if not player.mo then return end
	if player.mo.skin ~= "kombifreeman" then return end

	local xPosition = 308 * FRACUNIT
	local weapon	= player.hl1weapon
	local wpnStats  = HL_WpnStats[weapon] or {}
	local colormap  = v.getColormap(nil, player.mo.color)
	local drawFlags = drawflags | V_SNAPTOBOTTOM | V_SNAPTORIGHT | V_40TRANS

	-- Primary
	local primary = shouldDraw("primary", player)
	if primary.drawReserve then
		drawCount(v, xPosition, 196 * FRACUNIT, primary.reserveCnt, primary.ammostats, drawFlags, colormap)
	end
	if primary.drawClip then
		v.drawScaled(
			xPosition - 32 * FRACUNIT,
			184 * FRACUNIT,
			FRACUNIT / 2,
			v.cachePatch("HL1HUDDIVIDE"),
			drawFlags,
			colormap
		)
		K_DrawHL1Number(
			v,
			primary.clipCnt,
			xPosition - 35 * FRACUNIT,
			196 * FRACUNIT,
			drawFlags,
			colormap
		)
	end

	-- Secondary (only if defined and not using primary clip exclusively)
	if wpnStats.secondary and not wpnStats.secondary.altusesprimaryclip then
		local secondary = shouldDraw("secondary", player)
		if secondary.drawReserve then
			drawCount(v, xPosition, 176 * FRACUNIT, secondary.reserveCnt, secondary.ammostats, drawFlags, colormap)
		end
		if secondary.drawClip then
			v.drawScaled(
				xPosition - 32 * FRACUNIT,
				164 * FRACUNIT,
				FRACUNIT / 2,
				v.cachePatch("HL1HUDDIVIDE"),
				drawFlags,
				colormap
			)
			K_DrawHL1Number(
				v,
				secondary.clipCnt,
				xPosition - 35 * FRACUNIT,
				176 * FRACUNIT,
				drawFlags,
				colormap
			)
		end
	end
end, "game")

-- Crosshair
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local weaponStats = HL_WpnStats[player.hl1weapon]
	if weaponStats.crosshair then
		v.drawScaled(160 * FRACUNIT, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch(weaponStats.crosshair), drawflags, v.getColormap(nil, player.mo.color))
	end
end, "game")

-- Health
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local healthColor = (player.mo.hl1health > 25) and player.mo.color or SKINCOLOR_RED
	v.drawScaled(5 * FRACUNIT, 182 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDCROSS"), drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, healthColor))
	K_DrawHL1Number(v, player.mo.hl1health, 50 * FRACUNIT, 196 * FRACUNIT, drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, player.mo.color), 25)
	v.drawScaled(50 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, player.mo.color))
end, "game")

-- Flashlight
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin ~= "kombifreeman" return end

	local maxVal  = 100*FRACUNIT
	local armor   = min((player.hl.flashlightbattery or 0), maxVal)
	local crop	= FixedDiv((maxVal - armor) * 32, maxVal)

	local x0	  = 290 * FRACUNIT
	local y0	  =   7 * FRACUNIT
	local hscale  = FRACUNIT/2
	local vscale  = FRACUNIT/2
	local flags   = drawflags | V_SNAPTOTOP | V_SNAPTORIGHT
	if not player.hl.flashlight then
		flags = $|V_70TRANS
	else
		flags = $|V_50TRANS
	end
	local cm	  = armor > 25*FRACUNIT and v.getColormap(nil, player.mo.color) or v.getColormap(nil, SKINCOLOR_RED)

	v.drawScaled(
	  x0, y0,
	  hscale,
	  v.cachePatch("HL1HUDFLASHE"),
	  flags, cm
	)

	v.drawCropped(
	  x0 + (crop / 2), y0,
	  hscale, vscale,
	  v.cachePatch("HL1HUDFLASHF"),
	  flags, cm,
	  crop, 0,
	  (32 * FRACUNIT) - crop,
	  32 * FRACUNIT
	)

	if player.hl.flashlight then
	for i = 1, 2 do
		  v.drawScaled(
			306 * FRACUNIT, 7 * FRACUNIT, FRACUNIT/2,
			v.cachePatch("HL1HUDFLASHB"),
		   flags,
			cm
		  )
	end
	end
end, "game")

-- Armor
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local armor = min((player.mo.hl1armor or 0), 100 * FRACUNIT)
	local crop = FixedDiv((100 * FRACUNIT - armor) * 40, 100 * FRACUNIT)
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITE"), drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, player.mo.color), 0, 0, 40 * FRACUNIT, crop)
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT + crop / 2, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITF"), drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, player.mo.color), 0, crop, 40 * FRACUNIT, 40 * FRACUNIT - crop)
	K_DrawHL1Number(v, (player.mo.hl1armor or 0) / FRACUNIT, 99 * FRACUNIT, 196 * FRACUNIT, drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_40TRANS, v.getColormap(nil, player.mo.color))
end, "game")

local damageFadeTics = 5

-- Damage Direction Indicator
hud.add(function(v, player)
	if not player.mo then return end
	if player.mo.skin ~= "kombifreeman" then return end
	if player.mo.hl1dmgdir == nil return end
	local fade = ease.linear(FixedDiv(player.hl1damagetics, damageFadeTics), 0, 10)
	if fade >= 10 return end
	fade = fade<<V_ALPHASHIFT

	local centerdist = 50 * FRACUNIT
	local flags = drawflags | fade
	local hitAngle = player.mo.hl1dmgdir

	-- Un-angled hit, all indicators light up
	if hitAngle == -FRACUNIT then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) - centerdist, FRACUNIT / 2, v.cachePatch("HLPAINUP"), flags)
		v.drawScaled((160 * FRACUNIT) - centerdist, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HLPAINRIGHT"), flags | V_FLIP)
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) + centerdist, FRACUNIT / 2, v.cachePatch("HLPAINDOWN"), flags)
		v.drawScaled((160 * FRACUNIT) + centerdist, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HLPAINRIGHT"), flags)
		return
	end

	-- The tolerance for each indicator
	local tolerance = 45 * FRACUNIT

	-- Normalize the angle to a 0 - 360° range
	local function normalizeAngle(angle)
		local full = 360 * FRACUNIT
		return angle % full
	end

	hitAngle = normalizeAngle(hitAngle)

	-- Helper: Check if the absolute difference between two angles is within tolerance
	local function isWithin(angle, target, tol)
		local diff = abs(angle - target)
		if diff > 180 * FRACUNIT then
			diff = (360 * FRACUNIT) - diff
		end
		return diff <= tol
	end

	-- SRB2 has no native knowledge on carvinal directions, let's fix that by defining our own
	local centers = {
		up = 0,
		right = 90 * FRACUNIT,
		down = 180 * FRACUNIT,
		left = 270 * FRACUNIT,
	}

	-- Only draw an indicator if the hit angle is within tolerance
	if isWithin(hitAngle, centers.up, tolerance) then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) - centerdist, FRACUNIT / 2, v.cachePatch("HLPAINUP"), flags)
	end
	if isWithin(hitAngle, centers.right, tolerance) then
		v.drawScaled((160 * FRACUNIT) - centerdist, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HLPAINRIGHT"), flags | V_FLIP)
	end
	if isWithin(hitAngle, centers.down, tolerance) then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) + centerdist, FRACUNIT / 2, v.cachePatch("HLPAINDOWN"), flags)
	end
	if isWithin(hitAngle, centers.left, tolerance) then
		v.drawScaled((160 * FRACUNIT) + centerdist, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HLPAINRIGHT"), flags)
	end
end, "game")

-- Weapon Selection Menu
hud.add(function(v, player)
	if not player.mo then return end
	if player.mo.skin ~= "kombifreeman" then return end
	if not player.kombiaccessinghl1menu then return end

	local weaponamount   = player.selectionlist.weaponcount
	local weaponlist	 = player.selectionlist.weapons
	local weaponslots	= player.selectionlist.wepslotamounts
	local colormap	   = v.getColormap(nil, player.mo.color)

	-- Determine extra separation value based on whether the selected bucket has weapons.
	local extraSepValue = (player.kombihl1wpn > 0 and weaponslots and weaponslots[player.kombihl1category] and weaponslots[player.kombihl1category] > 0) and 65 or -10

	-- Draw small weapon icons in each category
	for i = 0, 9 do
		local sep = (i > player.kombihl1category) and extraSepValue or -10
		local drawx = (sep * FRACUNIT) + ((i + 1) * 12 * FRACUNIT)

		v.drawScaled(drawx, 2 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HUDSELBUCKET" .. i),
			drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS, colormap)

		local count = weaponslots and weaponslots[i] or 0
		local usable = (weaponslots.usable and weaponslots.usable[i]) or {}

		for d = 1, count do
			if player.kombihl1wpn ~= 0 and i == player.kombihl1category then break end

			local isUsable = usable[d]
			local usecolor = (not isUsable) and SKINCOLOR_RED or player.mo.color
			local previewColor = v.getColormap(nil, usecolor)

			v.drawScaled(drawx, 2 * FRACUNIT + (d * 12 * FRACUNIT), FRACUNIT / 2,
				v.cachePatch("HUDSELBUCKETITEM"),
				drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS, previewColor)
		end
	end

	if player.kombihl1wpn == 0 then return end

	-- Individual Weapon Selection
	for i = 1, weaponamount do
		local currentweapon = weaponlist[i].name
		local usable = weaponlist[i].usable
		local wepproperties = HL_WpnStats[currentweapon]
		local selectgraphic = wepproperties.selectgraphic or "HL1HUD9MM"
		local ammostats = HL_AmmoStats[ (wepproperties.primary and wepproperties.primary.ammo) or "9mm" ] or { max = 0 }
		local altammostats = HL_AmmoStats[ (wepproperties.secondary and wepproperties.secondary.ammo) or "none" ] or { max = 0 }
		local border

		-- Highlight Selected Weapon
		if i == player.kombihl1wpn then
			selectgraphic = selectgraphic .. "S"
			border = i
		end

		-- If unusable, then mark as red.
		if not usable then
			colormap = v.getColormap(nil, SKINCOLOR_RED)
		else
			colormap = v.getColormap(nil, player.mo.color)
		end

		-- Draw Weapon Icon
		v.drawScaled(-10 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
			(14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
			FRACUNIT / 2, v.cachePatch(selectgraphic),
			drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS, colormap)

		if i == border then
			v.drawScaled(-10 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
				(14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FRACUNIT / 2, v.cachePatch("HL1HUDWPNSEL"),
				drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_40TRANS, colormap)
		end

		local ammoKey = (wepproperties.primary and wepproperties.primary.ammo) or "9mm"
		local have = player.hl1ammo[ammoKey] or 0

		-- Draw Ammo Bars
		if have > 0 then
			local effectiveMaxAmmo = player.hl1doubleammo and (ammostats.backpackmax or ammostats.max * 2) or ammostats.max
			v.drawStretched(-9 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FRACUNIT * 10, 5 * FRACUNIT / 2, v.cachePatch("HL1HUDSELGRAY"),
				V_PERPLAYER|V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawStretched(-9 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FixedDiv((player.hl1ammo[ (wepproperties.primary and wepproperties.primary.ammo or "9mm") ] or 0) * 10, effectiveMaxAmmo or 10),
				5 * FRACUNIT / 2,
				v.cachePatch("HL1HUDSELGREEN"),
				V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT)
		end

		local ammoKey = (wepproperties.secondary and wepproperties.secondary.ammo) or "mpme"
		local have = player.hl1ammo[ammoKey] or 0

		if not have then continue end
		if have > 0 then
			local effectiveMaxAmmo = player.hl1doubleammo and (altammostats.backpackmax or altammostats.max * 2) or altammostats.max
			v.drawStretched((5 * FRACUNIT / 2) + ((player.kombihl1category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FRACUNIT * 10, 5 * FRACUNIT / 2, v.cachePatch("HL1HUDSELGRAY"),
				V_PERPLAYER|V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawStretched((5 * FRACUNIT / 2) + ((player.kombihl1category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FixedDiv((player.hl1ammo[ (wepproperties.secondary and wepproperties.secondary.ammo or "9mm") ] or 0) * 10, effectiveMaxAmmo or 10),
				5 * FRACUNIT / 2,
				v.cachePatch("HL1HUDSELGREEN"),
				V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT)
		end
	end
end, "game")