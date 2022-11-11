machine Drone
{
    var qgc: QGC;
    var ardu: Ardupilot;
    start state Init 
    {
        entry 
        {
            qgc = new QGC(ardu);
            ardu = new Ardupilot(qgc);
        }
    }
}