-- "Script" that's actually purely for reference at a later time
/*
AddMindscapeDialogSet(nil, {
    {"FA_ANGR", "Facciolo", "Your resolve is admirable, but futile!"},
    {"GF_SPAS", "Gordon", "..."},
}, "gordon", BOSS_PHASE1_TEXT)

AddMindscapeDialogSet(nil, {
    {"FA_SMUG", "Facciolo", "Ah, the silent one. Do you truly believe your weapon will save you?"},
    {"GF_NEUT", "Gordon", "..."},
    {"FA_SMUG", "Facciolo", "How fitting. Silence is all that will remain of you."},
}, "gordon", INTRO_TEXT)
*/

-- Grenade uses RadiusDamage with its inputs being ( Vector vecSrc, entvars_t *pevInflictor, entvars_t *pevAttacker, float flDamage, float flRadius, int iClassIgnore, int bitsDamageType ).
-- What inputs does it use, though?
/*
void CHandGrenade::WeaponIdle( void )
{
	if ( m_flReleaseThrow == 0 && m_flStartThrow )
		 m_flReleaseThrow = gpGlobals->time;

	if ( m_flTimeWeaponIdle > UTIL_WeaponTimeBase() )
		return;
	
	if ( m_flStartThrow )
	{
		Vector angThrow = m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle;

		if ( angThrow.x < 0 )
			angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
		else
			angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );

		static float flMultiplier = 6.5f;
		float flVel = ( 90 - angThrow.x ) * flMultiplier;
		if ( flVel > 1000 )
			flVel = 1000;

		UTIL_MakeVectors( angThrow );

		Vector vecSrc = m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 16;

		Vector vecThrow = gpGlobals->v_forward * flVel + m_pPlayer->pev->velocity;

		// alway explode 3 seconds after the pin was pulled
		float time = m_flStartThrow - gpGlobals->time + 3.0;
		if (time < 0)
			time = 0;

		CGrenade::ShootTimed( m_pPlayer->pev, vecSrc, vecThrow, time );

		if ( flVel < 500 )
		{
			SendWeaponAnim( HANDGRENADE_THROW1 );
		}
		else if ( flVel < 1000 )
		{
			SendWeaponAnim( HANDGRENADE_THROW2 );
		}
		else
		{
			SendWeaponAnim( HANDGRENADE_THROW3 );
		}

		// player "shoot" animation
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

		m_flReleaseThrow = 0;
		m_flStartThrow = 0;
		m_flNextPrimaryAttack = GetNextAttackDelay(0.5);
		m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + 0.5;

		m_pPlayer->m_rgAmmo[ m_iPrimaryAmmoType ]--;

		if ( !m_pPlayer->m_rgAmmo[ m_iPrimaryAmmoType ] )
		{
			// just threw last grenade
			// set attack times in the future, and weapon idle in the future so we can see the whole throw
			// animation, weapon idle will automatically retire the weapon for us.
			m_flTimeWeaponIdle = m_flNextSecondaryAttack = m_flNextPrimaryAttack = GetNextAttackDelay(0.5);// ensure that the animation can finish playing
		}
		return;
	}
	else if ( m_flReleaseThrow > 0 )
	{
		// we've finished the throw, restart.
		m_flStartThrow = 0;

		if ( m_pPlayer->m_rgAmmo[ m_iPrimaryAmmoType ] )
		{
			SendWeaponAnim( HANDGRENADE_DRAW );
		}
		else
		{
			RetireWeapon();
			return;
		}

		m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + UTIL_SharedRandomFloat( m_pPlayer->random_seed, 10, 15 );
		m_flReleaseThrow = -1;
		return;
	}

	if ( m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] )
	{
		int iAnim;
		float flRand = UTIL_SharedRandomFloat( m_pPlayer->random_seed, 0, 1 );
		if (flRand <= 0.75)
		{
			iAnim = HANDGRENADE_IDLE;
			m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + UTIL_SharedRandomFloat( m_pPlayer->random_seed, 10, 15 );// how long till we do this again.
		}
		else 
		{
			iAnim = HANDGRENADE_FIDGET;
			m_flTimeWeaponIdle = UTIL_WeaponTimeBase() + 75.0 / 30.0;
		}

		SendWeaponAnim( iAnim );
	}
}
*/

-- .357 kickback 7deg up
-- pistol kickback 2.5deg up

