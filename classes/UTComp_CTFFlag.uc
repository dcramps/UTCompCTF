class UTComp_CTFFlag extends CTFFlag;

struct FlagCarrier
{
    var Controller C;
    var float Time;
};

var array<FlagCarrier> FlagCarriers;
var float PickupTime;

/*
  Adds a flag carrier to the list so we can reward him if there's a cap.
*/
function AddFlagCarrier(Controller c)
{
  local int i;
  local FlagCarrier fc;
  local float dt;

  dt = Level.TimeSeconds - PickupTime;

  //Log("AddFlagCarrier"@c.PlayerReplicationInfo.PlayerName@dt);

  if (c == None || !c.bIsPlayer || (c.PlayerReplicationInfo != None && c.PlayerReplicationInfo.bOnlySpectator))
    return;

  for (i = 0; i < FlagCarriers.length; i++)
  {
    if (FlagCarriers[i].C == c)
    {
      FlagCarriers[i].Time += dt;
      //Log("AddFlagCarrier-Existing"@c.PlayerReplicationInfo.PlayerName@dt);
      return;
    }
  }

  fc.C = c;
  fc.Time = dt;
  FlagCarriers[FlagCarriers.Length] = fc;
  //Log("AddFlagCarrier-New"@c.PlayerReplicationInfo.PlayerName@dt);
}

function string CarriedString(float Time, float TotalTime)
{
  local int Perc;
  local float f;

  if (TotalTime == 0) 
    f = 0;
  else 
    f = (Time / TotalTime) * 100;

  Time /= Level.TimeDilation;

  Perc = Clamp(f, 0, 100);
  if (Perc == 100)
    return "(Solocap," @ int(Time) @ "sec.)";
  else 
    return "(Carried" @ Perc $ "% of the time:" @ int(Time) @ "sec.)";
}

/*t
  Determines if the controller in the team's zone.
*/
function bool IsInZone(Controller c, int team)
{
  local string loc;

  if (c.PlayerReplicationInfo != None)
  {
    loc = c.PlayerReplicationInfo.GetLocationName();

    if (team == 0) 
      return (Instr(Caps(loc), "RED" ) != -1);
      else 
        return (Instr(Caps(loc), "BLUE") != -1);
  }

  return false;
}

/*
  Since we want to overrde to scores from a flag, I copied this from CTFGame and negated the original scores.
*/
function ReverseStockScoreFlag(Controller Scorer)
{
  local float Dist,oppDist;
  local int i;
  local float ppp,numtouch;
  local vector FlagLoc;

  if (Scorer.PlayerReplicationInfo.Team == Team)
  {
    FlagLoc = Position().Location;
    Dist = vsize(FlagLoc - HomeBase.Location);

    oppDist = vsize(FlagLoc - xCTFGame(Level.Game).Teams[1 - TeamNum].HomeBase.Location);

    if (Dist>1024)
    {
      // figure out who's closer
      if (Dist<=oppDist)  // In your team's zone
      {
        Scorer.PlayerReplicationInfo.Score -= 3;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo,-3,"reverse_flag_ret_friendly");
      }
      else
      {
        Scorer.PlayerReplicationInfo.Score -= 5;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo,-5,"reverse_flag_ret_enemy");

        if (oppDist<=1024)  // Denial
        {
          Scorer.PlayerReplicationInfo.Score -= 7;
          Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo,-7,"reverse_flag_denial");
        }

      }
    }
    return;
  }

  // Figure out Team based scoring.
  if (FirstTouch != None) // Original Player to Touch it gets 5
  {
    Level.Game.ScoreEvent(FirstTouch.PlayerReplicationInfo, -5, "reverse_flag_cap_1st_touch");
    FirstTouch.PlayerReplicationInfo.Score -= 5;
    FirstTouch.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
  }

  // Guy who caps gets 5
  Scorer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
  Scorer.PlayerReplicationInfo.Score -= 5;

  // Each player gets 20/x but it's guarenteed to be at least 1 point but no more than 5 points
  numtouch=0;
  for (i=0; i< Assists.length; i++)
  {
    if (Assists[i] != None)
      numtouch = numtouch - 1.0;
  }

  ppp = FClamp(20/numtouch, 1, 5);

  for (i = 0; i < Assists.length; i++)
  {
    if (Assists[i] != None)
    {
      Level.Game.ScoreEvent(Assists[i].PlayerReplicationInfo, ppp,"reverse_flag_cap_assist");
      Assists[i].PlayerReplicationInfo.Score -= int(ppp);
    }
  }

  Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo,-5,"reverse_flag_cap_final");

}


