using System;

namespace JustBehave.xUnit
{
    /// <summary>
    ///     XUnit-based BehaviourTest.
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    public abstract class XBehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>, IDisposable
    {
        protected XBehaviourTest()
        {
            Execute();
        }

        public void Dispose()
        {
            PostAssertTeardown();
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {

        }
    }
}
