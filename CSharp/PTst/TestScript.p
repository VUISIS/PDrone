test CheckArdupilotState [main = Drone] : 
        assert ArdupilotOperation in union { Drone }, QGC, Ardupilot, UART, Timer;