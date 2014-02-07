

class UTComp_ServerReplicationInfo extends ReplicationInfo;

var bool bEnableVoting;
var byte EnableBrightSkinsMode;
var bool bEnableClanSkins;
var bool bEnableTeamOverlay;
var bool bEnableExtraHudClock;
var byte EnableHitSoundsMode;
var bool bEnableScoreboard;
var bool bEnableWarmup;
var bool bEnableWeaponStats;
var bool bEnablePowerupStats;
var bool benableDoubleDamage;
var bool bEnableTimedOvertimeVoting;


var bool bEnableBrightskinsVoting;
var bool bEnableHitsoundsVoting;
var bool bEnableWarmupVoting;
var bool bEnableTeamOverlayVoting;
var bool bEnableMapVoting;
var bool bEnableGametypeVoting;
var bool bEnableDoubleDamageVoting;
var byte ServerMaxPlayers;
var byte MaxPlayersClone;
var bool bEnableAdvancedVotingOptions;

var string VotingNames[15];
var string VotingOptions[15];
var bool bEnableTimedOvertime;

var PlayerReplicationInfo LinePRI[10];
var bool bEnableEnhancedNetCode;
var bool bEnableEnhancedNetCodeVoting;

var bool bShieldFix;
var bool bAllowRestartVoteEvenIfMapVotingIsTurnedOff;

struct PowerupInfoStruct
{
    var xPickupBase PickupBase; // So we can always update the same one !
    var int Team;
    var float NextRespawnTime;
    var PlayerReplicationInfo LastTaker;
};

var PowerupInfoStruct PowerupInfo[8];


function int GetTeamNum(Actor a, bool forceTeam)
{
    local string locationName;
    local Volume V;
    local Volume Best;
    local CTFBase FlagBase;
    local CTFBase RedFlagBase;
    local CTFBase BlueFlagBase;

    locationName = a.Region.Zone.LocationName;
    
    if (Instr(Caps(locationName), "RED" ) != -1)
        return 0;
    
    if (Instr(Caps(locationName), "BLUE" ) != -1)
        return 1;

    // For example the 100 in Citadel, we need to find in what volume it is.
    foreach AllActors( class'Volume', V )
    {
        if( V.LocationName == "" || V.LocationName == class'Volume'.default.LocationName)
            continue;

        if( (Best != None) && (V.LocationPriority <= Best.LocationPriority) )
            continue;

        if( V.Encompasses(a) )
            Best = V;
    }

    if (Best != None)
    {
        Log("BestName"@a@Best.LocationName);
        if (Instr(Caps(Best.LocationName), "RED" ) != -1)
            return 0;
        if (Instr(Caps(Best.LocationName), "BLUE" ) != -1)
            return 1;
    }

    if (forceTeam && Level.Game.IsA('xCTFGame'))
    {
        // Well we will look at the distance from the flag base...
        

        ForEach DynamicActors(class 'CTFBase', FlagBase)
        {
            if (FlagBase.DefenderTeamIndex == 0)
                RedFlagBase = flagBase;
            else
                BlueFlagBase = flagBase;
        }

        if (RedFlagBase != None && BlueFlagBase != None)
        {
            if (VSize(a.Location - RedFlagBase.Location) < VSize(a.Location - BlueFlagBase.Location))
                return 0;
            else 
                return 1;
        }
    }

    // For example the kegs in citadel, they are both counter as in the middle :/
    //TODO: calculate the distance from the base. Only if there are two powerups of the same class.


    return 255;
}


