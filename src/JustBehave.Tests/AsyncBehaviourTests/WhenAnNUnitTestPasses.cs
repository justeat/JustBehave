using System.Threading.Tasks;
using NUnit.Framework;
using Shouldly;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class WhenAnNunitTestPasses : AsyncBehaviourTest<NHappyThing>
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

        [Then,Test]
        public void ShouldHaveString()
        {
            _result.ShouldNotBe(null);
        }

        [Then,Test]
        public void ShouldHaveChangedFromInitial()
        {
            _result.ShouldNotBe("food");
        }
    }

// ReSharper disable once ClassNeverInstantiated.Global
    public class NHappyThing
    {
        public Task<string> AlwaysHappy()
        {
            return Task.Run(() => ToString());
        }
    }
}
