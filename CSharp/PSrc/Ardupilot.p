machine Ardupilot
{
    var uart: machine;
    var hbpayload: tHBPayload;
    start state Init 
    {
        entry (serial: machine)
        {
            uart = serial;
            hbpayload = (mtype = mav_type_fixed_wing, 
                         mautopilot = mav_autopilot_ardupilotmega,
                         mmode = mav_mode_auto_disarmed,
                         mstate = mav_state_active);
            goto Run;
        }
    }

    state Run
    {
        entry
        {
            send_default_messages();
        }
        on eError do (flag: error)
        {
            handle_error(flag);
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Armed
    {
        entry
        {
            send_default_messages();
        }
        on eError do (flag: error)
        {
            handle_error(flag);
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Takeoff
    {
        entry
        {
            send_default_messages();
        }
        on eError do (flag: error)
        {
            handle_error(flag);
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Mission
    {
        entry
        {
            send_default_messages();
        }
        on eError do (flag: error)
        {
            handle_error(flag);
        }
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state Land
    {
        entry
        {
            send_default_messages();
        }
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

    fun send_default_messages()
    {
        send_heartbeat(uart, qgroundcontrol, hbpayload);
        send_system_status(uart, qgroundcontrol);
    }

    fun handle_messages(msg: seq[int])
    {
        var decMsg: seq[int];
        decMsg = decrypt_validate_message(msg);
        if(decMsg[0] == -1)
        {
            raise eError, checksum_error;
        }
        else if(decMsg[0] == msg_mission_request to int)
        {
            send_mission_current(uart, qgroundcontrol, mav_mission_state_complete);
        }
        else if(decMsg[0] == msg_command_long to int)
        {
            handle_long_command(decMsg);
        }
    }

    fun handle_long_command(msg: seq[int])
    {
        var capayload: tCAPayload;
        if(msg[1] == mav_cmd_do_set_mode to int)
        {
            hbpayload.mmode = mav_mode_auto_armed;
            capayload = (mcmd = mav_cmd_do_set_mode, mresult = mav_result_accepted);
            send_command_ack(uart, qgroundcontrol, capayload);
            goto Armed;
        }
        if(msg[1] == mav_cmd_nav_takeoff to int)
        {
            capayload = (mcmd = mav_cmd_nav_takeoff, mresult = mav_result_accepted);
            send_command_ack(uart, qgroundcontrol, capayload);
            goto Takeoff;
        }
        if(msg[1] == mav_cmd_nav_land to int)
        {
            capayload = (mcmd = mav_cmd_nav_land, mresult = mav_result_accepted);
            send_command_ack(uart, qgroundcontrol, capayload);
            goto Land;
        }
        if(msg[1] == mav_cmd_preflight_reboot_shutdown to int)
        {
            goto Shutdown;
        }
        if(msg[1] == mav_cmd_mission_start to int)
        {
            capayload = (mcmd = mav_cmd_mission_start, mresult = mav_result_accepted);
            send_command_ack(uart, qgroundcontrol, capayload);
            goto Mission;
        }
    }
}