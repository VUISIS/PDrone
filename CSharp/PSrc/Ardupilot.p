machine Ardupilot
{
    var uart: UART;
    var timer: Timer;
    var hbpayload: tHBPayload;
    start state Init 
    {
        entry (serial: UART)
        {
            uart = serial;
            hbpayload = (mtype = mav_type_fixed_wing, 
                         mautopilot = mav_autopilot_ardupilotmega,
                         mmode = mav_mode_auto_disarmed,
                         mstate = mav_state_active);
            timer = CreateTimer(this);
            StartTimer(timer);
            goto Run;
        }
    }

    state Run
    {
        entry
        {

        }
        on eTimeOut goto SendDefaultMessages;
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
            goto Run;
        }
    }

    state Armed
    {
        entry
        {

        }
        on eTimeOut goto SendDefaultMessages;
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
            goto Armed;
        }
    }

    state Takeoff
    {
        entry
        {

        }
        on eTimeOut goto SendDefaultMessages;
        on eMavlinkMessage do (msg: seq[int])
        {
            handle_messages(msg);
            goto Takeoff;
        }
    }

    state SendDefaultMessages
    {
        ignore eMavlinkMessage, eTimeOut;
        entry
        {
            send_heartbeat(uart, qgroundcontrol, hbpayload);
            send_system_status(uart, qgroundcontrol);
            goto Run;
        }
    }

    fun handle_messages(msg: seq[int])
    {
        var decMsg: seq[int];
        var capayload: tCAPayload;
        decMsg = decrypt_validate_message(msg);
        if(decMsg[0] == msg_command_long to int)
        {
            if(decMsg[1] == mav_cmd_do_set_mode to int)
            {
                capayload = (mcmd = mav_cmd_do_set_mode, mresult = mav_result_accepted);
                send_command_ack(uart, qgroundcontrol, capayload);
                check_and_set_hbpayload(decMsg[2]);
                if(hbpayload.mmode == mav_mode_auto_armed)
                {
                    goto Armed;
                }
            }
            else if(decMsg[2] == mav_cmd_nav_takeoff to int)
            {
                capayload = (mcmd = mav_cmd_nav_takeoff, mresult = mav_result_accepted);
                send_command_ack(uart, qgroundcontrol, capayload);

                goto Takeoff;
            }
        }
    }

    fun check_and_set_hbpayload(num: int)
    {
        if(num == 220)
        {
            hbpayload.mmode = mav_mode_auto_armed;
        }
    }
}