type tHBPayload = (mtype: mav_type, mautopilot: mav_autopilot, mmode: mav_mode, mstate: mav_state);
type tCLPayload = (mcmd: mav_cmd, params: seq[int]);
type tCAPayload = (mcmd: mav_cmd, mresult: mav_result);

event eUARTLink: (sys: system, msg: seq[int]);
event eMavlinkMessage: seq[int];
event eInvalidMessage: string;

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

fun send_heartbeat(uart: UART, sys: system, hbpayload: tHBPayload)
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

fun send_system_status(uart: UART, sys: system)
{
    var sys_status_message: seq[int];

    sys_status_message += (0, msg_sys_status to int);
    sys_status_message += (1, healthy to int);
    sys_status_message += (2, 25);
    sys_status_message += (3, 100);
    sys_status_message += (4, Fletcher16(sys_status_message));

    encrypt_send_message(uart, sys, sys_status_message);
}

fun send_command_long(uart: UART, sys: system, clpayload: tCLPayload)
{
    var command_long_message: seq[int];
    var idx: int;
    var p_idx: int;
    idx = 2;
    p_idx = 0;

    command_long_message += (0, msg_command_long to int);
    command_long_message += (1, clpayload.mcmd to int);
    while(idx < sizeof(clpayload.params) + 2)
    {
        command_long_message += (idx, clpayload.params[p_idx]);
        idx = idx + 1;
    }
    command_long_message += (idx, Fletcher16(command_long_message));

    encrypt_send_message(uart, sys, command_long_message);
}

fun send_command_ack(uart: UART, sys: system, capayload: tCAPayload)
{
    var command_ack_message: seq[int];

    command_ack_message += (0, msg_command_ack to int);
    command_ack_message += (1, capayload.mcmd to int);
    command_ack_message += (2, capayload.mresult to int);

    encrypt_send_message(uart, sys, command_ack_message);
}

fun encrypt_send_message(uart: UART, sys: system, msg: seq[int])
{
    var encMsg: seq[int];
    encMsg = XORCrypto(msg);
    send uart, eUARTLink, (sys = sys, msg = encMsg);
}

fun decrypt_message(msg: seq[int]): seq[int]
{
    return XORCrypto(msg);
}

fun validate_checksum(msg_checksum: int, calc_checksum: int)
{
    if(msg_checksum != calc_checksum)
    {
        raise eInvalidMessage, "Invalid message checksum!";
    }
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

    validate_checksum(msg_checksum, calc_checksum);

    return decMsg;
}