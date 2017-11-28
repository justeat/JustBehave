using AutoFixture;
using AutoFixture.AutoNSubstitute;
using NSubstitute;
using Shouldly;
using Xunit;

namespace JustBehave.Tests.Examples
{
    public class WhenTestingSomethingWithDependencies : XBehaviourTest<SomethingUnderTest>
    {
        private ISomethingElse _fake;
        private string _result;
        private string _speech;

        protected override void Given()
        {
            _result = "bar";
            _fake = Fixture.Freeze<ISomethingElse>();
            _fake.SayHello().Returns("hi");
        }

        protected override void When()
        {
            _result = SomethingUnderTest.Food();
            _speech = SystemUnderTest.SomethingElse.SayHello();
        }

        protected override void CustomizeAutoFixture(IFixture fixture)
        {
            fixture.Customize(new AutoConfiguredNSubstituteCustomization());
        }

        [Fact]
        public void ShouldReadFood()
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
        }
    }

    public class SomethingUnderTest
    {
        private readonly ISomethingElse _somethingElse;

        public SomethingUnderTest(ISomethingElse somethingElse)
        {
            _somethingElse = somethingElse;
        }

        public ISomethingElse SomethingElse
        {
            get { return _somethingElse; }
        }

        public static string Food()
        {
            return "food";
        }
    }

    public interface ISomethingElse
    {
        string SayHello();
    }
}
