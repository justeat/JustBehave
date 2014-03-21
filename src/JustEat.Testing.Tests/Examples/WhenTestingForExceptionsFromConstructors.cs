using System;
using Shouldly;
using Xunit;

namespace JustEat.Testing.Tests.Examples
{
    public class WhenTestingForExceptionsFromConstructors : XBehaviourTest<BadlyBehavedConstructor>
    {
        [Then]
        public void ShouldSeeException()
        {
            ThrownException.ShouldBeTypeOf<NotSupportedException>();
        }

        protected override BadlyBehavedConstructor CreateSystemUnderTest()
        {
            return new BadlyBehavedConstructor();
        }

        protected override void Given()
        {
            RecordAnyExceptionsThrown();
        }

        protected override void When() {}
    }

    public class BadlyBehavedConstructor
    {
        public BadlyBehavedConstructor()
        {
            throw new NotSupportedException();
        }
    }
}
