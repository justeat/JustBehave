using System.Linq;
using System.Threading;
using NLog;
using NLog.Layouts;
using NLog.Targets;
using Shouldly;
using Xunit;

namespace JustBehave.Tests.Examples
{
    public class WhenAssertingAgainstLogs : XBehaviourTest<LoggerUnderTest>
    {
        private string _message;

        protected override void Given()
        {
            _message = "some message";
        }

        protected override void When()
        {
            SystemUnderTest.Log.Debug(_message);
            // TODO something wierd is happening here and the tests fail randomly
        }

        [Fact]
        public void ShouldBeAbleToAssertLogHappened()
        {
            ((MemoryTarget) LoggingTarget).Logs.SingleOrDefault(x => x.Equals(_message)).ShouldNotBe(null);
        }

        [Fact]
        public void ShouldBeAbleToUsePredicateExtensionMethod()
        {
            LoggingTarget.ShouldHaveLogged(x => x == _message);
        }

        [Fact]
        public void ShouldBeAbleToUseStringExtensionMethod()
        {
            LoggingTarget.ShouldHaveLogged(_message);
        }

        protected override LogLevel ConfigureLogLevel()
        {
            return LogLevel.Trace;
        }

        protected override TargetWithLayout ConfigureLoggingTarget()
        {
            return new MemoryTarget { Layout = LogLayout()};
        }

        protected override LoggerUnderTest CreateSystemUnderTest()
        {
            return new LoggerUnderTest {Log = Log};
        }

        protected override Layout LogLayout()
        {
            return "${message}";
        }
    }

    public class LoggerUnderTest
    {
        public Logger Log { get; set; }
    }
}
