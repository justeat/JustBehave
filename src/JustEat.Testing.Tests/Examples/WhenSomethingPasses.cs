﻿using Shouldly;
using Xunit;

namespace JustEat.Testing.Tests.Examples
{
    public class WhenSomethingPasses : XBehaviourTest<HappyThing>
    {
        private string _result;

        protected override void Given()
        {
            _result = "food";
        }

        protected override void When()
        {
            _result = SystemUnderTest.ToString();
        }

        [Fact]
        public void ShouldHaveString()
        {
            _result.ShouldNotBe(null);
        }

        [Fact]
        public void ShouldHaveChangedFromInitial()
        {
            _result.ShouldNotBe("food");
        }
    }

    public class HappyThing {}
}