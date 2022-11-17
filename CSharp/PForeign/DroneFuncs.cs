using System;
using System.Threading;
using System.Timers;
using Plang.CSharpRuntime;
using Plang.CSharpRuntime.Values;

namespace PImplementation
{   
    public static partial class GlobalFunctions
    {
        public static PrtSeq XORCrypto(PrtSeq vals, PMachine machine)
        {
            PrtSeq crypt = new PrtSeq();

            char key = 'X';

            foreach(PrtInt val in vals)
            {
                char v = Convert.ToChar((int)val);

                crypt.Add((PrtInt)Convert.ToInt32(v ^ key));
            }

            return crypt;
        }

        public static PrtInt Fletcher16(PrtSeq vals, PMachine machine)
        {
            int sum1 = 0;
            int sum2 = 0;
            
            foreach(PrtInt val in vals)
            {
                sum1 = (sum1 + val) % 255;
                sum2 = (sum2 + sum1) % 255;
            }

            return (PrtInt)((sum2 << 8) | sum1);
        }
        
        public static void Sleep(PrtInt val, PMachine machine)
        {
            Thread.Sleep(val);
        }
    }
}