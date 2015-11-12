using Ploeh.AutoFixture;
using Ploeh.AutoFixture.AutoRhinoMock;
using Rhino.Mocks;
using Shouldly;

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
            _fake.Expect(x => x.SayHello()).Return("hi");
        }

        protected override void When()
        {
            _result = SomethingUnderTest.Food();
            _speech = SystemUnderTest.SomethingElse.SayHello();
        }

        protected override void CustomizeAutoFixture(IFixture fixture)
        {
            fixture.Customize(new AutoRhinoMockCustomization());
        }

        [Then]
        public void ShouldReadFood()
        {
            _result.ShouldBe("food");
        }

        [Then]
        public void ShouldSupplyDependency()
        {
            SystemUnderTest.SomethingElse.ShouldNotBe(null);
        }

        [Then]
        public void ShouldBeAbleToReturnSameInstanceOfDependency()
        {
            var expected = Fixture.Create<ISomethingElse>().ToString();
            var actual = SystemUnderTest.SomethingElse.ToString();
            actual.ShouldBe(expected);
        }

        [Then]
        public void ShouldBeAbleToRunExpectationAndVerify()
        {
            _speech.ShouldBe("hi");
            _fake.VerifyAllExpectations();
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
