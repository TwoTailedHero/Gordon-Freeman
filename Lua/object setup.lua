addHook("MobjDamage", function(target, hurter, src, dmg, dmgType)
	if not hurter return end
	if hurter.type == MT_HL1_HANDGRENADE
		HL_HurtMobj(hurter, src, 1)
		return true
	end
end)

addHook("MobjSpawn", function(mobj)
	HL_InitHealth(mobj)
end)