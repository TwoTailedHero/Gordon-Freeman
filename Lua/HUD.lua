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

local function IsAboveVersion(major, sub)
    return (VERSION > major) or (VERSION == major and SUBVERSION >= sub)
end

local function dummy()
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

hud.add(function(v, player)
    if not player.mo or player.mo.skin ~= "kombifreeman" then return end

    hud.disable("score")
    hud.disable("time")
    hud.disable("rings")
    hud.disable("lives")
    hud.disable("weaponrings")
    hud.disable("crosshair")

    -- Skip rendering if player is dead or in third person
    if player.playerstate == PST_DEAD or camera.chase or not player.hl1inventory[player.hl1weapon] then return end

    local weaponStats = HL_WpnStats[player.hl1weapon]
    local curvmdl = kombihl1viewmodels[weaponStats.viewmodel or "PISTOL"]
    local curframe = player.hl1frame or 1
    local vmdlflags = V_PERPLAYER

    if curvmdl.flags and (curvmdl.flags & VMDL_FLIP) ~= 0 then
        vmdlflags = vmdlflags | V_FLIP
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

    -- Single draw call
    v.drawScaled(
        (160 * FRACUNIT) + bobx,
        (106 * FRACUNIT) + boby,
        FRACUNIT + bobOffset,
        patch,
        vmdlflags | V_SNAPTOBOTTOM,
        colormap
    )
end, "game")

