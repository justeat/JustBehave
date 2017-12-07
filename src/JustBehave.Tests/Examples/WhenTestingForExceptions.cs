using System;
using JustBehave.NUnit;
using Shouldly;

namespace JustBehave.Tests.Examples
{
    public class WhenTestingForExceptions : BehaviourTest<BadlyBehaved>
    {
        protected override void Given()
        {
            RecordAnyExceptionsThrown();
        }

        protected override void When()
        {
            BadlyBehaved.TakeADump();
        }

        [Then]
        public void ExceptionShouldBeOfExpectedType()
        {
            ThrownException.ShouldBeAssignableTo<InvalidOperationException>();
        }
    }

// ReSharper disable once ClassNeverInstantiated.Global
    public class BadlyBehaved
    {
        public static void TakeADump()
        {
            throw new InvalidOperationException();
        }
    }
}
