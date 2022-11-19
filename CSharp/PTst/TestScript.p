test ValidateNetwork [main = Drone] : 
        assert MavlinkChecksum in union { Drone }, Network;

test FaultyNetwork [main = UnstableDrone] : 
        assert MavlinkChecksum in union { UnstableDrone }, UnstableNetwork;