using System;

namespace JustEat.Testing
{
    /// <summary>
    ///     XUnit-based BehaviourTest.
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
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
