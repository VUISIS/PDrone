machine Drone
{
    var uart: UART;
    start state Init 
    {
        entry 
        {
            uart = new UART();
        }
    }
}