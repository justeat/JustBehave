using System;
using System.Diagnostics.CodeAnalysis;
using NLog;
using NLog.Config;
using NLog.Layouts;
using NLog.Targets;
using Ploeh.AutoFixture;

namespace JustEat.Testing
{
    public abstract class BehaviourTestBase<TSystemUnderTest>
    {
        protected Fixture Fixture { get; private set; }
        protected ExceptionMode ExceptionMode { get; private set; }
        protected TSystemUnderTest SystemUnderTest { get; private set; }
        protected Logger Log { get; private set; }
        protected Exception ThrownException { get; private set; }
        protected LogLevel LogLevel { get; private set; }
        protected TargetWithLayout LoggingTarget { get; private set; }

        protected BehaviourTestBase()
        {
            ExceptionMode = ExceptionMode.Throw;
            LoggingTarget = ConfigureLoggingTarget();
            LogLevel = ConfigureLogLevel();
            SimpleConfigurator.ConfigureForTargetLogging(LoggingTarget, LogLevel);
            Log = LogManager.GetCurrentClassLogger();

            Fixture = new Fixture();
            CustomizeAutoFixture(Fixture);
        }

        protected virtual TargetWithLayout ConfigureLoggingTarget()
        {
            return new ColoredConsoleTarget {Layout = LogLayout()};
        }

        protected virtual Layout LogLayout()
        {
            return "${message}";
        }

        protected virtual LogLevel ConfigureLogLevel()
        {
            return LogLevel.Warn;
        }

        protected virtual void CustomizeAutoFixture(Fixture fixture) {}
        
        protected abstract void Given();

        [SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", Justification = "When really is the best name for this message")]
        protected abstract void When();

        protected virtual void Teardown() {}

        protected virtual TSystemUnderTest CreateSystemUnderTest()
        {
            return Fixture.Create<TSystemUnderTest>();
        }

        protected void RecordAnyExceptionsThrown()
        {
            ExceptionMode = ExceptionMode.Record;
        }

        protected void Execute()
        {
            Given();

            try
            {
                SystemUnderTest = CreateSystemUnderTest();
                When();
            }
            catch (Exception ex)
            {
                if (ExceptionMode == ExceptionMode.Record)
                {
                    ThrownException = ex;
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                Teardown();
            }
        }

        protected virtual void PostAssertTeardown() {}
    }
}
