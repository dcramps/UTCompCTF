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

function ScoreFlag(Controller Scorer, CTFFlag theFlag)
{
	local UTComp_PRI uPRI;
	uPRI = class'UTComp_Util'.static.GetUTCompPRI(Scorer.PlayerReplicationInfo);

	// Flag return
	if (Scorer.PlayerReplicationInfo.Team == theFlag.Team)
	{
		uPRI.FlagReturns++;
	}
	else
	{
		uPRI.FlagCaps++;
	}

	// Would need to copy super.ScoreFlag here to change how scoring works
	super.ScoreFlag(Scorer, theFlag);
}

DefaultProperties
{
	GameName="UTComp Capture the Flag"
}