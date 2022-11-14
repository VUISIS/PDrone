event eMavlinkMessage : seq[int];

machine Ardupilot
{
    var qgc: QGC;
    start state Init 
    {
        entry (program: QGC)
        {
            qgc = program;
            goto Run;
        }
    }

    state Run
    {
        entry
        {
            var heartbeat_message: seq[int];
            var battery_status_message: seq[int];
            var system_status_message: seq[int];

            heartbeat_message += (msg_heartbeat as int);
            heartbeat_message += (1);

            battery_status_message += (msg_battery_status as int);
            battery_status_message += (2);

            system_status_message += (msg_sys_status as int);
            system_status_message += (3);

            encrypt_send_message(heartbeat_message);
            encrypt_send_message(system_status_message);
            encrypt_send_message(battery_status_message);
        }
    }

    fun encrypt_send_message(msg: seq[int])
    {
        var encMsg: seq[int];
        encMsg = XORCrypto(msg);
        send qgc, eMavlinkMessage, encMsg;
    }

    fun decrypt_message(msg: seq[int])
    {
        return XORCrypto(msg);
    }
}