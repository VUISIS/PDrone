machine UART
{
    var qgc: QGC;
    var ardu: Ardupilot;
    start state Init 
    {
        entry
        {
            ardu = new Ardupilot(this);
            qgc = new QGC(this);
            goto Network;
        }
    }

    state Network
    {
        on eUARTLink do (payload: (sys: System, msg: seq[int]))
        {
            if(payload.sys == Ardupilot)
            {
                send ardu, eMavlinkMessage, payload.msg;
            }
            else if(payload.sys == QGC)
            {
                send qgc, eMavlinkMessage, payload.msg;
            }
        }
    }
}