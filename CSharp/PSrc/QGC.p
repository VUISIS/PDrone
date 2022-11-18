machine QGC
{
    var uart: UART;
    var connected: bool;
    var beats: int;
    var health_all_ok: system_health;
    var heartbeat_info: tHBPayload;
    var timer: Timer;
    var command_sent: int;
    start state Init 
    {
        entry (serial: UART)
        {
            uart = serial;
            connected = false;
            beats = 0;
            health_all_ok = unknown;
            command_sent = mav_cmd_none to int;
            heartbeat_info = (mtype = mav_type_generic,
                              mautopilot = mav_autopilot_generic,
                              mmode = mav_mode_preflight,
                              mstate = mav_state_standby);
            timer = CreateTimer(this);
            goto Connect;
        }
    }

    state Connect
    {
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
            if(connected)
            {
                StartTimer(timer);
                goto Run;
            }
        }
    }

    state Run
    {
        on eTimeOut goto SendCommands;
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
        }
    }

    state SendCommands
    {
        ignore eMavlinkMessage, eTimeOut;
        entry
        {
            var clpayload: tCLPayload;
            var prms: seq[int];

            assert health_all_ok == healthy, "Drone health status error.";
            assert connected == true, "Drone connection error.";

            if(command_sent != mav_cmd_none to int)
            {
                goto Run;
            }

            if(heartbeat_info.mmode != mav_mode_auto_armed)
            {
                prms += (0, mav_mode_auto_armed to int);
                clpayload = (mcmd = mav_cmd_do_set_mode, params = prms);
                command_sent = mav_cmd_do_set_mode to int;
                send_command_long(uart, ardupilot, clpayload);
                goto Run;
            }
            else if(heartbeat_info.mmode == mav_mode_auto_armed)
            {
                prms += (0, 45);
                prms += (1, 90);
                prms += (2, 12);
                prms += (3, 24);
                prms += (4, 48);
                clpayload = (mcmd = mav_cmd_nav_takeoff, params = prms);
                command_sent = mav_cmd_nav_takeoff to int;
                send_command_long(uart, ardupilot, clpayload);
            }
            goto Run;
        }
    }

    fun handle_messages(msg: seq[int])
    {
        var decMsg: seq[int];
        decMsg = decrypt_validate_message(msg);
        if(decMsg[0] == msg_heartbeat to int)
        {
            check_and_set_hbinfo(decMsg[1], decMsg[2], decMsg[3], decMsg[4]);
            connected = true;
            beats = beats + 1;
        }
        else if(decMsg[0] == msg_sys_status to int)
        {
            if(decMsg[1] == 2)
            {
                health_all_ok = healthy;
            }
        }
        else if(decMsg[0] == msg_command_ack to int)
        {
            assert decMsg[2] == 0, "Command sent failed to accept.";

            if(command_sent == decMsg[1])
            {
                print("Command acknowledged.");
                command_sent = mav_cmd_none to int;
            }
        }
    }

    fun check_and_set_hbinfo(mtype: int, mautopilot: int, mmode: int, mstate: int)
    {
        if(mtype == 1)
        {
            heartbeat_info.mtype = mav_type_fixed_wing;
        }

        if(mautopilot == 3)
        {
            heartbeat_info.mautopilot = mav_autopilot_ardupilotmega;
        }

        if(mmode == 92)
        {
            heartbeat_info.mmode = mav_mode_auto_disarmed;
        }
        else if(mmode == 220)
        {
            heartbeat_info.mmode = mav_mode_auto_armed;
        }

        if(mstate == 4)
        {
            heartbeat_info.mstate = mav_state_active;
        }
    }
}