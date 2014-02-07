

class UTComp_ScoreBoardCTF extends UTComp_ScoreBoard;

#exec texture Import File=textures\UTCompLogo.TGA Name=UTCompLogo Mips=Off Alpha=1
#exec texture Import File=textures\forward_logo.dds name=ForwardLogo Mips=Off Alpha=1 LodSet=5
#exec texture Import File=textures\ScoreboardText.TGA Name=ScoreboardText Mips=Off Alpha=1

var localized string fraglimitteam;


//font names and objects
var Font FontArrayFonts[9];
var localized string FontArrayNames[9];

//Font indices
var int FONT_PLAYER_PING;
var int FONT_PLAYER_PL;
var int FONT_PLAYER_LOCATION;
var int FONT_PLAYER_STAT_NUM;
var int FONT_PLAYER_STAT;
var int FONT_PLAYER_SCORE;
var int FONT_PLAYER_NAME;
var int FONT_TEAM_PING_NUM;
var int FONT_TEAM_PL_NUM;
var int FONT_TEAM_POWERUP_NUM;
var int FONT_TEAM_PING;
var int FONT_TEAM_PL;
var int FONT_TEAM_POWERUP_PER;
var int FONT_TEAM_SCORE;

//Materials for backgrounds
var material TeamBoxMaterial;
var material TeamHeaderMaterial;

/*
 * Draw the map title, ie "Capture the Flag on Grendelkeep"
 */ 
function DrawMapTitle(Canvas Canvas)
{
  return; //fuck this who cares
  local string titlestring,scoreinfostring,RestartString;
  local float xl, yl, full, height, top, medH, smallH, titleXL, scoreInfoXL;

  Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
  Canvas.StrLen("W",xl,medH);
  height = medH;
  Canvas.Font = HUDClass.static.GetConsoleFont(Canvas);
  Canvas.StrLen("W",xl,smallH);
  height += smallH;

  full = height;
  top  = Canvas.ClipY - 8 - full;

  titleString     = GetTitleString();
  scoreInfoString = GetDefaultScoreInfoString();

  Canvas.StrLen(titleString, titleXL, YL);
  Canvas.DrawColor = HUDClass.default.GoldColor;

  if (UnrealPlayer(Owner).bDisplayLoser)
  {
    ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
  }
  else if (UnrealPlayer(Owner).bDisplayWinner)
  {
    ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
  }
  else if (PlayerController(Owner).IsDead())
  {
    RestartString = GetRestartString();
    ScoreInfoString = RestartString;
  }

  Canvas.StrLen(scoreInfoString,scoreInfoXL,YL);

  Canvas.Font = NotReducedFont;
  Canvas.SetDrawColor(255,150,0,255);
  Canvas.StrLen(TitleString,TitleXL,YL);
  Canvas.SetPos( (Canvas.ClipX/2) - (TitleXL/2), Canvas.ClipY*0.03);
  Canvas.DrawText(TitleString);


  Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
  Canvas.StrLen(ScoreInfoString,ScoreInfoXL,YL);
  Canvas.SetPos( (Canvas.ClipX/2) - (ScoreInfoXL/2), Top + (Full/2) - (YL/2));
  Canvas.DrawText(ScoreInfoString);
}

/*
 * Re-draw the scoreboard with updated data
 */
