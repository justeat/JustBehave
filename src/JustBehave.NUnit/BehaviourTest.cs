using NUnit.Framework;

namespace JustBehave
{
    /// <summary>
    ///     NUnit based BehaviourTest.  Name kept for backwards compatibility
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    [TestFixture]
    public abstract class BehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>
    {
        [OneTimeSetUp]
        public void Go()
        {
            Execute();
        }

        [OneTimeTearDown]
        public new virtual void PostAssertTeardown() {}
    }
}
