event eHeartbeatMonitor: seq[int];

machine HeartbeatMonitor
{
    var beats: int;
    var ticks: int;
    var timer: Timer;
	start state Init 
	{   
		entry
        {
            beats = 0;
            ticks = 0;
            timer = CreateTimer(this);
            goto MonitorHeartbeat;
		}
	}

	state MonitorHeartbeat
    {
        entry 
        {
            StartTimer(timer);
        }
        on eTimeOut do 
		{
            ticks = ticks + 1;
            if(ticks > 10)
            {
                goto Disconnected;
            }
		}
		on eHeartbeatMonitor do (msg: seq[int])
		{
            beats = beats + 1;
            ticks = 0;
		}
	}

    state Disconnected
    {
        entry
        {
            CancelTimer(timer);
            raise halt;
        }
    }
}