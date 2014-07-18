//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_Settings extends Info
HideDropDown
CacheExempt;

#exec AUDIO IMPORT FILE=Sounds\HitSound.wav             GROUP=Sounds
#exec AUDIO IMPORT FILE=Sounds\HitSoundFriendly.wav     GROUP=Sounds

var bool bFirstRun;
var bool bStats;
var bool bEnableUTCompAutoDemorec;
var string DemoRecordingMask;
var bool bEnableAutoScreenshot;
var string ScreenShotMask;
var string FriendlySound;
var string EnemySound;
var bool bEnableHitSounds;
var float HitSoundVolume;
var bool bCPMAStyleHitsounds;
var float CPMAPitchModifier;
var float SavedSpectateSpeed;
var bool bUseDefaultScoreBoard;
var bool bShowSelfInTeamOverlay;
var bool bEnableEnhancedNetCode;
var bool bEnableColoredNamesOnEnemies;
var bool ballowcoloredmessages;
var bool bEnableColoredNamesInTalk;
var string FallbackCharacterName;
var bool bEnemyBasedSkins;
var byte ClientSkinModeRedTeammate;
var byte ClientSkinModeBlueEnemy;
var byte PreferredSkinColorRedTeammate;
var byte PreferredSkinColorBlueEnemy;
var bool bBlueEnemyModelsForced;
var bool bRedTeammateModelsForced;
var string BlueEnemyModelName;
var string RedTeammateModelName;
var bool bEnableDarkSkinning;
var bool bEnemyBasedModels;


var int CurrentSelectedColoredName;
var color ColorName[20];

var bool bDisableSpeed;
var bool bDisableBooster;
var bool bDisableInvis;
var bool bDisableberserk;

struct ColoredNamePair
{
    var color SavedColor[20];
    var string SavedName;
};
var array<ColoredNamePair> ColoredName;

// Used for loading/saving the ColoredName array.
var ColoredNamePair TempColoredName;

var array<byte> DontDrawInStats;

struct ClanSkinTripple
{
    var string PlayerName;
    var color PlayerColor;
    var string ModelName;
};
var array<ClanSkinTripple> ClanSkins;


var color BlueEnemyUTCompSkinColor;
var color RedTeammateUTCompSkinColor;

var array<string> DisallowedEnemyNames;

