using System;
using System.Threading;
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
        
        public static void Sleep(PrtInt val, PMachine machine)
        {
            Thread.Sleep(val);
        }
    }
}