/*
	Shotty
	FrameIndex SHT0 A 0 0 // select
	FrameIndex SHT0 B 0 1
	FrameIndex SHT0 C 0 2
	FrameIndex SHT0 D 0 3
	FrameIndex SHT0 E 0 4

	FrameIndex SHT0 F 0 5 // idle
	FrameIndex SHT0 G 0 6
	FrameIndex SHT0 H 0 7
	FrameIndex SHT0 I 0 8
	FrameIndex SHT0 J 0 9
	FrameIndex SHT0 K 0 10
	FrameIndex SHT0 L 0 11
	FrameIndex SHT0 M 0 12
	FrameIndex SHT0 N 0 13
	FrameIndex SHT0 O 0 14

	FrameIndex SHT0 P 0 32 // idle2
	FrameIndex SHT0 Q 0 33
	FrameIndex SHT0 R 0 34
	FrameIndex SHT0 S 0 35
	FrameIndex SHT0 T 0 36
	FrameIndex SHT0 U 0 37
	FrameIndex SHT0 V 0 38
	FrameIndex SHT0 W 0 39
	FrameIndex SHT0 X 0 40
	FrameIndex SHT0 Y 0 41
	FrameIndex SHT0 Z 0 42

	FrameIndex SHT1 A 0 15 // idle3
	FrameIndex SHT1 B 0 16
	FrameIndex SHT1 C 0 17
	FrameIndex SHT1 D 0 18
	FrameIndex SHT1 E 0 19
	FrameIndex SHT1 F 0 20
	FrameIndex SHT1 G 0 21
	FrameIndex SHT1 H 0 22
	FrameIndex SHT1 I 0 23
	FrameIndex SHT1 J 0 24
	FrameIndex SHT1 K 0 25
	FrameIndex SHT1 L 0 26
	FrameIndex SHT1 M 0 27
	FrameIndex SHT1 N 0 28
	FrameIndex SHT1 O 0 29
	FrameIndex SHT1 P 0 30
	FrameIndex SHT1 Q 0 31

	FrameIndex SHT2 A 0 43 // fire
	FrameIndex SHT2 B 0 44
	FrameIndex SHT2 C 0 45
	FrameIndex SHT2 D 0 46
	FrameIndex SHT2 E 0 47
	FrameIndex SHT2 F 0 48
	FrameIndex SHT2 G 0 49
	FrameIndex SHT2 H 0 50
	FrameIndex SHT2 I 0 51
	FrameIndex SHT2 J 0 52
	FrameIndex SHT2 K 0 53
	FrameIndex SHT2 L 0 54

	FrameIndex SHT4 A 0 55 // altfire
	FrameIndex SHT4 B 0 56
	FrameIndex SHT4 C 0 57
	FrameIndex SHT4 D 0 58
	FrameIndex SHT4 E 0 59
	FrameIndex SHT4 F 0 60
	FrameIndex SHT4 G 0 61
	FrameIndex SHT4 H 0 62
	FrameIndex SHT4 I 0 63
	FrameIndex SHT4 J 0 64
	FrameIndex SHT4 K 0 65
	FrameIndex SHT4 L 0 66
	FrameIndex SHT4 M 0 67
	FrameIndex SHT4 N 0 68
	FrameIndex SHT4 O 0 69
	FrameIndex SHT4 P 0 70
	FrameIndex SHT4 Q 0 71
	FrameIndex SHT4 R 0 72
	FrameIndex SHT4 S 0 73
	FrameIndex SHT4 T 0 74
	FrameIndex SHT4 U 0 75

	FrameIndex SHT3 A 0 76 // rel start
	FrameIndex SHT3 B 0 77
	FrameIndex SHT3 C 0 78
	FrameIndex SHT3 D 0 79
	FrameIndex SHT3 E 0 80

	FrameIndex SHT3 F 0 81 // rel loop
	FrameIndex SHT3 G 0 82
	FrameIndex SHT3 H 0 83
	FrameIndex SHT3 I 0 84

	FrameIndex SHT3 J 0 85 // rel end
	FrameIndex SHT3 K 0 86
	FrameIndex SHT3 L 0 87
	FrameIndex SHT3 M 0 88
	FrameIndex SHT3 N 0 89
	FrameIndex SHT3 O 0 90
	FrameIndex SHT3 P 0 91
	FrameIndex SHT3 Q 0 92
*/