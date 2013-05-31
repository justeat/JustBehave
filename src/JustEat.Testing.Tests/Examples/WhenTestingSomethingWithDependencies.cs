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
            _result = SystemUnderTest.Foo();
        }

        [Fact]
        public void ShouldReadFoo()
        {
            _result.ShouldBe("foo");
        }
    }

    public class Something
    {
        private readonly ISomethingElse _somethingElse;

        public Something(ISomethingElse somethingElse)
        {
            _somethingElse = somethingElse;
        }

        public string Foo()
        {
            return "foo";
        }
    }

    public interface ISomethingElse { }
}