simulated event UpdateScoreBoard(Canvas C)
{
  local PlayerReplicationInfo PRI, OwnerPRI;
  local PlayerReplicationInfo RedPRI[MAXPLAYERS], BluePRI[MAXPLAYERS], SPecPRI[MAXPLAYERS];
  local int i, BluePlayerCount, RedPlayerCount, RedOwnerOffset, BlueOwnerOffset, maxTiles, numspecs, j;
  local float screenScale;
  local bool bOwnerDrawn;
    
  // Fonts
  mainFont         = HUDClass.static.GetMediumFontFor(C);
  notReducedFont   = GetSmallerFontFor(C,1);
  sortaReducedFont = GetSmallerFontFor(C,2);
  reducedFont      = GetSmallerFontFor(C,3);
  smallerFont      = GetSmallerFontFor(C,4);
  soTiny           = GetSmallerFontFor(C,5);
  maxTiles=8; //max players per team?
    

  FONT_PLAYER_PING      = 1;
  FONT_PLAYER_PL        = 1;
  FONT_PLAYER_LOCATION  = 4;
  FONT_PLAYER_STAT_NUM  = 4;
  FONT_PLAYER_STAT      = 3;
  FONT_PLAYER_SCORE     = 7;
  FONT_PLAYER_NAME      = 6;
  FONT_TEAM_PING_NUM    = 2;
  FONT_TEAM_PL_NUM      = 2;
  FONT_TEAM_POWERUP_NUM = 2;
  FONT_TEAM_PING        = 3;
  FONT_TEAM_PL          = 3;
  FONT_TEAM_POWERUP_PER = 5;
  FONT_TEAM_SCORE       = 7;



  if(Owner!=None) 
  {
    OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
  }

  //Fill team PRI arrays

  //Red/Blue offsets are useless?
  RedOwnerOffset  = -1;
  BlueOwnerOffset = -1;

  for (i=0; i<GRI.PRIArray.Length; i++)
  {
    PRI = GRI.PRIArray[i];

    if(PRI.bOnlySpectator)
    {
      specPRI[numSpecs]=PRI;
      numSpecs++;
    }

    if ((!PRI.bOnlySpectator || PRI.bWaitingPlayer))
    {
      if (PRI.Team == None || PRI.Team.TeamIndex == 0)
      {
        if (RedPlayerCount < MAXPLAYERS)
        {
          RedPRI[RedPlayerCount] = PRI;
        
          if (PRI == OwnerPRI) 
          {
            RedOwnerOffset = RedPlayerCount;
          }

          RedPlayerCount++;
        }
      }
      else 
      {
        if (BluePlayerCount < MAXPLAYERS)
        {
          BluePRI[BluePlayerCount] = PRI;
        
          if (PRI == OwnerPRI)
          {
            BlueOwnerOffset = BluePlayerCount;
          }

          BluePlayerCount++;
        }
      }
    }
  }

  screenScale = C.ClipX/1920; //1920 as a base..go down from there. 1024x768 --> 1024/1920 = 0.533 etc
  //DrawLogo(C, screenScale);
  //DrawMapTitle(C);

  DrawTeamHeaders(C);
  DrawCTFTeamInfoBoxes(C, RedPlayerCount, BluePlayerCount);

  C.SetDrawColor(255,255,255,255);

  if (((FPHTime == 0) || (!UnrealPlayer(Owner).bDisplayLoser && !UnrealPlayer(Owner).bDisplayWinner)) && (GRI.ElapsedTime > 0))
  {
    FPHTime = GRI.ElapsedTime;
  }

  for ( i=0; i<RedPlayerCount && i<maxTiles; i++ )
  {
    if(!redPRI[i].bOnlySpectator)
    {
      if(i==(maxTiles-1) && !bOwnerDrawn && OwnerPRI.Team != none && OwnerPRI.Team.TeamIndex==0 && !OwnerPRI.bOnlySpectator)
      {
        DrawPlayerInformation(C,OwnerPRI,C.ClipX*(0.003),(C.ClipY*0.055)*i,screenScale);
      }
      else
      {
        DrawPlayerInformation(C,RedPRI[i],C.ClipX*(0.003),(C.ClipY*0.055)*i,screenScale);
      }

      if (RedPRI[i]==OwnerPRI)
      {
        bOwnerDrawn=True;
      }
    }
  }
  
  for ( i=0; i<BluePlayerCount && i<maxTiles; i++ )
  {
    if(!BluePRI[i].bOnlySpectator)
    {
      if(i==(maxTiles-1) && !bOwnerDrawn && OwnerPRI.Team != none && OwnerPRI.Team.TeamIndex==1 && !OwnerPRI.bOnlySpectator)
      {
        DrawPlayerInformation(C,OwnerPRI,C.ClipX*0.496,(C.ClipY*0.055)*i,screenScale);
      }
      else
      {
        DrawPlayerInformation(C,BluePRI[i],C.ClipX*0.496,(C.ClipY*0.055)*i,screenScale);
      }

      if (BluePRI[i]==OwnerPRI)
      {
        bOwnerDrawn=True;
      }
    }
  }

  DrawStats(C);
  DrawPowerups(C);

  if(numSpecs>0)
  {
    //ArrangeSpecs(specPRI);
    for (i=0; i<numspecs && specPRI[i]!=None; i++)
    {
      DrawSpecs(C, SpecPRI[i], i);
    }

    DrawSpecs(C,None,i);
  }
}


/*
 * Draw the UTComp logo
 */ 
simulated function DrawLogo(Canvas C , float scale)
{
  // Border
	C.SetPos(0,0);
  C.Style=5;
  C.SetDrawColor(255,255,255,180);
  C.DrawTileStretched(TeamHeaderMaterial,C.ClipX,C.ClipY*0.066);

  // TCM Logo
  C.SetPos(0,0);

  C.DrawTile(material'UTCompLogo',(512*0.75)*Scale,(128*0.75)*Scale,0,0,256,64);
}

/*
 * Draw team header
 */

