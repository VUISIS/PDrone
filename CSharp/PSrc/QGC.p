machine QGC
{
    var ardu: Ardupilot;
    start state Init 
    {
        entry (controller: Ardupilot)
        {
            ardu = controller;
            goto Connected;
        }
    }

    state Connected
    {
        entry
        {
            
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            var decMsg: seq[int];
            decMsg = decrypt_message(msg);

            print format ("Message {0} {1}", decMsg[0], decMsg[1]);
        }
    }
}