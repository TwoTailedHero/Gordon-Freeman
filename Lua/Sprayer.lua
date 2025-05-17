-- Reserve a new mobj type for the spray projectile
freeslot("MT_SPRAY", "S_HL1_SPRAYSTATE", "S_HL1_FLASHSTATE", "SPR_HL1SPRAY", "MT_HLFLASHLIGHTBEAM", "MT_HLFLASHLIGHTPOINT", "SPR_HL1FLASHLIGHT")

states[S_HL1_SPRAYSTATE] = {
	sprite = SPR_HL1SPRAY,
	frame = FF_ADD|A,
	tics = -1,
	nextstate = S_HL1_SPRAYSTATE
}

mobjinfo[MT_SPRAY] = {
spawnstate = S_HL1_SPRAYSTATE,
spawnhealth = 100,
deathstate = S_NULL,
speed = 4*FRACUNIT,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY,
}

states[S_HL1_FLASHSTATE] = {
	sprite = SPR_HL1FLASHLIGHT,
	frame = FF_FULLBRIGHT | FF_PAPERSPRITE | FF_ADD | FF_TRANS50 | A,
	tics = -1,
	nextstate = S_HL1_FLASHSTATE
}

mobjinfo[MT_HLFLASHLIGHTBEAM] = {
spawnstate = S_HL1_SPRAYSTATE,
spawnhealth = 100,
deathstate = S_NULL,
speed = 16*FRACUNIT,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY | MF_PAPERCOLLISION,
}

mobjinfo[MT_HLFLASHLIGHTPOINT] = {
spawnstate = S_HL1_FLASHSTATE,
spawnhealth = 100,
deathstate = S_NULL,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY | MF_PAPERCOLLISION,
}

if not SPRAY then
	rawset(_G, "SPRAY", {})
end
SPRAY.names = {
	"8ball1",
	"alien_hd",
	"andre",
	"atom1",
	"b_axe1",
	"biohzrd",
	"bull2",
	"camp1",
	"chick1",
	"chkr_flg",
	"chuckskull",
	"clover1",
	"cobra1",
	"cow_skll",
	"devl1",
	"dice1",
	"dragon1",
	"eagle1",
	"elephnt1",
	"exclaim1",
	"explo1",
	"flower1",
	"fly1",
	"fox1",
	"gorilla",
	"gun1",
	"heart",
	"hshoe1",
	"kilroy",
	"lambda",
	"leo1",
	"mdvl_dog",
	"no1",
	"paydues1",
	"peace1",
	"peace2",
	"poisen",
	"lambda2",
	"ribbon",
	"rooster1",
	"skull",
	"smiley",
	"spidey1",
	"splatt",
	"spookcat",
	"stallion2",
	"stop1",
	"target1",
	"tiger1",
	"tiki",
	"toxskull",
	"unicorn1",
	"v_1",
	"valve1",
	"valve2",
	"x",
	"xhamer1",
	"yinyang1",
	"degagedi",
}

-- Hide ourselves for the moment
addHook("MobjSpawn", function(mobj)
	mobj.flags2 = $ | MF2_DONTDRAW
end, MT_SPRAY)

-- Fly forward until we hit something
local function HL_TheRaycastingAtHome(mobj, steps, nokill)
	local shooter = mobj.target
	local didathing = false
	shooter.flags = $|MF_NOCLIP -- No touchie.
	local fuse = steps or mobj.fuse or 32
	for i = 1, fuse do
		if not mobj and not mobj.valid then break end
		if P_RailThinker(mobj) then
			didathing = true
			break
		end
		if mobj.endcast then
			didathing = true
			break
		end
	end
	if not didathing and not nokill
		P_KillMobj(mobj, nil, nil, DMG_INSTAKILL)
	end
	shooter.flags = $&~MF_NOCLIP
end

addHook("MobjThinker", HL_TheRaycastingAtHome, MT_SPRAY)

addHook("MobjThinker", function(mobj)
	local pmo = mobj.target
	local player = pmo.player
	local freeman = player.hl
	mobj.sprite = SPR_HL1FLASHLIGHT
	if not (mobj.frame & FF_PAPERSPRITE) then
		mobj.fuse = 1
		mobj.z = $+(player.viewheight/2)
	end
	mobj.flags = $ & ~(MF_NOCLIP | MF_NOCLIPHEIGHT)
	mobj.endcast = false
	HL_TheRaycastingAtHome(mobj, 256)
end, MT_HLFLASHLIGHTBEAM)

-- On wall collision: stick the sprite, show, and stop thinking
local function SprayHitWall(mobj, thing, line)
    if not mobj.touchwall then
        mobj.touchwall = true
        mobj.flags = mobj.flags | MF_PAPERCOLLISION | MF_NOCLIP | MF_NOCLIPHEIGHT | MF_NOTHINK
		mobj.flags2 = $ & ~MF2_DONTDRAW

        -- compute exact wall-impact point
        local x, y = P_ClosestPointOnLine(mobj.x, mobj.y, line)
        P_SetOrigin(mobj, x, y, mobj.z)

        -- choose sprite frame from tracer’s current selection
        local idx = (mobj.tracer and mobj.tracer.player and mobj.tracer.player.hl and mobj.tracer.player.hl.spray or 38) - 1
        if idx < 0 or idx > #SPRAY.names then idx = 0 end

        -- set proper state and play spraying sound
        mobj.frame = FF_PAPERSPRITE | FF_ADD | idx
        mobj.sprite = SPR_HL1SPRAY
		mobj.angle = line.angle
		S_StartSound(mobj, sfx_hlspra)

        -- stop movement and get rid of tracer
        mobj.momx = 0
        mobj.momy = 0
		mobj.momz = 0
		mobj.tracer = nil
    end
end
addHook("MobjMoveBlocked", SprayHitWall, MT_SPRAY)

local function GoldSrcFlashlight(mobj, thing, line)
	if not line then return end
	mobj.flags = $ | MF_NOCLIP | MF_NOCLIPHEIGHT
	-- compute exact wall-impact point
	local x, y = P_ClosestPointOnLine(mobj.x, mobj.y, line)
	mobj.target.player.hl.flashlightbeam = (not $ or not $.valid) and P_SpawnMobj(x, y, mobj.z, MT_HLFLASHLIGHTPOINT) or $
	local flash = mobj.target.player.hl.flashlightbeam
	P_SetOrigin(flash, x, y, mobj.z)
	flash.angle = line.angle
	mobj.endcast = true
end
addHook("MobjMoveBlocked", GoldSrcFlashlight, MT_HLFLASHLIGHTBEAM)