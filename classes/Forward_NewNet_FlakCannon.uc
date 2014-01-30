//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_NewNet_FlakCannon extends NewNet_FlakCannon
HideDropDown
CacheExempt;

defaultproperties
{
    FireModeClass[0] = Class'UTCompCTF.Forward_NewNet_FlakFire'
    FireModeClass[1] = Class'UTCompCTF.Forward_newNet_FlakAltFire'
}
