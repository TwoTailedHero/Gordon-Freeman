local TRUEACCEL = 12*FRACUNIT
local MAXACCEL = 5*FRACUNIT
local MINACCEL = 5*FRACUNIT/4

addHook("PlayerThink", function(player)
		if not player.mo then return end
		if player.mo.skin != "kombifreeman" return end
			--a cheap way of dissabling srb2 acceleration
			player.thrustfactor = 0

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
				local TRUEDIV = FixedInt((wishspd - 4*player.mo.scale) - ACELTHRSH)
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
		end
end)