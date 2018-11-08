using System;
using System.Threading.Tasks;
using Xunit;

namespace JustBehave
{
    /// <summary>
    ///     XUnit-based BehaviourTest.
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    public abstract class XAsyncBehaviourTest<TSystemUnderTest> : AsyncBehaviourTestBase<TSystemUnderTest>, IAsyncLifetime
    {
        public virtual Task InitializeAsync() => Execute();

        public virtual Task DisposeAsync() => PostAssertTeardownAsync();
    }
}
