using System;
using System.Threading.Tasks;
using NUnit.Framework;
using Shouldly;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class WhenTestingForExceptions : AsyncBehaviourTest<BadlyBehaved>
    {
        protected override void Given()
        {
            RecordAnyExceptionsThrown();
        }

        protected override async Task When()
        {
            await BadlyBehaved.TakeADump();
        }

        [Then, Test]
        public void ExceptionShouldBeOfExpectedType()
        {
            ThrownException.ShouldBeAssignableTo<InvalidOperationException>();
        }
    }

// ReSharper disable once ClassNeverInstantiated.Global
    public class BadlyBehaved
    {
        public static Task TakeADump()
        {
            throw new InvalidOperationException();
        }
    }
}
