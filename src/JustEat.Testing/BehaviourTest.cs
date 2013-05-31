using NUnit.Framework;

namespace JustEat.Testing
{
    /// <summary>
    /// NUnit based BehaviourTest.  Name kept for backwards compatibility
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
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
