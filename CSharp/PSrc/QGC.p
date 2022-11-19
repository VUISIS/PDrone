machine QGC
{
    var uart: machine;
    var beats: int;
    start state Init 
    {
        entry (serial: machine)
        {
            uart = serial;
            beats = 0;
            goto Run;
        }
    }

    state Run
    {
        on eError do (flag: error)
        {
            handle_error(flag);
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Shutdown
    {
        ignore eError, eMavlinkMessage;
        entry
        {
            raise halt;
        }
    }

    fun handle_messages(msg: seq[int])
    {
        var decMsg: seq[int];
        var clpayload: tCLPayload;
        var prms: seq[int];
        decMsg = decrypt_validate_message(msg);
        if(decMsg[0] == -1)
        {
            raise eError, checksum_error;
        }
        if(decMsg[0] == msg_heartbeat to int)
        {
            beats = beats + 1;
            if(beats == 1)
            {
                prms += (0, mav_mode_auto_armed to int);
                clpayload = (mcmd = mav_cmd_do_set_mode, params = prms);
                send_command_long(uart, ardupilot, clpayload);
                return;
            }
            return;
        }
        if(decMsg[0] == msg_sys_status to int)
        {
            if(decMsg[1] != healthy to int)
            {
                raise eError, health_error;
            }
        }
        if(decMsg[0] == msg_mission_current to int)
        {
            prms += (0, 1);
            prms += (1, 2);
            clpayload = (mcmd = mav_cmd_nav_land, params = prms);
            send_command_long(uart, ardupilot, clpayload);
            return;
        }
        if(decMsg[0] == msg_command_ack to int)
        {
            if(decMsg[1] == mav_cmd_do_set_mode to int)
            {
                prms += (0, 45);
                clpayload = (mcmd = mav_cmd_nav_takeoff, params = prms);
                send_command_long(uart, ardupilot, clpayload);
                return;
            }
            if(decMsg[1] == mav_cmd_nav_takeoff to int)
            {
                prms += (0, 1);
                prms += (1, 2);
                clpayload = (mcmd = mav_cmd_mission_start, params = prms);
                send_command_long(uart, ardupilot, clpayload);
                return;
            }
            if(decMsg[1] == mav_cmd_nav_land to int)
            {
                prms += (0, 2);
                clpayload = (mcmd = mav_cmd_preflight_reboot_shutdown, params = prms);
                send_command_long(uart, ardupilot, clpayload);
                goto Shutdown;
            }
            if(decMsg[1] == mav_cmd_mission_start to int)
            {
                send_mission_req(uart, ardupilot);
                return;
            }
        }
    }
}