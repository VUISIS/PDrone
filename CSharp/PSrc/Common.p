event eUARTLink: (sys: System, msg: seq[int]);
event eMavlinkMessage: seq[int];
event eInvalidMessage: string;

enum System
{
    Ardupilot = 0,
    QGC = 1
}

fun send_heartbeat(uart: UART, system: System)
{
    var heartbeat_message: seq[int];

    heartbeat_message += (0, msg_heartbeat to int);
    heartbeat_message += (1, 1);
    heartbeat_message += (2, Fletcher16(heartbeat_message));

    encrypt_send_message(uart, system, heartbeat_message);
}

fun encrypt_send_message(uart: UART, system: System, msg: seq[int])
{
    var encMsg: seq[int];
    encMsg = XORCrypto(msg);
    send uart, eUARTLink, (sys = system, msg = encMsg);
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