simulated function DrawTeamHeaders(Canvas C)
{
  local float redScoreWidth, redScoreHeight;
  local float blueScoreWidth, blueScoreHeight;
  local int baseHeight, baseWidth, baseY, redBaseX, blueBaseX;

  baseHeight = 75;
  baseWidth  = 840;
  baseY      = 110;
  redBaseX   = 95;  //95+840 width = 935, 960-935 = 25 (Gap to mid)
  blueBaseX  = 985; //960 + 25 gap from mid

  //Turn on alpha for transparent fuckery
  C.Style = ERenderStyle.STY_Alpha;

  //Middle screen divider (debug...where is my #ifdef DEBUG?)
  SetPosScaled(C, 959, 0);
  C.SetDrawColor(255,0,0,255);
  DrawTileStretchedScaled(C, TeamHeaderMaterial, 3, 1080);

  //Main header Red
  C.SetDrawColor(0,0,0,90);
  SetPosScaled(C, redBaseX, baseY);
  DrawTileStretchedScaled(C, TeamHeaderMaterial, baseWidth, baseHeight);

  //Main header blue
  SetPosScaled(C, blueBaseX, baseY);
  DrawTileStretchedScaled(C, TeamHeaderMaterial, baseWidth, baseHeight);

  //Score
  C.SetDrawColor(255, 255, 255, 255);
  C.Style = ERenderStyle.STY_Normal;
  C.Font = GetFontWithSize(FONT_TEAM_SCORE); 
  C.StrLen(int(GRI.Teams[0].Score), redScoreWidth, redScoreHeight);
  C.StrLen(int(GRI.Teams[1].Score), blueScoreWidth, blueScoreHeight);

  DrawTextJustifiedScaled(C, int(GRI.Teams[0].Score), 2, 960-35-redScoreWidth - 10, baseY, 885  + redScoreWidth,  baseY + 75);
  DrawTextJustifiedScaled(C, int(GRI.Teams[1].Score), 0, blueBaseX + 10,            baseY, 1075 + blueScoreWidth, baseY + 75);


  //Draw average ping
  //C.DrawText(@GetAverageTeamPing(teamNum));
}

/*
 * Draw the background boxes for each player.
 */
simulated function DrawCTFTeamInfoBoxes(Canvas C, int redPlayerCount, int bluePlayerCount)
{
  local int baseHeight, baseWidth, baseY, redBaseX, blueBaseX;
  local int x;
  local int alpha;

  baseHeight = 85;
  baseWidth  = 840;
  baseY      = 110+75; //offset+height of header
  redBaseX   = 95;
  blueBaseX  = 985;

  C.Style = ERenderStyle.STY_Alpha;

  //Red players
  for (x = 0; x < redPlayerCount; x++) {
    //x % 2 == 0 ? alpha = 64 : alpha = 84;
    if (x % 2 == 0) {
      alpha = 64;
    } else {
      alpha = 84;
    }

    C.SetDrawColor(255, 0, 0, alpha);
    
    SetPosScaled(C, redBaseX, baseY + x*baseHeight);
    DrawTileStretchedScaled(C, TeamBoxMaterial, baseWidth, baseHeight);
  }


  //Blue players
  for (x = 0; x < bluePlayerCount; x++) {
    //x % 2 == 0 ? alpha = 64 : alpha = 84;
    if (x % 2 == 0) {
      alpha = 64;
    } else {
      alpha = 84;
    }

    C.SetDrawColor(0, 0, 255, alpha);

    SetPosScaled(C, blueBaseX, baseY + x*baseHeight);
    DrawTileStretchedScaled(C, TeamBoxMaterial, baseWidth, baseHeight);
  }
}


/*
 * Score, Ping, PL, Name, and stats for a given player (PRI)
 */
simulated function DrawPlayerInformation(Canvas C, PlayerReplicationInfo PRI, float x, float y, float scale)
{
  //Super.DrawPlayerInformation(C, PRI, x, y, scale);
}

/*
 * Arrange specs - WebAdmin, DemoRecSpectator go first.
 */
simulated function ArrangeSpecs(out PlayerReplicationInfo PRI[MAXPLAYERS])
{
  
}

/*
 *-----------------
 * Scaling functions
 * Regular Canvas functions but scaled versions to reduce stuff like ClipX*0.01248 existing in all the draw functions
 * These are here because I am too lazy to subclass Canvas (lol)
 *-----------------
 */

//ScaleX and ScaleY take a percentage value and convert to pixels
function float ScaleX(Canvas C, float value)
{
  return C.ClipX * (value/1920);
}

function float ScaleY(Canvas C, float value)
{
  return C.ClipY * (value/1080);
}

