//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Forward_UTComp_BioRifle extends UTComp_BioRifle
HideDropDown
CacheExempt;

defaultproperties
{
    FireModeClass[0] = Class'UTCompCTF.UTComp_BioFire'
    FireModeClass[1] = Class'UTCompCTF.UTComp_BioChargedFire'
}
