hevsounds = {
	blip				= sfx_frblip
	boop				= sfx_frboop
	boop2				= sfx_frboo2
	boop3				= sfx_frboo3
	beep				= sfx_frbeep
	beep2				= sfx_frbee2
	beep3				= sfx_frbee3
	hiss				= sfx_frhiss
	chemical_detected	= sfx_frwar0
	blood_loss			= sfx_frwar1
	minor_laceration	= sfx_frwar2
	major_laceration	= sfx_frwar3
	minor_fracture		= sfx_frwar4
	major_fracture		= sfx_frwar5
	shock_damage		= sfx_frwar6
	heat_damage			= sfx_frwar7
	seek_medic			= sfx_frseek
	health_dropping		= sfx_frhdrp
	health_critical		= sfx_frcrit
	evacuate_area		= sfx_frevac
	near_death			= sfx_fremer
	immediately			= sfx_frimme
	automedic_on		= sfx_frenga
	morphine_shot		= sfx_frmorp
	ammo_depleted		= sfx_frnoam
}

rawset(_G, "HL_StartHEVSound", function(source, sound, condition)
	source.hevsounds:insert(hevsounds[sound])
end)

rawset(_G, "FVox_WarnDamage", function(beeptype, dmgtype, player)
	local BeepSound = "blip"

	if beeptype >= 2 then
		BeepSoundDelay = 15
	end
	if beeptype == 2 then
		BeepSound = "boop3"
	elseif beeptype == 3 then
		BeepSound = "boop2"
	elseif beeptype == 4 then
		BeepSound = "beep2"
	elseif beeptype == 5 then
		BeepSound = "beep3"
	end

	-- Play the initial beep sounds if beeptype is nonzero.
	if beeptype ~= 0 then
		for i = 1, BeepSoundCount do
			if player.mo.hl1health > 0 then
				HL_StartHEVSound(player, toSound(BeepSound), nil)
			else
				break
			end
		end
	end

	-- Process based on damage type
	if dmgtype == 1 then
		HL_StartHEVSound(player, "chemical_detected", nil)
	elseif dmgtype == 2 then
		HL_StartHEVSound(player, "blood_loss", nil)
	elseif dmgtype == 3 then
		HL_StartHEVSound(player, "minor_laceration", nil)
	elseif dmgtype == 4 then
		HL_StartHEVSound(player, "major_laceration", nil)
	elseif dmgtype == 5 then
		HL_StartHEVSound(player, "minor_fracture", nil)
	elseif dmgtype == 6 then
		HL_StartHEVSound(player, "major_fracture", nil)
	elseif dmgtype == 7 then
		HL_StartHEVSound(player, "seek_medic", nil)
	elseif dmgtype == 8 then
		HL_StartHEVSound(player, "health_critical", nil)
		if A_RandomRange(0, 4) == 0 then
			HL_StartHEVSound(player, "evacuate_area", nil)
		end
	elseif dmgtype == 9 then
		HL_StartHEVSound(player, "near_death", nil)
		if A_RandomRange(0, 4) == 0 then
			HL_StartHEVSound(player, "evacuate_area"), function(player)
				if player.mo.hl1health > 0 then
					return true
				end)
		if A_RandomRange(0, 4) == 0 then
			HL_StartHEVSound(player, "immediately"), function(player)
				if player.mo.hl1health > 0 then
					return true
				end)
		end
	end
	elseif dmgtype == 10 then
		HL_StartHEVSound(player, "shock_damage", nil)
	elseif dmgtype == 11 then
		HL_StartHEVSound(player, "heat_damage", nil)
	elseif dmgtype == 12 then
		HL_StartHEVSound(player, "automedic_on", nil)
		if player.mo.hl1health < 1 then return end
		for i = 1, BeepSoundCount do
			if player.mo.hl1health > 0 then
				HL_StartHEVSound(player, BeepSound, nil)
			else
				break
			end
		end
		if player.mo.hl1health < 1 then return end
		HL_StartHEVSound(player, "hiss", nil)
		if player.mo.hl1health < 1 then return end
		HL_StartHEVSound(player, "morphine_shot", nil)
	elseif dmgtype == 13 then
		HL_StartHEVSound(player, "ammo_depleted", nil)
	end
end)