using System;
using System.Diagnostics;
using System.Threading;

namespace DDI.Tests.TestHelpers
{
    public class WaitHelper
    {
        public static bool WaitFor(Func<bool> function, long timeOutMilliseconds = 5000, int sleepMilliseconds = 1000)
        {
            var clock = new Stopwatch();
            clock.Start();
            do
            {
                if (function())
                {
                    clock.Stop();
                    return true;
                }

                Thread.Sleep(sleepMilliseconds);
            }
            while (clock.ElapsedMilliseconds < timeOutMilliseconds);
            clock.Stop();
            return false;
        }
    }
}