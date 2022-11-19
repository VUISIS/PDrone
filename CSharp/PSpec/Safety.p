event eSpec_ChecksumPassed;
event eSpec_ChecksumFailed;

spec MavlinkChecksum observes eSpec_ChecksumPassed, eSpec_ChecksumFailed
{
    var failure_count: int;
    start state Secure 
    {
        on eSpec_ChecksumFailed goto Failing with
        {
            failure_count = failure_count + 1;
            assert failure_count <  25,
                format ("Exceeded checksum failure rate: {0}", failure_count);
        }
        on eSpec_ChecksumPassed goto Secure;
    }

    hot state Failing
    {
        on eSpec_ChecksumPassed goto Secure;
        on eSpec_ChecksumFailed goto Failing;
    }
}