using System;
using System.Threading.Tasks;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class FakeAsyncTestCase : AsyncBehaviourTestBase<object>
    {
        private readonly Task _onWhen;

        public bool GivenExecuted { get; private set; }
        public bool WhenExecuted { get; private set; }
        public bool TearDownExecuted { get; private set; }

        public FakeAsyncTestCase(Task onWhen = null)
        {
            _onWhen = onWhen ?? Task.Run(() => { });
        }

        public new async Task Execute()
        {
            await base.Execute();
        }

        public new void RecordAnyExceptionsThrown()
        {
            base.RecordAnyExceptionsThrown();
        }

        public new Exception ThrownException
        {
            get { return base.ThrownException; }
        }

        protected override void Given()
        {
            GivenExecuted = true;
        }

        protected override async Task When()
        {
            WhenExecuted = true;
            await _onWhen;
        }

        protected override void Teardown()
        {
            TearDownExecuted = true;
        }
    }
}
