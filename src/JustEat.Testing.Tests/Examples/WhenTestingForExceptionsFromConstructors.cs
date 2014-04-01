using System;
using Shouldly;

namespace JustEat.Testing.Tests.Examples
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

        [Then]
        public void ShouldSeeException()
        {
            ThrownException.ShouldBeTypeOf<NotSupportedException>();
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
