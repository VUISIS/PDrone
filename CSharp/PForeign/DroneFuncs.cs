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

            int key = Convert.ToInt('X');

            foreach(int item in vals)
            {
                int out = item ^ key;

                crypt.Insert(out);
            }

            return crypt;
        }
        
        public static void Sleep(PrtInt val, PMachine machine)
        {
            Thread.Sleep(val);
        }
    }
}