/*
 * Reset cover and seal sprees of Team cause of flag return.
 */
function ResetSprees()
{
  local UTComp_PRI uPRI;
  local Controller C;
  local PlayerReplicationInfo PRI;

  for (C = Level.ControllerList; C != None; C = C.NextController)
  {
    PRI = c.PlayerReplicationInfo;
    if (PRI != None && PRI.Team != None && PRI.Team != Team) // != because this is called on the flag that was capped.
    {
        uPRI = class'UTComp_Util'.static.GetUTCompPRI(C.PlayerReplicationInfo);

        if (uPRI != None)
        {
            uPRI.CoverSpree = 0;
            uPRI.SealSpree = 0;
        }
    }
  }
}

function bool IsOtherFlagHome()
{
  return CTFBase(xCTFGame(Level.Game).Teams[1 - TeamNum].HomeBase).myFlag.bHome;
}

/*
  UTComp scoring
*/
function ScoreFlag(Controller Scorer)
{
  local UTComp_PRI uPRI;
  local float Dist,oppDist;
  local vector FlagLoc;

  uPRI = class'UTComp_Util'.static.GetUTCompPRI(Scorer.PlayerReplicationInfo);

  // Flag return
  if (Scorer.PlayerReplicationInfo.Team == Team)
  { 
    FlagLoc = selF.Position().Location;
    Dist = vsize(FlagLoc - HomeBase.Location);
    oppDist = vsize(FlagLoc - xCTFGame(Level.Game).Teams[1 - TeamNum].HomeBase.Location);

    if (Dist > 1024)
    {
      // figure out who's closer
      if (IsInZone(Scorer, TeamNum))  // In your team's zone
      {
        Scorer.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.BaseReturnBonus;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'UTCompCTFv01.MutUTComp'.Default.BaseReturnBonus, "flag_ret_friendly");
      }
      else if (IsInZone(Scorer, 1 - TeamNum))
      {
        if (oppDist <= 1000 && IsOtherFlagHome()) // Denial
        {
          Scorer.PlayerReplicationInfo.Score += 7;
          Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, 7, "flag_denial");
        }
        else
        {
          Scorer.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.EnemyBaseReturnBonus;
          Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'UTCompCTFv01.MutUTComp'.Default.EnemyBaseReturnBonus, "flag_ret_enemy");
        }
      }
      else
      {
        Scorer.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.MidReturnBonus;
        Level.Game.ScoreEvent(Scorer.PlayerReplicationInfo, class'UTCompCTFv01.MutUTComp'.Default.MidReturnBonus, "flag_ret_mid");
      }
    }

    ResetSprees();
  }
  else
  {
    AddFlagCarrier(Scorer);
    RewardFlagCarriers();
    GiveCoverSealBonus();

    uPRI.FlagCaps++;

    // Reset spress on both team.
    ResetSprees();
    ResetFlagCarriers();
  }
  // Would need to copy super.ScoreFlag here to change how scoring works
  // super.ScoreFlag(Scorer, theFlag);
}

/*
 * Gives all players of Team that covered their FC extra bonus points after the cap.
 */
function GiveCoverSealBonus()
{
    local PlayerReplicationInfo PRI;
    local Controller C;
    local UTComp_PRI uPRI;
    local float bonus;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PRI = C.PlayerReplicationInfo;
        if (PRI != None && PRI.Team != Team) // != because this is called on the flag that was capped.
        {
            uPRI = class'UTComp_Util'.static.GetUTCompPRI(PRI);

            if (uPRI != None)
            {
                iF (uPRI.SealSpree > 0)
                {
                    bonus = uPRI.SealSpree * class'UTCompCTFv01.MutUTComp'.Default.SealBonus;
                    PRI.Score += Int(bonus);

                    if (class'UTCompCTFv01.MutUTComp'.Default.bShowSealRewardConsoleMsg)
                    {
                        if (C.Pawn != None)
                        {
                          C.Pawn.ClientMessage("You killed " $ uPRI.SealSpree $ " people sealing off the base. You get " $ Int(bonus) $ " bonus pts!");
                        }
                    }

                }

                if (uPRI.CoverSpree > 0)
                {
                    bonus = uPRI.CoverSpree * class'UTCompCTFv01.MutUTComp'.Default.CoverBonus;
                    PRI.Score += Int(bonus);

                    if (class'UTCompCTFv01.MutUTComp'.Default.bShowSealRewardConsoleMsg)
                    {
                        if (C.Pawn != None)
                        {
                          C.Pawn.ClientMessage("You killed " $ uPRI.CoverSpree $ " people covering your FC. You get " $ Int(bonus) $ " bonus pts!");
                        }
                    }
                }
            }
        }
    }
}

