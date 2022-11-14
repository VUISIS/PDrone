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

            int key = 'X' - '0';

            foreach(PrtInt item in vals)
            {
                int enc = (int)item ^ key;

                crypt.Add((PrtInt)enc);
            }

            return crypt;
        }
        
        public static void Sleep(PrtInt val, PMachine machine)
        {
            Thread.Sleep(val);
        }
    }
}