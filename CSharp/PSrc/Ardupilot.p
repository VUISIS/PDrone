event eHeartbeat : mavlink_heartbeat_t;

machine Ardupilot
{
    var qgc: QGC;
    start state Init 
    {
        entry (machine: QGC)
        {
            qgc = machine;
            goto Run;
        }
    }

    state Run
    {
        entry
        {
            send qgc, eHeartbeat, (_custom_mode = 1,
                                   _type = 1, 
                                   _base_mode = 1,  
                                   _system_status = 1,  
                                   _mavlink_version = 1);
        }
    }
}