/*
HLInitInventory

	Hook format:
	HL.AddHook("HLInitInventory", functionname)

	Function format:
	function(player_t player)
	

	Function return value:
	Table, Table, Table, String (starting ammo, starting clips, starting weapons, initial weapon)


This hook is called when a player spawns and their inventory is being initialized. It allows the hook function to override the default starting values for ammo, clips, inventory items, and the initial weapon.
If the hook returns non‑nil values for any of these, those values will replace the defaults; if any value is nil, the engine’s default value is used instead.

HLFreemanHurt

	Hook format:
	HL.AddHook("HLFreemanHurt", functionname)

	Function format:
	function(target, inflictor, source, damage, damageType)
	

	Function return value:
	Int, DMG Constant (Damage, Damage Type (see Setup.lua))


This hook is called when Freeman is hurt. It enables modifications to the damage amount and damage type before the engine applies further effects. The hook receives the damaged object (target), the inflictor (inflictor), the source of the damage (source), the original damage amount, and the original damage type.
If the hook returns non‑nil values, these will override the default damage calculations.

HLBulletHit

	Hook format:
	HL.AddHook("HLBulletHit", functionname)

	Function format:
	function(bullet, target)
	

	Function return value:
	Boolean (override default behavior?)


This hook is called when one of Freeman's weapons hits an object. The hook is supplied with the bullet object and the object that was hit. By returning true, the custom hook signals that no further (default) damage handling is needed.

HLGetObjectHealth

	Hook format:
	HL.AddHook("HLGetObjectHealth", functionname)

	Function format:
	function(mobj)
	
	Function return value:
	Int (Health)

When an object spawns, this hook is called to determine its starting health. If the hook returns nil, the default logic is used.

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

This hook is called when calculating fall damage for a player. It receives the player’s fall speed along with two booleans: one indicating whether the fall is within a safe (non‑damaging) speed, and another indicating if the fall speed meets or exceeds the fatal threshold. By returning a numeric damage value, the hook can override the default damage calculation.
If nil is returned, the mod uses its built‑in logic.

HL_GetWeapons

	Function format:
	function(items, targetSlot, player)

	Function return value:
	Table - A table with the following keys:
		"weapons": A sorted list of available weapons for the specified target slot. Each entry contains:
			name: The weapon's identifier.
			priority: A numeric value used for sorting.
			id: The sequential index in the filtered list.
		"weaponcount": The total number of weapons found for the target slot.
		"wepslotamounts": An array indicating the count of weapons in each weapon slot.

	Description:
	This function iterates through the provided items table and, for each item that exists in the player's inventory (player.hl1inventory), it checks whether the weapon belongs to the specified targetSlot. It tallies the number of weapons per slot and collects those that match the target slot into a filtered list.
	The list is then sorted by each weapon’s priority before returning the complete table of results.

HL_AddAmmo

	Function format:
	function(freeman, ammotype, ammo)

	Function return value:
	Boolean - Returns true if ammo was successfully added; false otherwise.

	Description:
	This function attempts to add a specified amount of ammo (ammo) of a given type (ammotype) to the player's ammo inventory (freeman.hl1ammo). It first validates that the ammo type and the player's ammo inventory exist.
	Then, it calculates the effective maximum ammo capacity (considering any backpack bonus via double ammo) and determines how much ammo can actually be added without exceeding that limit. If ammo is added, it plays a pickup sound and logs the pickup event in the player's history.


HL_AddWeapon

	Function format:
	function(freeman, weapon, silent, autoswitch)

	Function return value:
	Boolean - Returns true if the inventory was modified (weapon added or ammo updated), false otherwise.

	Description:
	This function adds a weapon to the player's inventory if it isn’t already present. When adding a new weapon, it plays a pickup sound (unless silent is true), records the event in the pickup history, and optionally switches the player's active weapon if autoswitch is enabled.
	Additionally, it initializes the weapon's clip values (freeman.hl1clips) and handles any initial ammo or clip gifts specified by the weapon's stats. If the weapon is already owned, the function may simply add extra ammo based on the weapon's pick-up gift.


HL_TakeWeapon

	Function format:
	function(freeman, weapon)

	Function return value:
	Boolean - Returns true if a weapon was successfully removed from the inventory; false otherwise.

	Description:
	This function removes a weapon from the player's inventory (freeman.hl1inventory). If no specific weapon is provided (i.e., weapon is nil), the entire inventory is cleared. When a weapon is removed, the function also updates the player's selection list if necessary. The return value indicates whether any change was made to the inventory.

HL_TakeAmmo

	Function format:
	function(freeman, ammotype, ammocount)

	Function return value:
	None

	Description:
	This function subtracts a specified amount of ammo (ammocount) from the player's ammo inventory (freeman.hl1ammo). If ammotype is provided, only that ammo type is affected; if ammotype is nil, the function applies the subtraction across all ammo types in the inventory. If ammocount is nil, it defaults to 0. This allows for either decrementing the ammo count or resetting it.

HL_TakeClip

	Function format:
	function(player, weapon, amount, alt)

	Function return value:
	None

	Description:
	This function deducts ammo from the clip(s) of a weapon in the player's clip inventory (player.hl1clips). When a specific weapon is provided, the function adjusts its primary or alternate clip depending on the alt parameter:
		If alt is nil, both primary and alternate clips are reduced.
		If alt is true, only the alternate clip is reduced.
		Otherwise, only the primary clip is reduced.
	If the weapon parameter is nil, the function applies these deductions to all weapons in the player's inventory.

HL_DamageGordon

	Function format:
	function(thing, tmthing, dmg)

	Function return value:
	None

	Description:
	This function applies damage to an entity (thing) using Half-Life 1’s damage calculation rules. It determines the effective damage based on either the provided dmg or an overridden damage value (tmthing.hl1damage). If the entity has armor, the damage is partially absorbed by reducing the armor first, and the remainder is subtracted from health.
	Health and armor values are then clamped to a minimum of zero. If the entity’s health drops to zero or below, the function triggers its death using the P_KillMobj method.

HL_CreateItem

	Function format:
	function(type, stats)

	Description:
	Defines item behaviors based on the type and stats table. Supported properties include:

	health: {give, set, limit, maxmult}
	armor: {give, set, limit, maxmult}
	ammo: {type, give}
	weapon: Weapon identifier or list
	invuln: {set}
	berserk: Duration
	doubleammo: Boolean

HL_PickupStats

	Table containing item properties indexed by item type. Used during pickups to apply health, armor, ammo, and powerup effects.
	
HL_AmmoStats

	Table containing properties for various ammo types:

	max: Maximum ammo the player can hold.
	icon: UI icon representing the ammo type.
	shootmobj: Default projectile or entity spawned when firing.
	safetycatch: If true, prevents firing after a weapon autoswitch while the trigger is held, requiring you to release the attack key before firing.
	explosionradius: Explosion radius for applicable ammo types.
	rechargerate: Time between each recharge cycle.
	rechargeamount: Amount of ammo gained per recharge cycle.
	silentrecharge: If true, does not allow recharging to appear in the pick-up history.

	Note that for any property, besides max and icon, weapon-defined properties take priority over ammo-defined properties.
*/