function loadClientConfig()
{
    local int i;

    SetPropertyText("bFirstRun", class'UTComp_ClientConfig'.static.get("bFirstRun", GetPropertyText("bFirstRun"))); class'utcomp_settings'.default.bFirstRun = bFirstRun;
    SetPropertyText("bStats", class'UTComp_ClientConfig'.static.get("bStats", GetPropertyText("bStats"))); class'utcomp_settings'.default.bStats = bStats;
    SetPropertyText("bEnableUTCompAutoDemorec", class'UTComp_ClientConfig'.static.get("bEnableUTCompAutoDemorec", GetPropertyText("bEnableUTCompAutoDemorec"))); class'utcomp_settings'.default.bEnableUTCompAutoDemorec = bEnableUTCompAutoDemorec;
    SetPropertyText("DemoRecordingMask", class'UTComp_ClientConfig'.static.get("DemoRecordingMask", GetPropertyText("DemoRecordingMask"))); class'utcomp_settings'.default.DemoRecordingMask = DemoRecordingMask;
    SetPropertyText("bEnableAutoScreenshot", class'UTComp_ClientConfig'.static.get("bEnableAutoScreenshot", GetPropertyText("bEnableAutoScreenshot"))); class'utcomp_settings'.default.bEnableAutoScreenshot = bEnableAutoScreenshot;
    SetPropertyText("ScreenShotMask", class'UTComp_ClientConfig'.static.get("ScreenShotMask", GetPropertyText("ScreenShotMask"))); class'utcomp_settings'.default.ScreenShotMask = ScreenShotMask;
    SetPropertyText("FriendlySound", class'UTComp_ClientConfig'.static.get("FriendlySound", GetPropertyText("FriendlySound"))); class'utcomp_settings'.default.FriendlySound = FriendlySound;
    SetPropertyText("EnemySound", class'UTComp_ClientConfig'.static.get("EnemySound", GetPropertyText("EnemySound"))); class'utcomp_settings'.default.EnemySound = EnemySound;
    SetPropertyText("bEnableHitSounds", class'UTComp_ClientConfig'.static.get("bEnableHitSounds", GetPropertyText("bEnableHitSounds"))); class'utcomp_settings'.default.bEnableHitSounds = bEnableHitSounds;
    SetPropertyText("HitSoundVolume", class'UTComp_ClientConfig'.static.get("HitSoundVolume", GetPropertyText("HitSoundVolume"))); class'utcomp_settings'.default.HitSoundVolume = HitSoundVolume;
    SetPropertyText("bCPMAStyleHitsounds", class'UTComp_ClientConfig'.static.get("bCPMAStyleHitsounds", GetPropertyText("bCPMAStyleHitsounds"))); class'utcomp_settings'.default.bCPMAStyleHitsounds = bCPMAStyleHitsounds;
    SetPropertyText("CPMAPitchModifier", class'UTComp_ClientConfig'.static.get("CPMAPitchModifier", GetPropertyText("CPMAPitchModifier"))); class'utcomp_settings'.default.CPMAPitchModifier = CPMAPitchModifier;
    SetPropertyText("SavedSpectateSpeed", class'UTComp_ClientConfig'.static.get("SavedSpectateSpeed", GetPropertyText("SavedSpectateSpeed"))); class'utcomp_settings'.default.SavedSpectateSpeed = SavedSpectateSpeed;
    SetPropertyText("bUseDefaultScoreBoard", class'UTComp_ClientConfig'.static.get("bUseDefaultScoreBoard", GetPropertyText("bUseDefaultScoreBoard"))); class'utcomp_settings'.default.bUseDefaultScoreBoard = bUseDefaultScoreBoard;
    SetPropertyText("bShowSelfInTeamOverlay", class'UTComp_ClientConfig'.static.get("bShowSelfInTeamOverlay", GetPropertyText("bShowSelfInTeamOverlay"))); class'utcomp_settings'.default.bShowSelfInTeamOverlay = bShowSelfInTeamOverlay;
    SetPropertyText("bEnableEnhancedNetCode", class'UTComp_ClientConfig'.static.get("bEnableEnhancedNetCode", GetPropertyText("bEnableEnhancedNetCode"))); class'utcomp_settings'.default.bEnableEnhancedNetCode = bEnableEnhancedNetCode;
    SetPropertyText("bEnableColoredNamesOnEnemies", class'UTComp_ClientConfig'.static.get("bEnableColoredNamesOnEnemies", GetPropertyText("bEnableColoredNamesOnEnemies"))); class'utcomp_settings'.default.bEnableColoredNamesOnEnemies = bEnableColoredNamesOnEnemies;
    SetPropertyText("ballowcoloredmessages", class'UTComp_ClientConfig'.static.get("ballowcoloredmessages", GetPropertyText("ballowcoloredmessages"))); class'utcomp_settings'.default.ballowcoloredmessages = ballowcoloredmessages;
    SetPropertyText("bEnableColoredNamesInTalk", class'UTComp_ClientConfig'.static.get("bEnableColoredNamesInTalk", GetPropertyText("bEnableColoredNamesInTalk"))); class'utcomp_settings'.default.bEnableColoredNamesInTalk = bEnableColoredNamesInTalk;
    SetPropertyText("FallbackCharacterName", class'UTComp_ClientConfig'.static.get("FallbackCharacterName", GetPropertyText("FallbackCharacterName"))); class'utcomp_settings'.default.FallbackCharacterName = FallbackCharacterName;
    SetPropertyText("bEnemyBasedSkins", class'UTComp_ClientConfig'.static.get("bEnemyBasedSkins", GetPropertyText("bEnemyBasedSkins"))); class'utcomp_settings'.default.bEnemyBasedSkins = bEnemyBasedSkins;
    SetPropertyText("ClientSkinModeRedTeammate", class'UTComp_ClientConfig'.static.get("ClientSkinModeRedTeammate", GetPropertyText("ClientSkinModeRedTeammate"))); class'utcomp_settings'.default.ClientSkinModeRedTeammate = ClientSkinModeRedTeammate;
    SetPropertyText("ClientSkinModeBlueEnemy", class'UTComp_ClientConfig'.static.get("ClientSkinModeBlueEnemy", GetPropertyText("ClientSkinModeBlueEnemy"))); class'utcomp_settings'.default.ClientSkinModeBlueEnemy = ClientSkinModeBlueEnemy;
    SetPropertyText("PreferredSkinColorRedTeammate", class'UTComp_ClientConfig'.static.get("PreferredSkinColorRedTeammate", GetPropertyText("PreferredSkinColorRedTeammate"))); class'utcomp_settings'.default.PreferredSkinColorRedTeammate = PreferredSkinColorRedTeammate;
    SetPropertyText("PreferredSkinColorBlueEnemy", class'UTComp_ClientConfig'.static.get("PreferredSkinColorBlueEnemy", GetPropertyText("PreferredSkinColorBlueEnemy"))); class'utcomp_settings'.default.PreferredSkinColorBlueEnemy = PreferredSkinColorBlueEnemy;
    SetPropertyText("bBlueEnemyModelsForced", class'UTComp_ClientConfig'.static.get("bBlueEnemyModelsForced", GetPropertyText("bBlueEnemyModelsForced"))); class'utcomp_settings'.default.bBlueEnemyModelsForced = bBlueEnemyModelsForced;
    SetPropertyText("bRedTeammateModelsForced", class'UTComp_ClientConfig'.static.get("bRedTeammateModelsForced", GetPropertyText("bRedTeammateModelsForced"))); class'utcomp_settings'.default.bRedTeammateModelsForced = bRedTeammateModelsForced;
    SetPropertyText("BlueEnemyModelName", class'UTComp_ClientConfig'.static.get("BlueEnemyModelName", GetPropertyText("BlueEnemyModelName"))); class'utcomp_settings'.default.BlueEnemyModelName = BlueEnemyModelName;
    SetPropertyText("RedTeammateModelName", class'UTComp_ClientConfig'.static.get("RedTeammateModelName", GetPropertyText("RedTeammateModelName"))); class'utcomp_settings'.default.RedTeammateModelName = RedTeammateModelName;
    SetPropertyText("bEnableDarkSkinning", class'UTComp_ClientConfig'.static.get("bEnableDarkSkinning", GetPropertyText("bEnableDarkSkinning"))); class'utcomp_settings'.default.bEnableDarkSkinning = bEnableDarkSkinning;
    SetPropertyText("bEnemyBasedModels", class'UTComp_ClientConfig'.static.get("bEnemyBasedModels", GetPropertyText("bEnemyBasedModels"))); class'utcomp_settings'.default.bEnemyBasedModels = bEnemyBasedModels;
    SetPropertyText("CurrentSelectedColoredName", class'UTComp_ClientConfig'.static.get("CurrentSelectedColoredName", GetPropertyText("CurrentSelectedColoredName"))); class'utcomp_settings'.default.CurrentSelectedColoredName = CurrentSelectedColoredName;
    SetPropertyText("ColorName", class'UTComp_ClientConfig'.static.get("ColorName", GetPropertyText("ColorName")));
    for (i = 0; i < ArrayCount(ColorName); i++)
    {
       class'utcomp_settings'.default.ColorName[i] = ColorName[i]; 
    }

    SetPropertyText("bDisableSpeed", class'UTComp_ClientConfig'.static.get("bDisableSpeed", GetPropertyText("bDisableSpeed"))); class'utcomp_settings'.default.bDisableSpeed = bDisableSpeed;
    SetPropertyText("bDisableBooster", class'UTComp_ClientConfig'.static.get("bDisableBooster", GetPropertyText("bDisableBooster"))); class'utcomp_settings'.default.bDisableBooster = bDisableBooster;
    SetPropertyText("bDisableInvis", class'UTComp_ClientConfig'.static.get("bDisableInvis", GetPropertyText("bDisableInvis"))); class'utcomp_settings'.default.bDisableInvis = bDisableInvis;
    SetPropertyText("bDisableberserk", class'UTComp_ClientConfig'.static.get("bDisableberserk", GetPropertyText("bDisableberserk"))); class'utcomp_settings'.default.bDisableberserk = bDisableberserk;

    SetPropertyText("DontDrawInStats", class'UTComp_ClientConfig'.static.get("DontDrawInStats", GetPropertyText("DontDrawInStats"))); class'utcomp_settings'.default.DontDrawInStats = DontDrawInStats; 

    SetPropertyText("BlueEnemyUTCompSkinColor", class'UTComp_ClientConfig'.static.get("BlueEnemyUTCompSkinColor", GetPropertyText("BlueEnemyUTCompSkinColor"))); class'utcomp_settings'.default.BlueEnemyUTCompSkinColor = BlueEnemyUTCompSkinColor;
    SetPropertyText("RedTeammateUTCompSkinColor", class'UTComp_ClientConfig'.static.get("RedTeammateUTCompSkinColor", GetPropertyText("RedTeammateUTCompSkinColor"))); class'utcomp_settings'.default.RedTeammateUTCompSkinColor = RedTeammateUTCompSkinColor;
    SetPropertyText("DisallowedEnemyNames", class'UTComp_ClientConfig'.static.get("DisallowedEnemyNames", GetPropertyText("DisallowedEnemyNames"))); class'utcomp_settings'.default.DisallowedEnemyNames = DisallowedEnemyNames;


    SetPropertyText("ClanSkins", class'UTComp_ClientConfig'.static.get("ClanSkins", GetPropertyText("ClanSkins"))); class'utcomp_settings'.default.ClanSkins = ClanSkins;
    //SetPropertyText("ColoredName", class'UTComp_ClientConfig'.static.get("ColoredName", GetPropertyText("ColoredName"))); class'utcomp_settings'.default.ColoredName = ColoredName;

    // I think the SetPropetyText doesnt like when the string gets too long. UT2004 would just crash after saving two colored names.... So I'll do them one at a time !
    loadColoredName();
}

