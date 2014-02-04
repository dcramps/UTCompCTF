class UTComp_CTFFlag extends CTFFlag;


auto state Home
{
    // Flag Grab
    function LogTaken(Controller c)
    {
        local UTComp_PRI uPRI;
       uPRI = class'UTComp_Util'.static.GetUTCompPRI(c.PlayerReplicationInfo);
       uPRI.FlagGrabs++;

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