fun encrypt_send_message(target: machine, msg: seq[int])
{
    var encMsg: seq[int];
    encMsg = XORCrypto(msg);
    send target, eMavlinkMessage, encMsg;
}

fun decrypt_message(msg: seq[int]): seq[int]
{
    return XORCrypto(msg);
}