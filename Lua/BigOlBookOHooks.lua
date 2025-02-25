/*
HLInitInventory

	Hook format:
	HL.AddHook("HLInitInventory", functionname)

	Function format:
	function(player_t player)
	

	Function return value:
	Table, Table, Table, String (starting ammo, starting clips, starting weapons, initial weapon)


This hook is executed when a player spawns and their inventory is being initialized. It allows the hook function to override the default starting values for ammo, clips, inventory items, and the initial weapon. If the hook returns non‑nil values for any of these, those values will replace the defaults; if any value is nil, the engine’s default value is used instead.

HLFreemanHurt

	Hook format:
	HL.AddHook("HLFreemanHurt", functionname)

	Function format:
	function(target, inflictor, source, damage, damageType)
	

	Function return value:
	Int, DMG Constant (Damage, Damage Type (see Setup.lua))


This hook is called when Freeman is hurt. It enables modifications to the damage amount and damage type before the engine applies further effects. The hook receives the damaged object (target), the inflictor (inflictor), the source of the damage (source), the original damage amount, and the original damage type. If the hook returns non‑nil values, these will override the default damage calculations.

HLBulletHit

	Hook format:
	HL.AddHook("HLBulletHit", functionname)

	Function format:
	function(bullet, target)
	

	Function return value:
	Boolean (override default behavior?)


This hook is invoked when one of Freeman's weapons hits an object. The hook is supplied with the bullet object and the object that was hit. By returning true, the custom hook signals that no further (default) damage handling is needed.

HLGetObjectHealth

	Hook format:
	HL.AddHook("HLGetObjectHealth", functionname)

	Function format:
	function(mobj)
	
	Function return value:
	Int (Health)

When an object spawns, this hook is executed to determine its starting health. If the hook returns nil, the default logic is used.

HLGetObjectMaxStats

Hook format:
	HL.AddHook("HLGetObjectMaxStats", functionname)

Function format:
	function(mobj)
	

Function return value:
	Int, Int (max health, max armor)

This hook is called when an object is spawned, allowing a custom maximum health and maximum armor to be defined. These maximum stats are used to cap healing or armor pickups later on. If the hook returns nil for either value, the engine falls back to its defaults (usually 100 for health and 100 * FRACUNIT for armor).

HLFallDamage

	Hook format:
	HL.AddHook("HLFallDamage", functionname)

Function format:
	function(fallSpeed, isSafeFall, isFatalFall)

Function return value:
	Int (fall damage)

This hook is executed when calculating fall damage for a player. It receives the player’s fall speed along with two booleans: one indicating whether the fall is within a safe (non‑damaging) speed, and another indicating if the fall speed meets or exceeds the fatal threshold. By returning a numeric damage value, the hook can override the default damage calculation. If nil is returned, the mod uses its built‑in logic.
*/