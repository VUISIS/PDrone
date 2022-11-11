machine QGC
{
    var ticks: int;
    var ardu: Ardupilot;
    start state Init 
    {
        entry (machine: Ardupilot)
        {
            ardu = machine;
            receive
            {
                case eHeartbeat: 
                {
                    goto Connected;
                }
            }
        }
    }

    state Connected
    {
        entry
        {

        }
        on eHeartbeat do
        {
            ticks = ticks + 1
        }
    }
}