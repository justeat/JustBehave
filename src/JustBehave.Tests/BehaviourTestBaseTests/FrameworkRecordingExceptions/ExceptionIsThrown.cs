using System;
using NUnit.Framework;

namespace JustBehave.Tests.BehaviourTestBaseTests.FrameworkRecordingExceptions
{
    [TestFixture]
    public class ExceptionIsThrown
    {
        private FakeTestCase _fakeTest;
        private Exception _exception;

        [SetUp]
        public void SetUp()
        {
            _exception = new Exception("Something bad happened");
            _fakeTest = new FakeTestCase(() => { throw _exception; });
            _fakeTest.RecordAnyExceptionsThrown();
        }

        [Test]
        public void ExceptionCapturedAsThrownException()
        {
            _fakeTest.Execute();

            Assert.That(_fakeTest.ThrownException, Is.EqualTo(_exception));
        }
    }
}