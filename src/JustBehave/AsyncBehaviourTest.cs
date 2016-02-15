using NUnit.Framework;

namespace JustBehave
{
    [TestFixture]
    public abstract class AsyncBehaviourTest<TSystemUnderTest> : AsyncBehaviourTestBase<TSystemUnderTest>
    {
        [OneTimeSetUp]
        public void Go()
        {
            AsyncExtensions.RunSynchronously(Execute);
        }

        [OneTimeTearDown]
        public new virtual void PostAssertTeardown() { }
    }
}