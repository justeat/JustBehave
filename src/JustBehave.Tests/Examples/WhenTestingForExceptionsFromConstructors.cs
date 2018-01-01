using System;
using Shouldly;
using Xunit;

namespace JustBehave.Tests.Examples
{
    public class WhenTestingForExceptionsFromConstructors : XBehaviourTest<BadlyBehavedConstructor>
    {
        protected override BadlyBehavedConstructor CreateSystemUnderTest()
        {
            return new BadlyBehavedConstructor();
        }

        protected override void Given()
        {
            RecordAnyExceptionsThrown();
        }

        protected override void When() { }

        [Fact]
        public void ShouldSeeException()
        {
            ThrownException.ShouldBeAssignableTo<NotSupportedException>();
        }
    }

    public class BadlyBehavedConstructor
    {
        public BadlyBehavedConstructor()
        {
            throw new NotSupportedException();
        }
    }
}
