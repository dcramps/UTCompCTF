class UTComp_xCTFGame extends xCTFGame 
	config;

static function PrecacheGameTextures(LevelInfo myLevel)
{
	Super.PrecacheGameTextures(myLevel);
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	Super.PrecacheGameStaticMeshes(myLevel);
}

// Replace the flags by our UTComp_Flag
function PreBeginPlay()
{

	local CTFBase FlagBase;
	local MutUTComp UTCompMutator;

	ForEach DynamicActors(class 'CTFBase', FlagBase)
	{
		if (FlagBase.DefenderTeamIndex == 0)
			FlagBase.FlagType = class'UTCompCTFv01.UTComp_xRedFlag';
		else
			FlagBase.FlagType = class'UTCompCTFv01.UTComp_xBlueFlag';
	}

	Super.PreBeginPlay();
}

function bool IsInZone(Controller c, int team)
{
	local string location;

	if (c.PlayerReplicationInfo != None)
	{
		location = c.PlayerReplicationInfo.GetLocationName();

		if (team == 0) 
			return (Instr(Caps(location), "RED" ) != -1);
  		else 
  			return (Instr(Caps(location), "BLUE") != -1);
	}

	return false;
}

function bool PreventDeath(Pawn Victim, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerReplicationInfo victimPRI, killerPRI;
	local UTComp_PRI victimuPRI, killeruPRI;

	local Pawn killerTeamFC, victimTeamFC;
	local vector killerTeamFCPosition;

	if (Victim != None && Killer != None)
	{
		victimPRI = Victim.PlayerReplicationInfo;
		killerPRI = Killer.PlayerReplicationInfo;

		// Covers and seals!
		if (victimPRI != None && killerPRI != None && killerPRI.Team != victimPRI.Team)
		{
			killerTeamFC = CTFBase(Teams[killerPRI.Team.TeamIndex].HomeBase).myFlag.Holder;
			victimTeamFC = CTFBase(Teams[victimPRI.Team.TeamIndex].HomeBase).myFlag.Holder;
			if (killerTeamFC != None)
			{
				killerTeamFCPosition = killerTeamFC.Location;
			}


			victimuPRI = class'UTComp_Util'.static.GetUTCompPRI(victimPRI);
			killeruPRI = class'UTComp_Util'.static.GetUTCompPRI(killerPRI);

			if (victimPRI.HasFlag != None)
			{
				killeruPRI.FlagKills++;
				killerPRI.Score += class'UTCompCTFv01.MutUTComp'.Default.FlagKillBonus;
			}
			else if (killerPRI.HasFlag == None && killerTeamFC != None)
			{
				// For a cover bonus:
				// a) The victim is 512uu close to the FC
				// b) The killer is 512uu close to the FC
				// c) The victim is 1536uu close to the FC and can see him
				// d) The victim is 1024uu close to the FC and the killer can see the FC
				// e) The victim is 768uu close and is in line-of-sight of the FC (but not necessarely looking at him).

				if ((VSize(Victim.Location - killerTeamFCPosition) < 512)
				 || (VSize(Killer.Location - killerTeamFCPosition) < 512)
				 || (VSize(Victim.Location - killerTeamFCPosition) < 1536 && Victim.Controller.CanSee(killerTeamFC))
				 || (VSize(Victim.Location - killerTeamFCPosition) < 1024 && Killer.CanSee(killerTeamFC))
				 || (VSize(Victim.Location - killerTeamFCPosition) < 768 && Victim.Controller.lineOfSightTo(killerTeamFC)))
				{
					killeruPRI.Covers++;
					killerPRI.Score += class'UTCompCTFv01.MutUTComp'.Default.CoverBonus;
				}

				// If the flag is still on the base, we can make seals!
				if (victimTeamFC == None)
				{
					// If both the victim and the FC are in the FC's zone, it's a seal !
					if (IsInZone(Victim.Controller, killerPRI.Team.TeamIndex) && IsInZone(killerTeamFC.Controller, killerPRI.Team.TeamIndex))
					{
						killeruPRI.Seals++;
					}
				}
			}
		}
	}


	return Super.PreventDeath(Victim, Killer, damageType, HitLocation);
}

function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local UTComp_PRI uPRI;
	local float Dist,oppDist;
	local vector FlagLoc;

	uPRI = class'UTComp_Util'.static.GetUTCompPRI(Scorer.PlayerReplicationInfo);

	// Flag return
	if (Scorer.PlayerReplicationInfo.Team == theFlag.Team)
	{	
		
		FlagLoc = theFlag.Position().Location;
		Dist = vsize(FlagLoc - theFlag.HomeBase.Location);
		oppDist = vsize(FlagLoc - Teams[1 - theFlag.TeamNum].HomeBase.Location);

		GameEvent("flag_returned",""$theFlag.Team.TeamIndex,Scorer.PlayerReplicationInfo);
		BroadcastLocalizedMessage( class'CTFMessage', 1, Scorer.PlayerReplicationInfo, None, TheFlag.Team );

		if (Dist>1024)
		{
			// figure out who's closer
			if (IsInZone(Scorer, theFlag.TeamNum))	// In your team's zone
			{
				Scorer.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.BaseReturnBonus;
				ScoreEvent(Scorer.PlayerReplicationInfo,3,"flag_ret_friendly");
			}
			else
			{
				if (oppDist <= 1000 && CTFBase(Teams[1 - theFlag.TeamNum].HomeBase).myFlag.bHome)	// Denial
				{
  					Scorer.PlayerReplicationInfo.Score += 7;
					ScoreEvent(Scorer.PlayerReplicationInfo,7,"flag_denial");
				}
				else
				{
					Scorer.PlayerReplicationInfo.Score += class'UTCompCTFv01.MutUTComp'.Default.EnemyBaseReturnBonus;
					ScoreEvent(Scorer.PlayerReplicationInfo,5,"flag_ret_enemy");
				}
			}
		}
		return;

		uPRI.FlagReturns++;
	}
	else
	{
		if (theFlag.isA('UTComp_CTFFlag'))
		{
			UTComp_CTFFlag(theFlag).RewardFlagCarriers();
		}

		uPRI.FlagCaps++;
	}

	if (theFlag.isA('UTComp_CTFFlag'))
	{
		UTComp_CTFFlag(theFlag).ResetFlagCarriers();
	}

	// Would need to copy super.ScoreFlag here to change how scoring works
	// super.ScoreFlag(Scorer, theFlag);
}

DefaultProperties
{
	GameName="UTComp Capture the Flag"
}