function PopulatePowerups()
{
    local xPickupBase bickupBase;
    local int i;
    local byte shieldPickupCount;
    local byte uDamagePickupCount;
    local byte kegPickupCount;
    local bool forceTeam; // Force finding a team if there's 2 pickups of the same type.


    foreach AllActors(class'xPickupBase', bickupBase)
    {
        if (bickupBase.PowerUp == class'XPickups.SuperShieldPack' || bickupBase.PowerUp == class'XPickups.SuperHealthPack' || bickupBase.PowerUp == class'XPickups.UDamagePack')
        {
            PowerupInfo[i].PickupBase = bickupBase;
            
            if (bickupBase.myPickUp != None)
                PowerupInfo[i].NextRespawnTime = Level.TimeSeconds + bickupBase.myPickUp.GetRespawnTime();

            if (bickupBase.PowerUp == class'XPickups.SuperShieldPack')
                shieldPickupCount++;
            else if (bickupBase.PowerUp == class'XPickups.SuperHealthPack')
                kegPickupCount++;
            else if (bickupBase.PowerUp == class'XPickups.UDamagePack')
                uDamagePickupCount++;

            i++;

            if (i == 8)
            break;
        }
    }

    for (i = 0; i < 8; i++)
    {
        if (PowerupInfo[i].PickupBase == None)
            break;
        
        forceTeam = false;

        if (PowerupInfo[i].PickupBase.PowerUp == class'XPickups.SuperShieldPack' && shieldPickupCount == 2)
            forceTeam = true;
        else if (PowerupInfo[i].PickupBase.PowerUp == class'XPickups.SuperHealthPack' && kegPickupCount == 2)
            forceTeam = true;
        else if (PowerupInfo[i].PickupBase.PowerUp == class'XPickups.UDamagePack' && uDamagePickupCount == 2)
            forceTeam = true;

        PowerupInfo[i].Team = GetTeamNum(PowerupInfo[i].PickupBase, forceTeam);
    }
}

function LogPickup(Pawn other, Pickup item)
{
    local int i;

    for (i = 0; i < 8; i++)
    {
        if (PowerupInfo[i].PickUpBase == item.PickUpBase)
        {
            PowerupInfo[i].NextRespawnTime = Level.TimeSeconds + item.GetRespawnTime() - item.RespawnEffectTime;
            PowerupInfo[i].LastTaker = other.PlayerReplicationInfo;
        }

        if (PowerupInfo[i].PickUpBase == None)
        {
            SortPowerupInfo(0, i - 1);
            return;
        }
    }

    // If we have 8 powerups (yeah, right)
    SortPowerupInfo(0, 7);    
}


//TODO: Sort moving client-side. I don't think this is good, sorting replicated things. it probably sends out the whole array ?
function SortPowerupInfo(int low, int high)
{
  //  low is the lower index, high is the upper index
  //  of the region of array a that is to be sorted
  local Int i, j;
  local float x;
  Local PowerupInfoStruct Temp;

  i = Low;
  j = High;
  x = PowerupInfo[(Low + High) / 2].NextRespawnTime;

  //  partition
  do
  {
   while (PowerupInfo[i].NextRespawnTime < x)
      i += 1;
    while ((PowerupInfo[j].NextRespawnTime > x) && (x > 0))
     j -= 1;

    if (i <= j)
    {
     // swap array elements, inlined
     Temp = PowerupInfo[i];
      PowerupInfo[i] = PowerupInfo[j];
      PowerupInfo[j] = Temp;
      i += 1; 
      j -= 1;
    }
  } until (i > j);

  //  recursion
  if (low < j)
    SortPowerupInfo(low, j);
  if (i < high)
    SortPowerupInfo(i, high);
}

replication
{
    reliable if (Role==Role_Authority)
        bEnableVoting, EnableBrightSkinsMode, EnableHitSoundsMode,
        bEnableClanSkins, bEnableTeamOverlay,
        bEnableWarmup, bEnableBrightskinsVoting,
        bEnableHitsoundsVoting, bEnableTeamOverlayVoting,
        bEnableMapVoting, bEnableGametypeVoting, VotingNames,
        benableDoubleDamage, ServerMaxPlayers, bEnableTimedOvertime,
        MaxPlayersClone, bEnableAdvancedVotingOptions, VotingOptions, LinePRI, bEnableTimedOvertimeVoting,
        bEnableEnhancedNetCodeVoting,bEnableEnhancedNetCode, bEnableWarmupVoting,
        bAllowRestartVoteEvenIfMapVotingIsTurnedOff;

    unreliable if (Role==Role_Authority && bNetOwner)
        PowerupInfo;
}

defaultproperties
{
     bEnableVoting=True
     EnableBrightSkinsMode=3
     bEnableClanSkins=True
     bEnableTeamOverlay=True
     EnableHitSoundsMode=1
     bEnableScoreboard=True
     bEnableWarmup=True
     bEnableWeaponStats=True
     bEnablePowerupStats=True
     bEnableBrightskinsVoting=True
     bEnableHitsoundsVoting=True
     bEnableWarmupVoting=True
     bEnableTeamOverlayVoting=True
     bEnableMapVoting=True
     bEnableGametypeVoting=True
     bEnableDoubleDamageVoting=True
     ServerMaxPlayers=10
     bEnableTimedOvertimeVoting=True
     bEnableTimedOvertime=False
}

