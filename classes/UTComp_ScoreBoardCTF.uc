

class UTComp_ScoreBoardCTF extends UTComp_ScoreBoard;
//#exec texture Import File=textures\UTCompLogo.TGA Name=UTCompLogo Mips=Off Alpha=1
//#exec texture Import File=textures\UTCompLogo.TGA Name=UTCompLogo Mips=Off Alpha=1
//#exec texture Import File=textures\ScoreboardText.TGA Name=ScoreboardText Mips=Off Alpha=1
//const MAXPLAYERS=32;

var font ExtremelyTiny;

simulated event UpdateScoreBoard(Canvas C)
{
    ExtremelyTiny = GetSmallerFontFor (C, 6);
    Super.UpdateScoreBoard(C);
}

simulated function DrawPlayerInformation(Canvas C, PlayerReplicationInfo PRI, float XOffset, float YOffset, float Scale)
{
    local float tmpEff;
    local int i, otherteam;
    local PlayerReplicationInfo OwnerPRI;
    local UTComp_PRI uPRI;
    local string AdminString;
    local float oldClipX;
   	if(Owner!=None)
       OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;

    uPRI=class'UTComp_Util'.static.GetUTCompPRI(PRI);

    if (PRI.bAdmin)
       AdminString ="Admin";
    // Draw Player name

    C.Font = NotReducedFont;
    C.SetPos(C.ClipX*0.188+XOffset, (C.ClipY*0.159)+YOffset);
    oldClipX=C.ClipX;
    C.ClipX=C.ClipX*0.470+XOffset;

    if(default.benablecolorednamesonscoreboard && uPRI!=None && uPRI.ColoredName !="")
    {
      C.DrawTextClipped(uPRI.ColoredName$AdminString);
    }
    else
    {
       C.SetDrawColor(255,255,255,255);
       C.DrawTextClipped(PRI.PlayerName$AdminString);
    }
    C.ClipX=OldClipX;

    for(i=0;i<MAXPLAYERS;i++)
    {
         if( PRI == OwnerPRI )
         {
             C.SetDrawColor(255,255,0,255);
         }
         else
             C.SetDrawColor(255,255,255,255);
    }

    // DrawScore
    if(PRI.Score>99)
      C.Font= SortaReducedFont;
    else
       C.Font = NotReducedFont;


	if ( PRI.bOutOfLives )
	{
        C.SetPos(C.ClipX*0.0190+XOffset, (C.ClipY*0.159)+YOffset);
        C.DrawText("OUT");
    }
	else
	{ //  C.strLen(PRI.Score, strlenx, strleny);
     //   C.SetPos(C.ClipX*0.0190+XOffset, (C.ClipY*0.159)+YOffset);
        C.DrawTextJustified(int(PRI.Score), 0,C.ClipX*0.0190+XOffset,C.ClipY*0.159+YOffset, C.ClipX*0.068+XOffset, C.ClipY*0.204+Yoffset);

    }
    if(PRI.Team!=None && PRI.Team.TeamIndex==0)
      OtherTeam=1;
    else
      OtherTeam=0;

    if(PRI.Team !=None && (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Home) && (GRI.FlagState[OtherTeam] != EFlagState.FLAG_Down) && (PRI.HasFlag != None || PRI == GRI.FlagHolder[PRI.Team.TeamIndex]))
    {
        C.SetDrawColor(255,255,255,255);
        C.SetPos(C.ClipX*0.41+XOffset, (C.ClipY*0.159)+YOffset);
        C.DrawTile(material'xInterface.S_FlagIcon',90*scale,64*Scale,0,0,90,64);
    }

    // CTF-related stats
    C.SetDrawColor(255,255,255,255);
    C.Font = ExtremelyTiny;

    // If I just draw "FG: 1" directely, the different numbers (of FC, FG, FP, FR) are not aligned and it looks fugly
    // so I'm just gonna draw the FC, : and the number aligned to each other.

    // FG is the largest text.
    //local float XLType, YLType;
     //   local float XLType, YLType;
    //C.TextSize("FG", XL, YL);

    // Flag grabs
    C.SetPos(C.ClipX*0.070+XOffset, (C.ClipY*0.159)+YOffset);
    c.DrawText("FG");
    C.SetPos(C.ClipX*0.080+XOffset, (C.ClipY*0.159)+YOffset);
    c.DrawText(":");
    C.SetPos(C.ClipX*0.090+XOffset, (C.ClipY*0.159)+YOffset);
    c.DrawText(uPRI.FlagGrabs);

    // Flag caps
    C.SetPos(C.ClipX*0.070+XOffset, (C.ClipY*0.170)+YOffset);
    c.DrawText("FC");
    C.SetPos(C.ClipX*0.080+XOffset, (C.ClipY*0.170)+YOffset);
    c.DrawText(":");
    C.SetPos(C.ClipX*0.090+XOffset, (C.ClipY*0.170)+YOffset);
    c.DrawText(uPRI.FlagCaps);

    C.SetPos(C.ClipX*0.070+XOffset, (C.ClipY*0.181)+YOffset);
    c.DrawText("FP");
    C.SetPos(C.ClipX*0.080+XOffset, (C.ClipY*0.181)+YOffset);
    c.DrawText(":");
    C.SetPos(C.ClipX*0.090+XOffset, (C.ClipY*0.181)+YOffset);
    c.DrawText(uPRI.FlagPickups);

    C.SetPos(C.ClipX*0.070+XOffset, (C.ClipY*0.192)+YOffset);
    c.DrawText("FR");
    C.SetPos(C.ClipX*0.080+XOffset, (C.ClipY*0.192)+YOffset);
    c.DrawText(":");
    C.SetPos(C.ClipX*0.090+XOffset, (C.ClipY*0.192)+YOffset);
    c.DrawText(uPRI.FlagReturns);

    C.Font = SmallerFont;
    if(PRI==OwnerPRI)
       C.SetDrawColor(255,255,0,255);
    else
       C.SetDrawColor(255,255,255,255);
    if ( Level.NetMode != NM_Standalone )
    {// Net Info
        C.SetPos(C.ClipX*0.108+XOffset, (C.ClipY*tmp1)+YOffset);
        C.DrawText("Ping:"$Min(999,4*PRI.Ping));

        C.SetPos(C.ClipX*0.108+XOffset, (C.ClipY*tmp2)+YOffset);
        C.DrawText("P/L :"$PRI.PacketLoss);
    }

    C.SetPos(C.ClipX*0.108+XOffset, (C.ClipY*tmp3)+YOffset);

    if(uWarmup==None)
       foreach DynamicActors(class'UTComp_Warmup', uWarmup)
           break;
    if(uWarmup!=None && uWarmup.bInWarmup)
    {
       if(!uPRI.bIsReady)
          C.DrawText("Not Ready");
       else
          C.DrawText("Ready");
    }
    else if(PRI.bReadyToPlay && !GRI.bMatchHasBegun)
        C.DrawText("Ready");
    else if(!GRI.bMatchHasBegun)
        C.DrawText("Not Ready");
    else
    C.DrawText(FormatTime(Max(0,FPHTime - PRI.StartTime)) );

    // Location Name
    // Hide if Player is using HUDTeamoverlay
    if (OwnerPRI.bOnlySpectator || (PRI.Team!=None && OwnerPRI.Team!=None && PRI.Team.TeamIndex==OwnerPRI.Team.TeamIndex))
    {
        C.SetDrawColor(255,150,0,255);
	    C.SetPos(C.ClipX*0.21+XOffset, (C.ClipY*tmp3)+YOffset);
        C.DrawText(Left(PRI.GetLocationName(), 30));
    }
}

defaultproperties
{
}
