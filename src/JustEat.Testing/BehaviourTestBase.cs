using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using NLog;
using NLog.Config;
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
        
        protected BehaviourTestBase()
        {
            ExceptionMode = ExceptionMode.Throw;
#if DEBUG
            var level = LogLevel.Trace;
#else
			var level = LogLevel.Warn;
#endif
            SimpleConfigurator.ConfigureForTargetLogging(new ColoredConsoleTarget {Layout = "${message}"}, level);
            Log = LogManager.GetCurrentClassLogger();

            Fixture = new Fixture();
            CustomizeAutoFixture(Fixture);
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

        [DebuggerNonUserCode]
        protected void Setup()
        {
            Given();

            SystemUnderTest = CreateSystemUnderTest();

            try
            {
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

        public virtual void PostAssertTeardown() {}
    }
}
