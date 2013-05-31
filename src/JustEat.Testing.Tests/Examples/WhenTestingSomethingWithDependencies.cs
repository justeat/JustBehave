using Ploeh.AutoFixture;
using Ploeh.AutoFixture.AutoRhinoMock;
using Shouldly;
using Xunit;

namespace JustEat.Testing.Tests.Examples
{
    public class WhenTestingSomethingWithDependencies : XBehaviourTest<Something>
    {
        private string _result;

        protected override void Given()
        {
            _result = "bar";
        }

        protected override void When()
        {
            _result = SystemUnderTest.Food();
        }

        protected override void CustomizeAutoFixture(Fixture fixture)
        {
            fixture.Customize(new AutoRhinoMockCustomization());
        }

        [Fact]
        public void ShouldReadFoo()
        {
            _result.ShouldBe("food");
        }

        [Fact]
        public void ShouldSupplyDependency()
        {
            SystemUnderTest.SomethingElse.ShouldNotBe(null);
        }
    }

    public class Something
    {
        private readonly ISomethingElse _somethingElse;

        public Something(ISomethingElse somethingElse)
        {
            _somethingElse = somethingElse;
        }

        public ISomethingElse SomethingElse
        {
            get { return _somethingElse; }
        }

        public string Food()
        {
            return "food";
        }
    }

    public interface ISomethingElse { }
}
