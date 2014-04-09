using NUnit.Framework;

namespace JustBehave.Tests.BehaviourTestBaseTests
{
    [TestFixture]
    public class WhenExecuteIsInvokedByTestRunner
    {
        private FakeTestCase _fakeTest;

        [SetUp]
        public void SetUp()
        {
            _fakeTest = new FakeTestCase();
            _fakeTest.Execute();
        }

        [Test]
        public void GivenIsCalled()
        {
            Assert.That(_fakeTest.GivenExecuted, Is.True);
        }

        [Test]
        public void WhenIsCalled()
        {
            Assert.That(_fakeTest.WhenExecuted, Is.True);
        }

        [Test]
        public void TeardownIsCalled()
        {
            Assert.That(_fakeTest.TearDownExecuted, Is.True);
        }
    }
}
