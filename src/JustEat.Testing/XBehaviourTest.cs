using System;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using NLog;
using NLog.Config;
using NLog.Targets;

namespace JustEat.Testing
{
    public abstract class XBehaviourTest<TSystemUnderTest> : IDisposable
    {
        private ExceptionMode _exceptionMode = ExceptionMode.Throw;
        private MockManager _mockManager;
        private AutoMocker<TSystemUnderTest> _autoMocker;
        protected Logger Log { get; set; }

        protected XBehaviourTest()
        {
#if DEBUG
            var level = LogLevel.Trace;
#else
			var level = LogLevel.Warn;
#endif
            SimpleConfigurator.ConfigureForTargetLogging(new ColoredConsoleTarget {Layout = "${message}"}, level);
            Log = LogManager.GetCurrentClassLogger();

            Setup();
        }

        protected Exception ThrownException { get; private set; }

        protected TSystemUnderTest SUT { get; private set; }

        [DebuggerStepThrough]
        private void Setup()
        {
            _mockManager = new MockManager();
            _autoMocker = new AutoMocker<TSystemUnderTest>(_mockManager);

            Given();

            SUT = CreateSystemUnderTest();

            try
            {
                When();
            }
            catch (Exception ex)
            {
                if (_exceptionMode == ExceptionMode.Record)
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

        protected abstract void Given();

        [SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", Justification = "When really is the best name for this message")]
        protected abstract void When();

        protected virtual void Teardown() {}

        /// <summary>
        /// Override this if TSystemUnderTest doesn't have a parameterless constructor.
        /// </summary>
        protected virtual TSystemUnderTest CreateSystemUnderTest()
        {
            return _autoMocker.ConstructedObject();
            //return Activator.CreateInstance<TSystemUnderTest>();
        }

        protected void RecordAnyExceptionsThrown()
        {
            _exceptionMode = ExceptionMode.Record;
        }

        protected TMock Mock<TMock>() where TMock : class
        {
            return _mockManager.Mock<TMock>();
        }

        #region Nested type: ExceptionMode

        private enum ExceptionMode
        {
            Throw,
            Record
        }

        #endregion    }

        public void Dispose()
        {
            PostAssertTeardown();
        }
    }
}