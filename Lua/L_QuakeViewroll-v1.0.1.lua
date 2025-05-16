-- QuakeViewroll: adds Quake-style viewroll to Sonic Robo Blast 2
-- Copyright (C) 2024 Biff
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

local function dotProduct(x1,y1,x2,y2)
	return FixedMul(x1,x2) + FixedMul(y1,y2)
end

local function angToVec2(ang)
	return cos(ang), sin(ang)
end

local function viewRoll()
	if displayplayer == nil then return end
	if displayplayer.mo == nil then return end
	if displayplayer.mo.skin != "kombifreeman" then return end -- Make sure we're playing as Freeman
	if (maptol & TOL_NIGHTS) then return end -- let them handle it
	if camera.chase == true then return end -- ONLY run this for non-chase camera!!

	local player = displayplayer
	local mo = displayplayer.mo
	local ang = 0
	local angx, angy = 0, 0
	local momx, momy = mo.momx, mo.momy

	player.hl1wepbob = FixedMul(player.mo.momx, player.mo.momx) + FixedMul(player.mo.momy, player.mo.momy)
	player.hl1wepbob = player.hl1wepbob >> 2
	if player.hl1wepbob > FRACUNIT*16 then
		player.hl1wepbob = FRACUNIT*16
	end

	player.bob = 0
	ang = displayplayer.mo.angle + ANGLE_90
	angx, angy = angToVec2(ang)

	-- V_CalcRoll, Quake/WinQuake/view.c:81
	local side = 0
	local sign = 0
	local value = 0
	local cl_rollspeed = CV_FindVar("cl_rollspeed")
	local cl_rollangle = CV_FindVar("cl_rollangle")
	side = dotProduct(momx, momy, angx, angy)
	sign = side < 0 and -1 or 1
	side = abs($)
	value = cl_rollangle.value

	if side < cl_rollspeed.value then
		-- CV_FLOAT convars return a multiple of FRACUNIT
		side = FixedDiv(FixedMul(side, value), cl_rollspeed.value)
	else
		side = value
	end

	if (mo.eflags & MFE_VERTICALFLIP) then
		side = -$
	end

	displayplayer.viewrollangle = FixedMul(InvAngle(FixedAngle(side * sign)), 4 * FRACUNIT)

	-- Add extra viewroll (e.g. viewpunch from falling) if available
	if player.hl and player.hl.viewrollpunch then
		displayplayer.viewrollangle = $ + player.hl.viewrollpunch
	end
end

local convars = {}
local initialized = false

local function writeConfig()
	if not initialized then return end
	local file = io.openlocal("client/hl/qvr_autorun.cfg", "w")
	if file == nil then return end
	for _,v in ipairs(convars) do
		file:write(string.format("%s\t%s\n", v.name, v.string))
	end
	file:close()
end

local function readConfig()
	local file = io.openlocal("client/hl/qvr_autorun.cfg", "r")
	if file == nil then return end
	for c in file:lines() do
		local f = {}
		for k in c:gmatch("[^;,%s]+") do
			table.insert(f, k)
		end
		if #f >= 2 then
			local convar = CV_FindVar(f[1])
			if convar ~= nil then CV_StealthSet(convar, f[2]) end -- don't write back to the cfg
		end
	end
	file:close()
end

convars[#convars+1] = CV_RegisterVar({
	name = "cl_rollspeed",
	defaultvalue = "17.5", -- Quake cl_rollspeed. 200 is Quake's run speed, 36 is SRB2's (default) run speed
	flags = CV_CALL|CV_FLOAT,
	PossibleValue = nil,
	func = writeConfig
})
convars[#convars+1] = CV_RegisterVar({
	name = "cl_rollangle", -- Quake cl_rollangle. Internally multiplied by 4
	defaultvalue = "0.65",
	flags = CV_CALL|CV_FLOAT,
	PossibleValue = nil,
	func = writeConfig
})

readConfig()

initialized = true -- default value being set calls func?

addHook("ThinkFrame", viewRoll)
addHook("PlayerSpawn", function(player)
	-- avoid debug flood
	if player == displayplayer then
		displayplayer.v_dmg_roll = 0
		displayplayer.v_dmg_time = 0
	end
end)