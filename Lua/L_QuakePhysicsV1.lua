local WATER_MAXSPEED  = 20 * FRACUNIT   -- max swim speed
local WATER_ACCEL     = 10 * FRACUNIT   -- roughly "trueaccel" from quake
local WATER_FRICTION = FRACUNIT / 2
local WATER_DRAWDOWN  = -FRACUNIT / 6      -- sink-speed when going too slow
local WATER_DT = FRACUNIT/TICRATE
local SWIM_UP_FORCE   =  12 * FRACUNIT
local SWIM_DOWN_FORCE =  12 * FRACUNIT

-- helper: 3-axis hypotenuse
local function FixedHypot3(x,y,z)
    return FixedHypot(FixedHypot(x,y), z)
end

-- the actual water-move function
local function WaterMove(player)
    local mo, c = player.mo, player.cmd
    if not mo or not c then return end

    local dt   = WATER_DT             -- = FRACUNIT/TICRATE
    local ang  = mo.angle
    local pitch = player.aiming
    local sinp, cosp = sin(pitch), cos(pitch)

    -- build raw wishvel (units per tic)
    local fwd = c.forwardmove * FRACUNIT
    local sde = -c.sidemove * FRACUNIT
    local ca, sa = cos(ang), sin(ang)
    local wishx = FixedMul(fwd, ca) - FixedMul(sde, sa)
    local wishy = FixedMul(fwd, sa) + FixedMul(sde, ca)
    local wishz
    if (c.buttons & BT_JUMP) ~= 0 then
        wishz = SWIM_UP_FORCE
    elseif (c.buttons & BT_SPIN) ~= 0 then
        wishz = -SWIM_DOWN_FORCE
    else
        -- forward‐leaning drift
        local fwdVel = FixedMul(wishx, ca) + FixedMul(wishy, sa)
        wishz = FixedMul(fwdVel, sinp)
    end
	wishz = $*2

    -- cap and scale wishspeed
    local wishspd = FixedHypot3(wishx, wishy, wishz)
    if wishspd > WATER_MAXSPEED then
        local s = FixedDiv(WATER_MAXSPEED, wishspd)
        wishx, wishy, wishz = FixedMul(wishx, s), FixedMul(wishy, s), FixedMul(wishz, s)
        wishspd = WATER_MAXSPEED
    end

    -- slow “desired” speed
	-- (Quake does 0.8)
    wishspd = FixedMul(wishspd, 7*FRACUNIT/10)

    -- get normalized wishdir
    local inv = wishspd > 0 and FixedDiv(FRACUNIT, wishspd) or 0
    local dirx, diry, dirz = FixedMul(wishx, inv), FixedMul(wishy, inv), FixedMul(wishz, inv)

    -- apply friction to current velocity
	local vx,vy,vz   = mo.momx, mo.momy, mo.momz
	local speed3d    = FixedHypot3(vx, vy, vz)
	if speed3d > 0 then
		-- reduce speed3d by friction * dt
		local newspd = speed3d - FixedMul(FixedMul(speed3d, WATER_DT), WATER_FRICTION)
		if newspd < 0 then newspd = 0 end
		local f = FixedDiv(newspd, speed3d)
		mo.momx = FixedMul(vx, f)
		mo.momy = FixedMul(vy, f)
		mo.momz = FixedMul(vz, f)
	end

    -- accelerate toward wishdir
    if wishspd >= (FRACUNIT/10) then
        local curspd = FixedHypot(mo.momx, mo.momy)
        local adds = wishspd - curspd
        if adds > 0 then
            local accels = FixedMul(
						WATER_ACCEL,
						FixedMul(wishspd, WATER_DT)
					)
            if accels > adds then accels = adds end
            mo.momx = mo.momx + FixedMul(accels, dirx)
            mo.momy = mo.momy + FixedMul(accels, diry)
            mo.momz = mo.momz + FixedMul(accels, dirz)
        end
    end

	-- enforce absolute swim speed cap on mom vector (maybe fixes errant behavior on vertical swimming?)
	local speed3d = FixedHypot3(mo.momx, mo.momy, mo.momz)
	if speed3d > WATER_MAXSPEED then
		local s = FixedDiv(WATER_MAXSPEED, speed3d)
		mo.momx = FixedMul(mo.momx, s)
		mo.momy = FixedMul(mo.momy, s)
		mo.momz = FixedMul(mo.momz, s)
	end