// // I think the SetPropetyText doesnt like when the string gets too long. UT2004 would just crash after saving two colored names.... So I'll do them one at a time !
function loadColoredName()
{
    local int coloredNameCount;
    local int i;
    local String coloredName;
    coloredNameCount = int(class'UTComp_ClientConfig'.static.get("ColoredNameCount"));

    class'utcomp_settings'.default.ColoredName.length = coloredNameCount;
    for (i = 0; i < coloredNameCount; i++)
    {
        coloredName = class'UTComp_ClientConfig'.static.get("ColoredName"$i);
        SetPropertyText("TempColoredName", coloredName);
        class'utcomp_settings'.default.ColoredName[i] = TempColoredName;
    }
}

// // I think the SetPropetyText doesnt like when the string gets too long. UT2004 would just crash after saving two colored names.... So I'll do them one at a time !
function saveColoredName()
{
    local int i;
    local int coloredNameCount;

    coloredNameCount = class'utcomp_settings'.default.ColoredName.length;

    class'UTComp_ClientConfig'.static.set("ColoredNameCount", coloredNameCount);

    for (i = 0; i < coloredNameCount; i++)
    {
        TempColoredName = class'utcomp_settings'.default.ColoredName[i];
        class'UTComp_ClientConfig'.static.set("ColoredName"$i, GetPropertyText("TempColoredName"));
    }

}

