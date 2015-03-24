using NUnit.Framework;

namespace JustBehave
{
    [TestFixture]
    public abstract class AsyncBehaviourTest<TSystemUnderTest> : AsyncBehaviourTestBase<TSystemUnderTest>
    {
        [TestFixtureSetUp]
        public void Go()
        {
            AsyncExtensions.RunSynchronously(Execute);
        }

        [TestFixtureTearDown]
        public new virtual void PostAssertTeardown() { }
    }
}