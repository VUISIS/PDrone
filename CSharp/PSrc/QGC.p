machine QGC
{
    var hb_monitor: HeartbeatMonitor;
    var uart: UART;
    var connected: bool;
    start state Init 
    {
        entry (serial: UART)
        {
            uart = serial;
            hb_monitor = new HeartbeatMonitor();
            connected = false;
            goto Connect;
        }
    }

    state Connect
    {
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
            if(connected)
            {
                goto Run;
            }
        }
    }

    state Run
    {
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Arm
    {
        ignore eMavlinkMessage;
        entry
        {

        }
    }

    fun handle_messages(msg: seq[int])
    {
        var decMsg: seq[int];
        decMsg = decrypt_validate_message(msg);
        if(decMsg[0] == msg_heartbeat to int)
        {
            connected = true;
            send hb_monitor, eHeartbeatMonitor, decMsg;
        }
    }
}