function saveClientConfig()
{
    local UTComp_ClientConfig clientConfig;

    clientConfig = Spawn(class'UTComp_ClientConfig');
    
    class'UTComp_ClientConfig'.static.set("bFirstRun", GetPropertyText("bFirstRun"));
    class'UTComp_ClientConfig'.static.set("bStats", GetPropertyText("bStats"));
    class'UTComp_ClientConfig'.static.set("bEnableUTCompAutoDemorec", GetPropertyText("bEnableUTCompAutoDemorec"));
    class'UTComp_ClientConfig'.static.set("DemoRecordingMask", GetPropertyText("DemoRecordingMask"));
    class'UTComp_ClientConfig'.static.set("bEnableAutoScreenshot", GetPropertyText("bEnableAutoScreenshot"));
    class'UTComp_ClientConfig'.static.set("ScreenShotMask", GetPropertyText("ScreenShotMask"));
    class'UTComp_ClientConfig'.static.set("FriendlySound", GetPropertyText("FriendlySound"));
    class'UTComp_ClientConfig'.static.set("EnemySound", GetPropertyText("EnemySound"));
    class'UTComp_ClientConfig'.static.set("bEnableHitSounds", GetPropertyText("bEnableHitSounds"));
    class'UTComp_ClientConfig'.static.set("HitSoundVolume", GetPropertyText("HitSoundVolume"));
    class'UTComp_ClientConfig'.static.set("bCPMAStyleHitsounds", GetPropertyText("bCPMAStyleHitsounds"));
    class'UTComp_ClientConfig'.static.set("CPMAPitchModifier", GetPropertyText("CPMAPitchModifier"));
    class'UTComp_ClientConfig'.static.set("SavedSpectateSpeed", GetPropertyText("SavedSpectateSpeed"));
    class'UTComp_ClientConfig'.static.set("bUseDefaultScoreBoard", GetPropertyText("bUseDefaultScoreBoard"));
    class'UTComp_ClientConfig'.static.set("bShowSelfInTeamOverlay", GetPropertyText("bShowSelfInTeamOverlay"));
    class'UTComp_ClientConfig'.static.set("bEnableEnhancedNetCode", GetPropertyText("bEnableEnhancedNetCode"));
    class'UTComp_ClientConfig'.static.set("bEnableColoredNamesOnEnemies", GetPropertyText("bEnableColoredNamesOnEnemies"));
    class'UTComp_ClientConfig'.static.set("ballowcoloredmessages", GetPropertyText("ballowcoloredmessages"));
    class'UTComp_ClientConfig'.static.set("bEnableColoredNamesInTalk", GetPropertyText("bEnableColoredNamesInTalk"));
    class'UTComp_ClientConfig'.static.set("FallbackCharacterName", GetPropertyText("FallbackCharacterName"));
    class'UTComp_ClientConfig'.static.set("bEnemyBasedSkins", GetPropertyText("bEnemyBasedSkins"));
    class'UTComp_ClientConfig'.static.set("ClientSkinModeRedTeammate", GetPropertyText("ClientSkinModeRedTeammate"));
    class'UTComp_ClientConfig'.static.set("ClientSkinModeBlueEnemy", GetPropertyText("ClientSkinModeBlueEnemy"));
    class'UTComp_ClientConfig'.static.set("PreferredSkinColorRedTeammate", GetPropertyText("PreferredSkinColorRedTeammate"));
    class'UTComp_ClientConfig'.static.set("PreferredSkinColorBlueEnemy", GetPropertyText("PreferredSkinColorBlueEnemy"));
    class'UTComp_ClientConfig'.static.set("bBlueEnemyModelsForced", GetPropertyText("bBlueEnemyModelsForced"));
    class'UTComp_ClientConfig'.static.set("bRedTeammateModelsForced", GetPropertyText("bRedTeammateModelsForced"));
    class'UTComp_ClientConfig'.static.set("BlueEnemyModelName", GetPropertyText("BlueEnemyModelName"));
    class'UTComp_ClientConfig'.static.set("RedTeammateModelName", GetPropertyText("RedTeammateModelName"));
    class'UTComp_ClientConfig'.static.set("bEnableDarkSkinning", GetPropertyText("bEnableDarkSkinning"));
    class'UTComp_ClientConfig'.static.set("bEnemyBasedModels", GetPropertyText("bEnemyBasedModels"));
    class'UTComp_ClientConfig'.static.set("CurrentSelectedColoredName", GetPropertyText("CurrentSelectedColoredName"));
    class'UTComp_ClientConfig'.static.set("ColorName", GetPropertyText("ColorName"));
    class'UTComp_ClientConfig'.static.set("bDisableSpeed", GetPropertyText("bDisableSpeed"));
    class'UTComp_ClientConfig'.static.set("bDisableBooster", GetPropertyText("bDisableBooster"));
    class'UTComp_ClientConfig'.static.set("bDisableInvis", GetPropertyText("bDisableInvis"));
    class'UTComp_ClientConfig'.static.set("bDisableberserk", GetPropertyText("bDisableberserk"));

    class'UTComp_ClientConfig'.static.set("DontDrawInStats", GetPropertyText("DontDrawInStats"));
    class'UTComp_ClientConfig'.static.set("ClanSkins", GetPropertyText("ClanSkins"));


    class'UTComp_ClientConfig'.static.set("BlueEnemyUTCompSkinColor", GetPropertyText("BlueEnemyUTCompSkinColor"));
    class'UTComp_ClientConfig'.static.set("RedTeammateUTCompSkinColor", GetPropertyText("RedTeammateUTCompSkinColor"));
    class'UTComp_ClientConfig'.static.set("DisallowedEnemyNames", GetPropertyText("DisallowedEnemyNames"));

    // I think the SetPropetyText doesnt like when the string gets too long. UT2004 would just crash after saving two colored names.... So I'll do them one at a time !
    // class'UTComp_ClientConfig'.static.set("ColoredName", GetPropertyText("ColoredName"));
    saveColoredName();

    class'UTComp_ClientConfig'.static.staticSaveConfig();
}

