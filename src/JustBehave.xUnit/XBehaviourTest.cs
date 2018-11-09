using System;

namespace JustBehave
{
    /// <summary>
    ///     XUnit-based BehaviourTest.
    /// </summary>
    /// <typeparam name="TSystemUnderTest"></typeparam>
    public abstract class XBehaviourTest<TSystemUnderTest> : BehaviourTestBase<TSystemUnderTest>
    {
        protected XBehaviourTest() => Execute();
    }
}
