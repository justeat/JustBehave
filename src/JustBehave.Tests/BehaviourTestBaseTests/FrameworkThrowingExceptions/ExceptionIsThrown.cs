using System;
using NUnit.Framework;

namespace JustBehave.Tests.BehaviourTestBaseTests.FrameworkThrowingExceptions
{
    [TestFixture]
    public class ExceptionIsThrown
    {
        private FakeTestCase _fakeTest;

        [SetUp]
        public void SetUp()
        {
            _fakeTest = new FakeTestCase(() => { throw new Exception("Something bad happened"); });
        }

        [Test]
        public void ExceptionNotHandled()
        {
            var ex = Assert.Throws<Exception>(() => _fakeTest.Execute());

            Assert.That(ex.Message, Is.EqualTo("Something bad happened"));
        }
    }
}