defaultproperties
{
    bFirstRun=True
    bStats=True
    DemoRecordingMask="%d-(%t)-%m-%p"
    ScreenShotMask="%d-(%t)-%m-%p"
    FriendlySound="UTCompCTFv03.Sounds.HitSoundFriendly"
    EnemySound="UTCompCTFv03.Sounds.HitSound"
    bEnableHitSounds=True
    HitSoundVolume=1.00
    bCPMAStyleHitsounds=True
    CPMAPitchModifier=1.40
    SavedSpectateSpeed=800.00
    bShowSelfInTeamOverlay=True
    bEnableEnhancedNetCode=True
    ballowcoloredmessages=True
    bEnableColoredNamesInTalk=True
    CurrentSelectedColoredName=255
    ColorName(0)=(R=255,G=255,B=255,A=255)
    ColorName(1)=(R=255,G=255,B=255,A=255)
    ColorName(2)=(R=255,G=255,B=255,A=255)
    ColorName(3)=(R=255,G=255,B=255,A=255)
    ColorName(4)=(R=255,G=255,B=255,A=255)
    ColorName(5)=(R=255,G=255,B=255,A=255)
    ColorName(6)=(R=255,G=255,B=255,A=255)
    ColorName(7)=(R=255,G=255,B=255,A=255)
    ColorName(8)=(R=255,G=255,B=255,A=255)
    ColorName(9)=(R=255,G=255,B=255,A=255)
    ColorName(10)=(R=255,G=255,B=255,A=255)
    ColorName(11)=(R=255,G=255,B=255,A=255)
    ColorName(12)=(R=255,G=255,B=255,A=255)
    ColorName(13)=(R=255,G=255,B=255,A=255)
    ColorName(14)=(R=255,G=255,B=255,A=255)
    ColorName(15)=(R=255,G=255,B=255,A=255)
    ColorName(16)=(R=255,G=255,B=255,A=255)
    ColorName(17)=(R=255,G=255,B=255,A=255)
    ColorName(18)=(R=255,G=255,B=255,A=255)
    ColorName(19)=(R=255,G=255,B=255,A=255)
    FallbackCharacterName="Arclite"
    ClientSkinModeRedTeammate=3
    ClientSkinModeBlueEnemy=3
    PreferredSkinColorRedTeammate=5
    PreferredSkinColorBlueEnemy=6
    BlueEnemyUTCompSkinColor=(R=0,G=0,B=128,A=255)
    RedTeammateUTCompSkinColor=(R=128,G=0,B=0,A=255)
    bBlueEnemyModelsForced=True
    bRedTeammateModelsForced=True
    BlueEnemyModelName="Arclite"
    RedTeammateModelName="Arclite"
    bEnableDarkSkinning=True
}