-- Ammo
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local weaponStats = HL_WpnStats[player.hl1weapon]
	if not (weaponStats.primary and weaponStats.primary.noreserveammo) then
		K_DrawHL1Number(v, player.hl1ammo[weaponStats.primary and weaponStats.primary.ammo or "9mm"], 315 * FRACUNIT, 196 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
	end
	if player.hl1clips[player.hl1weapon] and (player.hl1clips[player.hl1weapon].primary or 0) >= 0 then
		v.drawScaled(283 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
		K_DrawHL1Number(v, player.hl1clips[player.hl1weapon].primary, 280 * FRACUNIT, 196 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
	end
	if weaponStats.altusesprimaryclip or weaponStats.secondary == nil return end
	if not weaponStats.secondary.noreserveammo then
		K_DrawHL1Number(v, player.hl1ammo[weaponStats.secondary.ammo], 315 * FRACUNIT, 176 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
	end
	if player.hl1clips[player.hl1weapon] and (player.hl1clips[player.hl1weapon].secondary or 0) >= 0 then
		v.drawScaled(283 * FRACUNIT, 164 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
		K_DrawHL1Number(v, player.hl1clips[player.hl1weapon].secondary, 280 * FRACUNIT, 176 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
	end
end, "game")

-- Crosshair
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local weaponStats = HL_WpnStats[player.hl1weapon]
	if weaponStats.crosshair then
		v.drawScaled(160 * FRACUNIT, 100 * FRACUNIT, FRACUNIT / 2, v.cachePatch(weaponStats.crosshair), V_PERPLAYER|V_ADD, v.getColormap(nil, player.skincolor))
	end
end, "game")

-- Health
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local healthColor = (player.mo.hl1health > 25) and player.skincolor or SKINCOLOR_RED
	v.drawScaled(5 * FRACUNIT, 182 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDCROSS"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, healthColor))
	K_DrawHL1Number(v, player.mo.hl1health, 50 * FRACUNIT, 196 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, player.skincolor), 25)
	v.drawScaled(50 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDDIVIDE"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, player.skincolor))
end, "game")

-- Flashlight
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	if player.hl1flashlightuse then
		v.drawScaled(306 * FRACUNIT, 7 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HL1HUDFLASHB"), V_PERPLAYER|V_ADD|V_SNAPTOTOP|V_SNAPTORIGHT, v.getColormap(nil, player.skincolor))
	end
end, "game")

-- Armor
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
	local armor = min((player.mo.hl1armor or 0), 100 * FRACUNIT)
	local crop = FixedDiv((100 * FRACUNIT - armor) * 40, 100 * FRACUNIT)
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITE"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, player.skincolor), 0, 0, 40 * FRACUNIT, crop)
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT + crop / 2, FRACUNIT / 2, FRACUNIT / 2, v.cachePatch("HL1SUITF"), V_PERPLAYER|V_ADD|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, player.skincolor), 0, crop, 40 * FRACUNIT, 40 * FRACUNIT - crop)
	K_DrawHL1Number(v, (player.mo.hl1armor or 0) / FRACUNIT, 99 * FRACUNIT, 196 * FRACUNIT, V_ADD|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(nil, player.skincolor))
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
    local flags = V_PERPLAYER | V_ADD | fade
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

-- Pickup History Display
hud.add(function(v, player)
	if not player.mo return end
	if player.mo.skin != "kombifreeman" return end
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
end, "game")

-- Weapon Selection Menu
hud.add(function(v, player)
    if not player.mo then return end
    if player.mo.skin ~= "kombifreeman" then return end
    if not player.kombiaccessinghl1menu then return end

    local weaponamount   = player.selectionlist.weaponcount
    local weaponlist     = player.selectionlist.weapons
    local weaponslots    = player.selectionlist.wepslotamounts
    local colormap       = v.getColormap(nil, player.skincolor)

    -- Determine extra separation value based on whether the selected bucket has weapons.
    local extraSepValue = (weaponslots[player.kombihl1category] and weaponslots[player.kombihl1category] > 0) and 65 or -10

    -- Weapon Category Buckets
    for i = 0, 9 do
        -- For buckets after the selected bucket, add extra separation; otherwise use the standard offset (-10)
        local sep = (i > player.kombihl1category) and extraSepValue or -10
        local drawx = (sep * FRACUNIT) + ((i + 1) * 12 * FRACUNIT)
        v.drawScaled(drawx, 2 * FRACUNIT, FRACUNIT / 2, v.cachePatch("HUDSELBUCKET" .. i),
            V_PERPLAYER|V_ADD|V_SNAPTOTOP|V_SNAPTOLEFT, colormap)

        for d = 1, weaponslots[i] do
            if i == player.kombihl1category then break end
            v.drawScaled(drawx, 2 * FRACUNIT + (d * 12 * FRACUNIT), FRACUNIT / 2, v.cachePatch("HUDSELBUCKETITEM"),
                V_PERPLAYER|V_ADD|V_SNAPTOTOP|V_SNAPTOLEFT, colormap)
        end
    end

    -- Individual Weapon Selection
    for i = 1, weaponamount do
        local currentweapon = weaponlist[i].name
        local wepproperties = HL_WpnStats[currentweapon]
        local selectgraphic = wepproperties.selectgraphic or "HL1HUD9MM"
        local ammostats = HL_AmmoStats[ (wepproperties.primary and wepproperties.primary.ammo) or "9mm" ] or { max = 0 }
        local border

        -- Highlight Selected Weapon
        if i == player.kombihl1wpn then
            selectgraphic = selectgraphic .. "S"
            border = i
        end

        -- Determine Ammo Availability
        if (player.hl1clips[currentweapon] and (player.hl1clips[player.hl1weapon].primary or 0) <= 0)
           and player.hl1ammo[ (player.hl1clips[player.hl1weapon] and player.hl1clips[player.hl1weapon].primary and (wepproperties.primary and wepproperties.primary.ammo) or "9mm") ]
           and player.hl1ammo[ (wepproperties.primary and wepproperties.primary.ammo or "9mm") ] <= 0
           and not ((wepproperties.primary and wepproperties.primary.neverdenyuse)
                    or (wepproperties.secondary and wepproperties.secondary.neverdenyuse)) then
            colormap = v.getColormap(nil, SKINCOLOR_RED)
        else
            colormap = v.getColormap(nil, player.skincolor)
        end

        -- Draw Weapon Icon
        v.drawScaled(-10 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
            (14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
            FRACUNIT / 2, v.cachePatch(selectgraphic),
            V_PERPLAYER|V_ADD|V_SNAPTOTOP|V_SNAPTOLEFT, colormap)

        if i == border then
            v.drawScaled(-10 * FRACUNIT + ((player.kombihl1category + 1) * 12 * FRACUNIT),
                (14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
                FRACUNIT / 2, v.cachePatch("HUDSELITEMBORDER"),
                V_PERPLAYER|V_ADD|V_SNAPTOTOP|V_SNAPTOLEFT, colormap)
        end

        -- Draw Ammo Bar
        if player.hl1ammo[ (wepproperties.primary and wepproperties.primary.ammo or "9mm") ] then
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
    end
end, "game")