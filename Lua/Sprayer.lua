-- Reserve a new mobj type for the spray projectile
freeslot("MT_SPRAY", "S_HL1_SPRAYSTATE", "SPR_HL1SPRAY")

states[S_HL1_SPRAYSTATE] = {
	sprite = SPR_HL1SPRAY,
	frame = A,
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

rawset(_G, "SPRAY", {})
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
local function HL_TheRaycastingAtHome(mobj)
	local shooter = mobj.target
	local didathing = false
	shooter.flags = $|MF_NOCLIP -- No touchie.
	local fuse = mobj.fuse or 32
	for i = 1, fuse do
		if not mobj and not mobj.valid break end
		if P_RailThinker(mobj) didathing = true break end
	end
	if not didathing
		P_KillMobj(mobj, nil, nil, DMG_INSTAKILL)
	end
	shooter.flags = $&~MF_NOCLIP
end

addHook("MobjThinker", HL_TheRaycastingAtHome, MT_SPRAY)

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