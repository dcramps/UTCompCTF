class UTComp_CTFFlag extends CTFFlag;

struct FlagCarrier
{
    var Pawn FC;
    var float Time;
};

var array<FlagCarrier> FlagCarriers;
var float PickupTime;

/*
  Adds a flag carrier to the list so we can reward him if there's a cap.
*/
function AddFlagCarrier(Controller c, float dt)
{
  local int i;
  local FlagCarrier fc;

  if (c == None || !c.bIsPlayer || (c.PlayerReplicationInfo != None && c.PlayerReplicationInfo.bOnlySpectator))
    return;

  for (i = 0; i < FlagCarriers.length; i++)
  {
    if (FlagCarriers[i].FC == c.Pawn)
    {
      FlagCarriers[i].Time += dt;
      return;
    }
  }

  fc.FC = c.Pawn;
  fc.Time = dt;
  FlagCarriers[FlagCarriers.Length] = fc;
}

/*
  Rewards the flag carriers (the cap and the assists)
*/
function RewardFlagCarriers()
{
  local int i;
  local UTComp_PRI uPRI;
  local float totalTime;
  local int bonus;

  for (i = 0; i < FlagCarriers.Length; i++)
    totalTime += FlagCarriers[i].Time;

  for (i = 0; i < FlagCarriers.Length; i++)
  {
    if (FlagCarriers[i].FC != None)
    {
      if (totalTime == 0)
        bonus = 0;
      else
        bonus = (FlagCarriers[i].Time / totalTime) * (7 + class'UTCompCTFv01.MutUTComp'.Default.CapBonus);

      // At least 5 points for the capper
      if (FlagCarriers[i].FC == Holder)
        bonus = Max(bonus, class'UTCompCTFv01.MutUTComp'.Default.MinimalCapBonus);
      else
      {
        bonus = Max(bonus, 1);
        
        uPRI = class'UTComp_Util'.static.GetUTCompPRI(FlagCarriers[i].FC.PlayerReplicationInfo);
        uPRI.Assists++;
      }

      FlagCarriers[i].FC.PlayerReplicationInfo.Score += bonus;
      
      
    }
  }
}

/*
  Reset the carriers, for when a flag is returned. Called by UTCompCTF_xCTFGame
*/
function ResetFlagCarriers()
{
  FlagCarriers.Remove(0, FlagCarriers.Length);
  PickupTime = 0;
}

function LogDropped()
{
  AddFlagCarrier(Holder.Controller, Level.TimeSeconds - PickupTime);
}

auto state Home
{
    // Flag Grab
    function LogTaken(Controller c)
    {
      local UTComp_PRI uPRI;

      PickupTime = Level.TimeSeconds;

      uPRI = class'UTComp_Util'.static.GetUTCompPRI(c.PlayerReplicationInfo);
      uPRI.FlagGrabs++;

      c.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.GrabBonus;

      Super.LogTaken(c);
    }
}

state Dropped
{
    // Flag Pickup
    function LogTaken(Controller c)
    {
        local UTComp_PRI uPRI;
        local bool bCountPickup;
        local int i;

        PickupTime = Level.TimeSeconds;

        uPRI = class'UTComp_Util'.static.GetUTCompPRI(c.PlayerReplicationInfo);

        bCountPickup = true;

        // Count only one pickup from a run. The flag grab counts.
        if (FirstTouch == Controller(uPRI.Owner))
            bCountPickup = false;
        else
        {
            for (i=0; i < Assists.Length; i++)
            {
                if (Assists[i] == Controller(uPRI.Owner))
                {
                   bCountPickup = false;
                   break;
                }
            }
        }

        if (bCountPickup)
            uPRI.FlagPickups++;



       Super.LogTaken(c);
    }
}

DefaultProperties
{
  
}