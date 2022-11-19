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
        on eUARTLink do (payload: (sys: system, msg: seq[int]))
        {
            if(payload.sys == ardupilot)
            {
                send ardu, eMavlinkMessage, payload.msg;
            }
            else if(payload.sys == qgroundcontrol)
            {
                send qgc, eMavlinkMessage, payload.msg;
            }
        }
    }
}

machine UnstableUART
{
    var qgc: QGC;
    var ardu: Ardupilot;
    var fault: bool;
    start state Init 
    {
        entry
        {
            fault = false;
            ardu = new Ardupilot(this);
            qgc = new QGC(this);
            goto Network;
        }
    }

    state Network
    {
        on eUARTLink do (payload: (sys: system, msg: seq[int]))
        {
            if($)
            {
                fault = true;
            }
            if(fault)
            {
                payload.msg[0] = 100;
            }

            if(payload.sys == ardupilot)
            {
                send ardu, eMavlinkMessage, payload.msg;
            }
            else if(payload.sys == qgroundcontrol)
            {
                send qgc, eMavlinkMessage, payload.msg;
            }
        }
    }
}