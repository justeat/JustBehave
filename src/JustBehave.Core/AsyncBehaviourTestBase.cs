using System;
using System.Diagnostics.CodeAnalysis;
using System.Threading.Tasks;
using AutoFixture;
using NLog;
using NLog.Config;
using NLog.Layouts;
using NLog.Targets;

namespace JustBehave
{
    public abstract class AsyncBehaviourTestBase<TSystemUnderTest>
    {
        // ReSharper disable DoNotCallOverridableMethodsInConstructor
        protected AsyncBehaviourTestBase()
        {
            ExceptionMode = ExceptionMode.Throw;
            LoggingTarget = ConfigureLoggingTarget();
            LogLevel = ConfigureLogLevel();
            SimpleConfigurator.ConfigureForTargetLogging(LoggingTarget, LogLevel);
            Log = LogManager.GetCurrentClassLogger();

            Fixture = new Fixture();
            CustomizeAutoFixture(Fixture);
        }
        // ReSharper restore DoNotCallOverridableMethodsInConstructor

// ReSharper disable MemberCanBePrivate.Global
        protected IFixture Fixture { get; private set; }
        protected Logger Log { get; private set; }
        protected TargetWithLayout LoggingTarget { get; private set; }
// ReSharper restore MemberCanBePrivate.Global
        protected TSystemUnderTest SystemUnderTest { get; private set; }
        protected Exception ThrownException { get; private set; }
        private ExceptionMode ExceptionMode { get; set; }
        private LogLevel LogLevel { get; set; }

        protected virtual LogLevel ConfigureLogLevel()
        {
            return LogLevel.Warn;
        }

        protected virtual TargetWithLayout ConfigureLoggingTarget()
        {
            return new ColoredConsoleTarget { Layout = LogLayout() };
        }

        protected virtual TSystemUnderTest CreateSystemUnderTest()
        {
            return Fixture.Create<TSystemUnderTest>();
        }

        protected virtual void CustomizeAutoFixture(IFixture fixture) { }

        protected async Task Execute()
        {
            Given();

            try
            {
                SystemUnderTest = CreateSystemUnderTest();
                await When();
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

        protected abstract void Given();

        protected virtual Layout LogLayout()
        {
            return "${message}";
        }

        protected virtual void PostAssertTeardown() { }

        protected void RecordAnyExceptionsThrown()
        {
            ExceptionMode = ExceptionMode.Record;
        }

        protected virtual void Teardown() { }

        [SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", Justification = "When really is the best name for this message")]
        protected abstract Task When();
    }
}