end

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin != "kombifreeman" then return end

	local previousWaterState = player.lastWaterState or 0
	local currentWaterState = (player.mo.eflags & MFE_UNDERWATER)

	-- Just entered water
	if currentWaterState and not previousWaterState then
		local scale = FixedDiv(457*FRACUNIT, 780*FRACUNIT)
		player.mo.momz = FixedMul(player.mo.momz, scale) -- SRB2 hardcodes a boost when we enter water, which we don't want
		player.justEnteredWater = true
	end

	player.lastWaterState = currentWaterState
end)

local TRUEACCEL = 12*FRACUNIT
local MAXACCEL = 5*FRACUNIT
local MINACCEL = 5*FRACUNIT/4

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin != "kombifreeman" return end
		if player.hl and player.hl.nophys then
			player.thrustfactor = skins[player.realmo.skin].thrustfactor
			return
		else
			--a cheap way of dissabling srb2 acceleration
			player.thrustfactor = 0
		end

	-- print("X Momentum: " .. player.mo.momx, "Y Momentum: " .. player.mo.momy, "Z Momentum: " .. player.mo.momz)

	if abs(player.cmd.forwardmove) + abs(player.cmd.sidemove) ~= 0
	and player.playerstate == PST_LIVE
	and player.exiting == 0
	and player.powers[pw_carry] == 0
	and player.powers[pw_nocontrol] == 0
	and player.climbing == 0
	and not (player.mo.state >= S_PLAY_SUPER_TRANS1 and player.mo.state <= S_PLAY_SUPER_TRANS6)
	and P_PlayerInPain(player) == false
	and not (player.pflags & PF_STASIS)
	and not (player.pflags & PF_STARTDASH)
		if player.mrce and MRCE_isHyper(player) then
			player.mrce.physics = true
		elseif player.powers[pw_sneakers] > 0 then
			if player.mrce then player.mrce.physics = true end
		else
			if player.mrce then player.mrce.physics = false end
		end

	if (player.mo.eflags & MFE_UNDERWATER) ~= 0 then
		print("Water tick!")
		if player.justEnteredWater then
			player.justEnteredWater = false
			print("...Though, physics were skipped.")
			return -- skip WaterMove
		end
        WaterMove(player)
        return -- Skip Quake Physics
    end

		local wishang
		wishang = R_PointToAngle2(0, 0, player.cmd.forwardmove * FRACUNIT, player.cmd.sidemove * -FRACUNIT) + player.mo.angle
		if (player.pflags & PF_ANALOGMODE) and not (player.mo.flags2 & MF2_TWOD) then
			wishang = player.cmd.angleturn<<16 + R_PointToAngle2(0, 0, player.cmd.forwardmove * FRACUNIT, player.cmd.sidemove * -FRACUNIT)
		end
		if (player.mo.flags2 & MF2_TWOD) then wishang = player.mo.angle end
		local analog = FixedHypot(player.cmd.forwardmove * 1311, -player.cmd.sidemove * 1311)

		--where am i going
		local movedir = R_PointToAngle2(0, 0, player.rmomx, player.rmomy)
		local movespd = FixedHypot(player.rmomx, player.rmomy)

		--wish varibles
		local wishspd
		wishspd = FixedMul(player.normalspeed, player.mo.scale)
		if player.mo.eflags & MFE_UNDERWATER then wishspd = $/2 end
		if player.powers[pw_sneakers] > 0 or player.powers[pw_super] > 0 then wishspd = 5*$/3 end
		if (player.pflags & PF_SPINNING) or P_IsObjectOnGround(player.mo) == false then
			if player.powers[pw_super] > 0
				wishspd = $/12
			else
				wishspd = $/16
			end
		end

		--funny dot product
		local angdiff
		local curspeed
		local addspeed
		local accelspeed
		angdiff = abs(movedir - wishang)
		curspeed = FixedMul(movespd, cos(angdiff))

		--accel hell
		local ACELTHRSH = 4*wishspd/5
		local minaccel
		local maxaccel
		local trueaccel
		minaccel = FixedMul(MINACCEL + ((player.accelstart - 96) * 224), player.mo.scale)
		maxaccel = FixedMul(MAXACCEL + ((player.acceleration - 40) * 256), player.mo.scale)
		trueaccel = FixedMul(TRUEACCEL + ((player.acceleration - 40) * 192), player.mo.scale)
		if player.powers[pw_super] > 0 then
			minaccel = $ + 3*player.mo.scale/4
			maxaccel = 2*$
			trueaccel = FixedMul($, 4*FRACUNIT/3)
			if player.mrce and MRCE_isHyper(player) then
				if not P_IsObjectOnGround(player.mo) then
					trueaccel = max(wishspd, FixedMul($, 8*FRACUNIT/7))
				end
				maxaccel = 5*$/4
				minaccel = $ + player.mo.scale/2
			end
		end
		if player.powers[pw_sneakers] > 0 and player.powers[pw_super] == 0 then
			minaccel = $ + player.mo.scale/3
			maxaccel = FixedMul($, 5*FRACUNIT/3) + player.mo.scale/2
		end
		if player.mo.eflags & MFE_UNDERWATER then
			trueaccel = $/2
			maxaccel = $/2
			minaccel = $/2
		end
		if movespd == 0 then
			if player.dashmode >= TICRATE*3 then accelspeed = maxaccel else accelspeed = minaccel end
		elseif movespd < ACELTHRSH then
			if player.dashmode >= TICRATE*3
				accelspeed = maxaccel
			else
				accelspeed = ease.insine(min(FixedDiv(movespd, ACELTHRSH), FRACUNIT), minaccel, maxaccel)
			end
		elseif movespd >= ACELTHRSH and movespd < wishspd - 4*player.mo.scale then
			local TRUEDIV = FixedInt((wishspd - 4*player.mo.scale) - ACELTHRSH) or 1
			accelspeed = ease.outquad(min(FixedDiv((movespd - ACELTHRSH), TRUEDIV), FRACUNIT), maxaccel, trueaccel)
		else accelspeed = TRUEACCEL end
		addspeed = min(max(wishspd - curspeed, 0), accelspeed)

		--lmfao
		P_Thrust(player.mo, wishang, FixedMul(addspeed, analog))

		player.rmomx = player.mo.momx - player.cmomx
		player.rmomy = player.mo.momy - player.cmomy
		player.speed = P_AproxDistance(player.rmomx, player.rmomy)

		--if shit fucked up? have this!
		if abs(addspeed) > 300*FRACUNIT
			print("bullshit error! thanks" + player.name + "!")
			print(trueaccel/FRACUNIT)
			print(maxaccel/FRACUNIT)
			print(minaccel/FRACUNIT)
			print(curspeed/FRACUNIT)
			print(accelspeed/FRACUNIT)
			print(addspeed/FRACUNIT)
		end
	else
		-- print("No physics at all during this tic (May not have pressed movement keys?)")
	end

	-- "Slow down, I'm pulling it! (a box maybe) but only when I'm standing on ground" - HL1 Source Code
	if player.hlcmds and player.hlcmds.use == true and P_IsObjectOnGround(player.mo) then
		player.mo.momx = FixedMul($, FRACUNIT*3/10)
		player.mo.momy = FixedMul($, FRACUNIT*3/10)
	end
end)