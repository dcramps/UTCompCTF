

class UTComp_HudSettings extends Info;

struct SpecialCrosshair
{
    var texture CrossTex;
    var float CrossScale;
    var color CrossColor;
    var float OffsetX;
    var float OffsetY;
};

var array<SpecialCrosshair> UTCompCrosshairs;
var bool bEnableUTCompCrosshairs;
var bool bEnableCrosshairSizing;

var bool bMatchHudColor;

var SpecialCrosshair TempxHair;

function loadClientConfig()
{
	SetPropertyText("UTCompCrosshairs", class'UTComp_ClientConfig'.static.get("HUD_UTCompCrosshairs", GetPropertyText("UTCompCrosshairs"))); class'utcomp_hudsettings'.default.UTCompCrosshairs = UTCompCrosshairs;;
	SetPropertyText("bEnableUTCompCrosshairs", class'UTComp_ClientConfig'.static.get("HUD_bEnableUTCompCrosshairs", GetPropertyText("bEnableUTCompCrosshairs"))); class'utcomp_hudsettings'.default.bEnableUTCompCrosshairs = bEnableUTCompCrosshairs;;
	SetPropertyText("bEnableCrosshairSizing", class'UTComp_ClientConfig'.static.get("HUD_bEnableCrosshairSizing", GetPropertyText("bEnableCrosshairSizing"))); class'utcomp_hudsettings'.default.bEnableCrosshairSizing = bEnableCrosshairSizing;;
	SetPropertyText("bMatchHudColor", class'UTComp_ClientConfig'.static.get("HUD_bMatchHudColor", GetPropertyText("bMatchHudColor"))); class'utcomp_hudsettings'.default.bMatchHudColor = bMatchHudColor;;

}

function saveClientConfig()
{
	class'UTComp_ClientConfig'.static.set("HUD_UTCompCrosshairs", GetPropertyText("UTCompCrosshairs"));
	class'UTComp_ClientConfig'.static.set("HUD_bEnableUTCompCrosshairs", GetPropertyText("bEnableUTCompCrosshairs"));
	class'UTComp_ClientConfig'.static.set("HUD_bEnableCrosshairSizing", GetPropertyText("bEnableCrosshairSizing"));
	class'UTComp_ClientConfig'.static.set("HUD_bMatchHudColor", GetPropertyText("bMatchHudColor"));

	class'UTComp_ClientConfig'.static.staticSaveConfig();

}

defaultproperties
{
    bEnableCrosshairSizing=True
}
