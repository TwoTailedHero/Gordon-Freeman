-- Copied and pasted? Who cares, it's allowed!
local RAIL = GS_RAILS -- do this to enable even more laziness, woohoo!
if GS_RAILS_SKINS==nil rawset(_G,"GS_RAILS_SKINS",{}) end
GS_RAILS_SKINS["kombifreeman"] = {
	["S_SKIN"] = {
	JUMP = true, --You can jump off rails with the jump button!
	JUMPBOOST = true, --Gain a minor jumpboost when jumping off a rail? (Up to a certain limit.)
	AIRDRAG = 44, --Airdrag time in tics after hopping off a rail. (35 tics = 1 second)

	SIDEHOP = 44, --Specifies the speed of your sidehop speed. If 0, you can't sidehop at all!
	SIDEHOPARC = 0, --If not 0, adds a vertical arc when sidehopping, creating an "arced" sidehop like in modern games.
	SIDEFLIP = nil, --Do a Modern-style sideflip? Specify a sprite here to use for it! (I recommend SPR2_SPNG for most chars)
	SIDEHOPTIME = 9, --How many tics your sidehop is considered active. If you have a slow sidehop, you probably want more time.

	EMERGENCYDROP = true, --If true, you can press CUSTOM3 to emergency-drop through rails.
	CROUCH = true, --If true, you can "crouch" by holding SPIN, gaining more favorable slope momentum at the cost of balance.
	CROUCHBUTTON = BT_SPIN, --Button to crouch with. If set to BT_SPIN|BT_CUSTOM1, it'd be either SPIN or CUSTOM1! 
	AUTOBALANCE = false, --You auto-balance on rails, losing less speed and making it near-impossible to fall off.
	SLOPEPHYSICS = true, --If false, slope physics are ignored.
	MUSTBALANCE = true, --The character must always balance as if crouching, risking falling off at all times like in SA2!

	SLOPEMULT = 0, --Percentage modifier of slope momentum. 10 would add 10% more, while -20 would reduce the effect by 20%.
	LAUNCHPOWER = 0, --Percentage modifier of vertical rail-flings. 10 would add 10% more height, while -20 would reduce it by 20%.
	STARTMODIFIER = 0, --Speed percentage modifier when attaching to rails. 10 would increase speed by 10%, while -20 decreases it 20%
	STARTSPEEDCONDITION = 0, --Minimum Speed you must be at before your start speed modifier takes place. If 0, defaults to 30.

	HEROESTWIST = 15, --The amount of speed the Heroes-Twist gives, diminishing with gained speed. If 0, you CAN'T twist at all!
	TWISTBUTTON = 0, --What button to press to perform the Heroes Twist. If 0, it mimicks the crouch button.
	ACCELSPEED = 0, --If not 0, you can forcibly accelerate on rails by simply holding forwards.
	ACCELCAP = 48, --This is the speed cap you can manually accelerate to, if you're capable. Defaults to 48.
	AUTODASHMODE = 72, --At what grinding speed you'll automatically enter dashmode. (only if you have SF_DASHMODE!)

	MINSPEED = 0, --Minimum speed your character always has when grinding. If not 0, your character can NEVER reverse!
	MAXSPEED = 180, --Your character won't gain more slopespeed than this. If 0, it's infinite.

	FORCESPRITE = nil, --Force a sprite2 when grinding, overriding both SPR2_GRND as well as the backup pose.
	FORCEHANGSPRITE = nil, --Force a sprite2 when on hangrails, rather than SPR2_RIDE
	WALLCLINGSPRITE = nil, --Use this sprite2 when readying for a walljump? Otherwise, picks sprite automatically.
	NOWINDLINES = false, --If true, doesn't spawn windlines when moving fast on rails.
	NOSIDEHOPGFX = 0, --If 1, only spawns sidehop ghosts. If 2, only spawns sidehop speedlines. If 3, spawns neither.
	NOFUNALLOWED = false, --If true, your character cannot use dunce poses with TOSS FLAG.
	AUTOVERTICALAIM = false --Soon-to-be a way to let us shoot whatever enemy's flying past us
	},
}