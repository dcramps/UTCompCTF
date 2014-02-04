//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UTComp_menu_AdrenMenu extends UTComp_Menu_MainMenu;

var automated moCheckBox ch_booster;
var automated moCheckBox ch_invis;
var automated moCheckBox ch_speed;
var automated moCheckBox ch_berserk;

var automated GUILAbel l_adren;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController,MyOwner);

    ch_booster.Checked(!class'UTComp_Settings'.default.bDisableBooster);
    ch_speed.Checked(!class'UTComp_Settings'.default.bDisableSpeed);
    ch_berserk.Checked(!class'UTComp_Settings'.default.bDisableBerserk);
    ch_invis.Checked(!class'UTComp_Settings'.default.bDisableInvis);
}

function InternalOnChange( GUIComponent C )
{
    switch(C)
    {
        case ch_booster: class'UTComp_Settings'.default.bDisableBooster=!ch_booster.IsChecked(); break;
        case ch_invis:  class'UTComp_Settings'.default.bDisableInvis=!ch_Invis.IsChecked();
        case ch_speed:  class'UTComp_Settings'.default.bDisableSpeed=!ch_Speed.IsChecked(); break;
        case ch_berserk: class'UTComp_Settings'.default.bDisableberserk=!ch_Berserk.IsChecked(); break;
    }
    class'UTComp_Settings'.static.staticSaveConfig();
}


DefaultProperties
{
    Begin Object Class=GUILabel Name=AdrenLabel
        Caption="----Adrenaline Combo Settings----"
        TextColor=(B=0,G=200,R=230)
		WinWidth=1.000000
		WinHeight=0.060000
		WinLeft=0.250000
		WinTop=0.36
     End Object
     l_Adren=GUILabel'UTCompCTFv01.UTComp_Menu_AdrenMenu.AdrenLabel'


     Begin Object Class=moCheckBox Name=BoosterCheck
        Caption="Enable Booster Combo"
        OnCreateComponent=BoosterCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.430000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Booster=moCheckBox'UTCompCTFv01.UTComp_Menu_AdrenMenu.BoosterCheck'

      Begin Object Class=moCheckBox Name=InvisCheck
        Caption="Enable Invisibility Combo"
        OnCreateComponent=InvisCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.480000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Invis=moCheckBox'UTCompCTFv01.UTComp_Menu_AdrenMenu.InvisCheck'

          Begin Object Class=moCheckBox Name=SpeedCheck
        Caption="Enable Speed Combo"
        OnCreateComponent=SpeedCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.530000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Speed=moCheckBox'UTCompCTFv01.UTComp_Menu_AdrenMenu.SpeedCheck'

     Begin Object Class=moCheckBox Name=BerserkCheck
        Caption="Enable Berserk Combo"
        OnCreateComponent=BerserkCheck.InternalOnCreateComponent
		WinWidth=0.500000
		WinHeight=0.030000
		WinLeft=0.250000
		WinTop=0.580000
         OnChange=UTComp_Menu_AdrenMenu.InternalOnChange
     End Object
     ch_Berserk=moCheckBox'UTCompCTFv01.UTComp_Menu_AdrenMenu.BerserkCheck'
}
