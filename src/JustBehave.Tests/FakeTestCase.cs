using System;

namespace JustBehave.Tests
{
    public class FakeTestCase : BehaviourTestBase<object>
    {
        private readonly Action _onWhen;

        public bool GivenExecuted { get; private set; }
        public bool WhenExecuted { get; private set; }
        public bool TearDownExecuted { get; private set; }

        public FakeTestCase(Action onWhen = null)
        {
            _onWhen = onWhen ?? (()=>{});
        }

        public new void Execute()
        {
            base.Execute();
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
        
        protected override void When()
        {
            WhenExecuted = true;
            _onWhen();
        }

        protected override void Teardown()
        {
            TearDownExecuted = true;
        }
    }
}