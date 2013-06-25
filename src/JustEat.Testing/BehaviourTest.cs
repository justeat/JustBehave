using NUnit.Framework;

namespace JustEat.Testing
{
    /// <summary>
    ///     NUnit based BehaviourTest.  Name kept for backwards compatibility
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    [TestFixture]
    public abstract class BehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>
    {
        [TestFixtureSetUp]
        public void Go()
        {
            Execute();
        }

        [TestFixtureTearDown]
        public new virtual void PostAssertTeardown() {}
    }
}
