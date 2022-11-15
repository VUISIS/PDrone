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

            heartbeat_message += (0, msg_heartbeat to int);
            heartbeat_message += (1, 1);

            battery_status_message += (0, msg_battery_status to int);
            battery_status_message += (1, 2);

            system_status_message += (0, msg_sys_status to int);
            system_status_message += (1, 3);

            encrypt_send_message(qgc, heartbeat_message);
            encrypt_send_message(qgc, battery_status_message);
            encrypt_send_message(qgc, system_status_message);
        }
    }
}