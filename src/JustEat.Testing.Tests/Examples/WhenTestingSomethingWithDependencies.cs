using Ploeh.AutoFixture;
using Ploeh.AutoFixture.AutoRhinoMock;
using Rhino.Mocks;
using Shouldly;
using Xunit;

namespace JustEat.Testing.Tests.Examples
{
    public class WhenTestingSomethingWithDependencies : XBehaviourTest<Something>
    {
        private ISomethingElse _fake;
        private string _result;
        private string _speech;

        protected override void Given()
        {
            _result = "bar";
            _fake = Fixture.Freeze<ISomethingElse>();
            _fake.Expect(x => x.SayHi()).Return("hi");
        }

        protected override void When()
        {
            _result = SystemUnderTest.Food();
            _speech = SystemUnderTest.SomethingElse.SayHi();
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

        [Fact]
        public void ShouldBeAbleToReturnSameInstanceOfDependency()
        {
            var expected = Fixture.Create<ISomethingElse>().ToString();
            var actual = SystemUnderTest.SomethingElse.ToString();
            actual.ShouldBe(expected);
        }

        [Fact]
        public void ShouldBeAbleToRunExpectationAndVerify()
        {
            _speech.ShouldBe("hi");
            _fake.VerifyAllExpectations();
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

    public interface ISomethingElse
    {
        string SayHi();
    }
}
