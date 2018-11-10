using System.Threading.Tasks;
using Shouldly;
using Xunit;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class WhenAnXUnitTestPasses : XAsyncBehaviourTest<XHappyThing>
    {
        private string _result;

        protected override Task Given()
        {
            _result = "food";
            return Task.CompletedTask;
        }

        protected override async Task When()
        {
            _result = await SystemUnderTest.AlwaysHappy();
        }

        [Fact]
        public void ShouldHaveString()
        {
            _result.ShouldNotBe(null);
        }

        [Fact]
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
