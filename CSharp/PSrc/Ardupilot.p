machine Ardupilot
{
    var uart: UART;
    var timer: Timer;
    start state Init 
    {
        entry (serial: UART)
        {
            uart = serial;
            timer = CreateTimer(this);
            goto Run;
        }
    }

    state Run
    {
        entry
        {
            StartTimer(timer);
        }
        on eTimeOut goto SendDefaultMessages;
        on eMavlinkMessage do (msg: seq[int])
        {

        }
    }

    state SendDefaultMessages
    {
        ignore eMavlinkMessage;
        entry
        {
            send_heartbeat(uart, QGC);
            goto Run;
        }
    }
}