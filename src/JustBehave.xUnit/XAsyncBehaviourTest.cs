using System;

namespace JustBehave.xUnit
{
    /// <summary>
    ///     XUnit-based BehaviourTest.
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    public abstract class XAsyncBehaviourTest<TSystemUnderTest> : AsyncBehaviourTestBase<TSystemUnderTest>, IDisposable
    {
        protected XAsyncBehaviourTest()
        {
            AsyncExtensions.RunSynchronously(async() => await Execute());
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
