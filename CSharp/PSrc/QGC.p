machine QGC
{
    var ticks: int;
    var ardu: Ardupilot;
    start state Init 
    {
        entry (controller: Ardupilot)
        {
            ardu = controller;
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            var decMsg: seq[int];
            decMsg = decrypt_message(msg);
            if(decMsg[0] == (msg_heartbeat to int))
            {
                print format ("Message Heartbeat {0}", msg[1]);
            }
            else if(decMsg[0] == (msg_sys_status to int))
            {
                print format ("Message System Status {0}", msg[1]);
            }
            else if(decMsg[0] == (msg_battery_status to int))
            {
                print format ("Message Battery Status {0}", msg[1]);
            }
        }
    }

    state Connected
    {
        entry
        {

        }
    }

    fun encrypt_send_message(msg: seq[int])
    {
        var encMsg: seq[int];
        encMsg = XORCrypto(msg);
        send ardu, eMavlinkMessage, encMsg;
    }

    fun decrypt_message(msg: seq[int]): seq[int]
    {
        return XORCrypto(msg);
    }
}