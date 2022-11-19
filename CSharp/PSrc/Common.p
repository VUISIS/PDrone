type tHBPayload = (mtype: mav_type, mautopilot: mav_autopilot, mmode: mav_mode, mstate: mav_state);
type tCLPayload = (mcmd: mav_cmd, params: seq[int]);
type tCAPayload = (mcmd: mav_cmd, mresult: mav_result);

event eUARTLink: (sys: system, msg: seq[int]);
event eMavlinkMessage: seq[int];
event eInvalidMessage: string;
event eError: error;

enum system
{
    ardupilot = 0,
    qgroundcontrol = 1
}

enum system_health 
{
    unknown = 0,
    error = 1,
    healthy = 2
}

enum error
{
    checksum_error = 0,
    encryption_error = 1,
    transition_error = 2,
    ack_error = 3,
    health_error = 4,
    connection_error = 5
}

fun send_heartbeat(uart: machine, sys: system, hbpayload: tHBPayload)
{
    var heartbeat_message: seq[int];

    heartbeat_message += (0, msg_heartbeat to int);
    heartbeat_message += (1, hbpayload.mtype to int);
    heartbeat_message += (2, hbpayload.mautopilot to int);
    heartbeat_message += (3, hbpayload.mmode to int);
    heartbeat_message += (4, hbpayload.mstate to int);
    heartbeat_message += (5, Fletcher16(heartbeat_message));

    encrypt_send_message(uart, sys, heartbeat_message);
}

fun send_mission_req(uart: machine, sys: system)
{
    var mission_req_message: seq[int];

    mission_req_message += (0, msg_mission_request to int);
    mission_req_message += (1, Fletcher16(mission_req_message));

    encrypt_send_message(uart, sys, mission_req_message);
}

fun send_system_status(uart: machine, sys: system)
{
    var sys_status_message: seq[int];

    sys_status_message += (0, msg_sys_status to int);
    sys_status_message += (1, healthy to int);
    sys_status_message += (2, 25);
    sys_status_message += (3, 100);
    sys_status_message += (4, Fletcher16(sys_status_message));

    encrypt_send_message(uart, sys, sys_status_message);
}

fun send_mission_current(uart: machine, sys: system, status: mav_mission_state)
{
    var mission_current_message: seq[int];

    mission_current_message += (0, msg_mission_current to int);
    mission_current_message += (1, status to int);
    mission_current_message += (2, Fletcher16(mission_current_message));

    encrypt_send_message(uart, sys, mission_current_message);
}

fun send_command_long(uart: machine, sys: system, clpayload: tCLPayload)
{
    var command_long_message: seq[int];
    var num: int;
    var idx: int;
    idx = 2;

    command_long_message += (0, msg_command_long to int);
    command_long_message += (1, clpayload.mcmd to int);
    foreach(num in clpayload.params)
    {
        command_long_message += (idx, num);
        idx = idx + 1;
    }
    command_long_message += (2+sizeof(clpayload.params), Fletcher16(command_long_message));

    encrypt_send_message(uart, sys, command_long_message);
}

fun send_command_ack(uart: machine, sys: system, capayload: tCAPayload)
{
    var command_ack_message: seq[int];

    command_ack_message += (0, msg_command_ack to int);
    command_ack_message += (1, capayload.mcmd to int);
    command_ack_message += (2, capayload.mresult to int);
    command_ack_message += (3, Fletcher16(command_ack_message));

    encrypt_send_message(uart, sys, command_ack_message);
}

fun encrypt_send_message(uart: machine, sys: system, msg: seq[int])
{
    var encMsg: seq[int];
    encMsg = XORCrypto(msg);
    send uart, eUARTLink, (sys = sys, msg = encMsg);
}

fun decrypt_message(msg: seq[int]): seq[int]
{
    return XORCrypto(msg);
}

fun validate_checksum(msg_checksum: int, calc_checksum: int): bool
{
    return (msg_checksum == calc_checksum);
}

fun decrypt_validate_message(msg: seq[int]): seq[int]
{
    var msg_checksum: int;
    var calc_checksum: int;
    var decMsg: seq[int];
    var tempDecMsg: seq[int];

    decMsg = decrypt_message(msg);
    
    tempDecMsg = decMsg;
    
    msg_checksum = tempDecMsg[sizeof(tempDecMsg)-1];
    
    tempDecMsg -= (sizeof(tempDecMsg)-1);

    calc_checksum = Fletcher16(tempDecMsg);

    if(!validate_checksum(msg_checksum, calc_checksum))
    {
        decMsg = default(seq[int]);
        decMsg += (0, -1);
        return decMsg;
    }
    announce eSpec_ChecksumPassed;
    return decMsg;
}

fun handle_error(flag: error)
{
    if(flag == checksum_error)
    {
        print format("ERROR: Checksum error detected.");
        announce eSpec_ChecksumFailed;
    }
    else if(flag == ack_error)
    {
        print format("ERROR: Command acknowledge error detected.");
    }
    else if(flag == encryption_error)
    {
        print format("ERROR: Mavlink encryption error detected.");
    }
    else if(flag == transition_error)
    {
        print format("ERROR: State transition error detected.");
    }
    else if(flag == health_error)
    {
        print format("ERROR: System health error detected.");
        raise halt;
    }
    else if(flag == connection_error)
    {
        print format("ERROR: System connection error detected.");
        raise halt;
    }
    else
    {
        print format("ERROR: Unknown error detected.");
        raise halt;
    }
}