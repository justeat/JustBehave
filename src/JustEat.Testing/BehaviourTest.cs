using NUnit.Framework;

namespace JustEat.Testing
{
    public abstract class BehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>
    {
        [TestFixtureSetUp]
        public void Go()
        {
            Setup();
        }

        [TestFixtureTearDown]
        public new virtual void PostAssertTeardown() {}
    }
}
