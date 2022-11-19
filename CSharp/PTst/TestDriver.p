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

machine UnstableDrone
{
    var uart: UnstableUART;
    start state Init 
    {
        entry 
        {
            uart = new UnstableUART();
        }
    }
}