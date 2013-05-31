using System;

namespace JustEat.Testing
{
    public enum ExceptionMode
    {
        Throw,
        Record
    }

    public abstract class XBehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>, IDisposable
    {
        protected XBehaviourTest()
        {
            Setup();
        }

        public void Dispose()
        {
            PostAssertTeardown();
        }
    }
}
