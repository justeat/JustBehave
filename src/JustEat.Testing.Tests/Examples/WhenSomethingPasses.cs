using Shouldly;

namespace JustEat.Testing.Tests.Examples
{
    public class WhenSomethingPasses : XBehaviourTest<HappyThing>
    {
        private string _result;

        protected override void Given()
        {
            _result = "food";
        }

        protected override void When()
        {
            _result = SystemUnderTest.ToString();
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

    public class HappyThing {}
}