function SetPosScaled(Canvas C, float x, float y)
{
  C.SetPos(ScaleX(C, x), ScaleY(C, y));
}

function DrawTileStretchedScaled(Canvas C, material mat, float XL, float YL)
{
  C.DrawTileStretched(mat, ScaleX(C, XL), ScaleY(C, YL));
}

function DrawBoxScaled(Canvas C, float w, float h)
{

}

function DrawTextJustifiedScaled(Canvas C, coerce string text, byte justification, float x1, float y1, float x2, float y2)
{
  C.DrawTextJustified(text, justification, ScaleX(C, x1), ScaleY(C, y1), ScaleX(C, x2), ScaleX(C, y2));
}

/* 
 *-----------------
 * String functions
 *-----------------
 */
function String GetRestartString()
{
  local string RestartString;

  RestartString = Restart;
  if (PlayerController(Owner).PlayerReplicationInfo.bOutOfLives)
  {
    RestartString = OutFireText;
  }
  else if ( Level.TimeSeconds - UnrealPlayer(Owner).LastKickWarningTime < 2 )
  {
    RestartString = class'GameMessage'.Default.KickWarning;
  }

  return RestartString;
}


function String GetTitleString()
{
  local string titlestring;

  if ( Level.NetMode == NM_Standalone )
  {
    if ( Level.Game.CurrentGameProfile != None )
    {
      titlestring = SkillLevel[Clamp(Level.Game.CurrentGameProfile.BaseDifficulty,0,7)];
    }
    else
    {
      titlestring = SkillLevel[Clamp(Level.Game.GameDifficulty,0,7)];
    }
  }
  else if ( (GRI != None) && (GRI.BotDifficulty >= 0) )
  {
    titlestring = SkillLevel[Clamp( GRI.BotDifficulty,0,7)];
  }

  return titlestring@GRI.GameName$MapName$Level.Title;
}

function String GetDefaultScoreInfoString()
{
  local String ScoreInfoString;

  if (GRI.MaxLives != 0)
  {
    ScoreInfoString = MaxLives@GRI.MaxLives;
  }
  else if ( GRI.GoalScore != 0 )
  {

    ScoreInfoString = FragLimitTeam@GRI.GoalScore;

    if (GRI.TimeLimit != 0)
    {
      ScoreInfoString = ScoreInfoString@spacer@TimeLimit$FormatTime(GRI.RemainingTime);
    }
  }
  else
  {
    ScoreInfoString = ScoreInfoString@spacer@FooterText@FormatTime(GRI.ElapsedTime);
  }

  return ScoreInfoString;
}

simulated function string GetAverageTeamPing(byte team)
{
    local int i;
    local float avg;
    local int NumSamples;

    for(i = 0; i < GRI.PRIArray.Length; i++)
    {
        if(!GRI.PRIArray[i].bOnlySpectator && GRI.PRIArray[i].Team != None && GRI.PRIArray[i].Team.TeamIndex == team)
        {
           Avg += GRI.PRIArray[i].Ping;
           NumSamples++;
        }
    }

    if(NumSamples == 0)
    {
      return "";
    }

    return string(int(4.0*Avg/float(NumSamples))); //Why 4?
}

/*
 * -----------
 * Font loader
 * -----------
 */

static function Font GetFontWithSize(int i)
{
  if( default.FontArrayFonts[i] == None )
  {
    default.FontArrayFonts[i] = Font(DynamicLoadObject(default.FontArrayNames[i], class'Font'));
    if(default.FontArrayFonts[i] == None)
    {
      Log("Warning: "$default.Class$" Couldn't dynamically load font "$default.FontArrayNames[i]);
    }
  }

  return default.FontArrayFonts[i];
}

defaultproperties
{
  fraglimitteam="SCORE LIMIT:"
  bEnableColoredNamesOnScoreboard=True
  bDrawStats=True
  bDrawPickups=True
  bOverrideDisplayStats=false
  FontArrayNames(0)  = "Engine.DefaultFont"
  FontArrayNames(1)  = "EurostileRegular.FontEurostile12"
  FontArrayNames(2)  = "EurostileRegular.FontEurostile14"
  FontArrayNames(3)  = "UT2003Fonts.FontEurostile14"
  FontArrayNames(4)  = "EurostileRegular.FontEurostile17"
  FontArrayNames(5)  = "UT2003Fonts.FontEurostile17"
  FontArrayNames(6)  = "UT2003Fonts.FontEurostile29"
  FontArrayNames(7)  = "UT2003Fonts.FontEurostile37"
  FontArrayNames(8)  = "Engine.DefaultFont"

  TeamBoxMaterial = Material'Engine.WhiteTexture'
  TeamHeaderMaterial = Material'Engine.BlackTexture'
}