/*
  Rewards the flag carriers (the cap and the assists)
*/
function RewardFlagCarriers()
{
  
  local int i;
  local UTComp_PRI uPRI;
  local float totalTime;
  local float bonus;

  for (i = 0; i < FlagCarriers.Length; i++)
    totalTime += FlagCarriers[i].Time;

  //Log("RewardFlagCarriers - TotalTime:"@totalTime);

  for (i = 0; i < FlagCarriers.Length; i++)
  {
    if (FlagCarriers[i].C != None)
    {
     
      //Log("RewardFlagCarriers - "@FlagCarriers[i].C.PlayerReplicationInfo.PlayerName@"-"@FlagCarriers[i].Time);

      if (totalTime == 0)
        bonus = 0;
      else
        bonus = (FlagCarriers[i].Time / totalTime) * (7 + class'UTCompCTFv01.MutUTComp'.Default.CapBonus);

      // At least 5 points for the capper
      if (FlagCarriers[i].C == Holder.Controller)
      {
        bonus = Max(bonus, class'UTCompCTFv01.MutUTComp'.Default.MinimalCapBonus);

        if (class'UTCompCTFv01.MutUTComp'.Default.bShowAssistConsoleMsg) 
          FlagCarriers[i].C.Pawn.ClientMessage("You get " $ Int(Bonus) $ " bonus pts for the Capture!" @ CarriedString(FlagCarriers[i].Time, totalTime));
      }
      else
      {
        bonus = Max(bonus, 1);
        
        if (class'UTCompCTFv01.MutUTComp'.Default.bShowAssistConsoleMsg) 
          FlagCarriers[i].C.Pawn.ClientMessage("You get " $ Int(Bonus) $ " pts for the Assist!" @ CarriedString(FlagCarriers[i].Time, TotalTime));

        uPRI = class'UTComp_Util'.static.GetUTCompPRI(FlagCarriers[i].C.PlayerReplicationInfo);
        uPRI.Assists++;
      }
      
      FlagCarriers[i].C.PlayerReplicationInfo.Score += bonus;
    }
  }
}

/*
  Reset the carriers, for when a flag is returned. Called by UTCompCTF_xCTFGame
*/
function ResetFlagCarriers()
{
  //Log("ResetFlagCarriers");
  FlagCarriers.Remove(0, FlagCarriers.Length);
  PickupTime = 0;
}

function LogDropped()
{
  AddFlagCarrier(Holder.Controller);

  Super.LogDropped();
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

    function SameTeamTouch(Controller c)
    {
      local array<float> scores;
      local int index;
      local Controller loopC;
      local PlayerReplicationInfo loopPRI;
      local UTComp_CTFFlag otherFlag;

      if (C.PlayerReplicationInfo.HasFlag == None || !C.PlayerReplicationInfo.HasFlag.isA('UTComp_CTFFlag'))
        return;

      otherFlag = UTComp_CTFFlag(C.PlayerReplicationInfo.HasFlag);

      // Capped the other flag! Doing so, we touched our own so this is where we are at.

      // Back up the scores.
      for (loopC = Level.ControllerList; loopC != None; loopC = loopC.NextController)
      {
        loopPRI = loopC.PlayerReplicationInfo;
        if (loopPRI != None && loopPRI.Team != None && loopPRI.Team == c.PlayerReplicationInfo.Team)
        {
            scores[index++] = loopPRI.Score;
        }
      }

      // Do the stock scoring
      Super.SameTeamTouch(c);

      // Reverse the scoring
      index = 0;
      for (loopC = Level.ControllerList; loopC != None; loopC = loopC.NextController)
      {
        loopPRI = loopC.PlayerReplicationInfo;
        if (loopPRI != None && loopPRI.Team != None && loopPRI.Team == c.PlayerReplicationInfo.Team)
        {
            loopPRI.Score = scores[index++];
        }
      }

      otherFlag.ScoreFlag(c);
      //UTComp_CTFFlag(C.PlayerReplicationInfo.HasFlag).ReverseStockScoreFlag(c);
    }
}

state Dropped
{
    function SameTeamTouch(Controller c)
    {
      // returned flag
      ReverseStockScoreFlag(c);
      ScoreFlag(c);
      
      Super.SameTeamTouch(c);
    }
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