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
        // ReSharper disable InconsistentNaming
        protected readonly Fixture Fixture;
        protected ExceptionMode ExceptionMode = ExceptionMode.Throw;

        protected BehaviourTestBase()
        {
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

        protected virtual void CustomizeAutoFixture(Fixture fixture)
        {
            
        }

        protected TSystemUnderTest SystemUnderTest { get; private set; }

        protected Logger Log { get; set; }
        protected Exception ThrownException { get; set; }
        protected abstract void Given();

        [SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", Justification = "When really is the best name for this message")]
        protected abstract void When();

        protected virtual void Teardown() {}

        /// <summary>
        ///     Override this if TSystemUnderTest doesn't have a parameterless constructor.
        /// </summary>
        protected virtual TSystemUnderTest CreateSystemUnderTest()
        {
            return Fixture.Create<TSystemUnderTest>();
        }

        protected void RecordAnyExceptionsThrown()
        {
            ExceptionMode = ExceptionMode.Record;
        }

        protected TMock Mock<TMock>() where TMock : class
        {
            return Fixture.Create<TMock>();
        }

        [DebuggerStepThrough]
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