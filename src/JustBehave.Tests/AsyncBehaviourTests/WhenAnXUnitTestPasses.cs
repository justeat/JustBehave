using System.Threading.Tasks;
using JustBehave.xUnit;
using Shouldly;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class WhenAnXUnitTestPasses : XAsyncBehaviourTest<XHappyThing>
    {
        private string _result;

        protected override void Given()
        {
            _result = "food";
        }

        protected override async Task When()
        {
            _result = await SystemUnderTest.AlwaysHappy();
        }

        [Then]
        public void ShouldHaveString()
        {
            _result.ShouldNotBe(null);
        }

        [Then]
        public void ShouldHaveChangedFromInitial()
        {
            _result.ShouldNotBe("food");
        }
    }

// ReSharper disable once ClassNeverInstantiated.Global
    public class XHappyThing
    {
        public Task<string> AlwaysHappy()
        {
            return Task.Run(() => ToString());
        }
    }
}
