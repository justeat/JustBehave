using System.Threading.Tasks;
using NUnit.Framework;

namespace JustBehave
{
    [TestFixture]
    public abstract class AsyncBehaviourTest<TSystemUnderTest> : AsyncBehaviourTestBase<TSystemUnderTest>
    {
        [OneTimeSetUp]
        public Task Go() => Execute();

        [OneTimeTearDown]
        public virtual Task TeardownAsync() => PostAssertTeardownAsync();
    }
}
