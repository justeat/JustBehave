using System;
using Shouldly;
using NUnit.Framework;
using Xunit;

namespace JustEat.Testing.Tests
{
	[TestFixture]
	public class WhenMocking
	{
		[Test]
		public void ShouldAddToDictionary()
		{
			var mm = new MockManager();
			var mock = mm.Mock<IAmARandomThing>();
			mock.ShouldNotBe(null);
			mock.ShouldBeTypeOf<IAmARandomThing>();
		}
	}

    public class WhenMockingXunit
    {
        [Fact]
        public void ShouldAddToDictionary()
        {
            var mm = new MockManager();
            var mock = mm.Mock<IAmARandomThing>();
            mock.ShouldNotBe(null);
            mock.ShouldBeTypeOf<IAmARandomThing>();
        }
    }

	public class MockManagerBehaviour : BehaviourTest<MockManager>
	{
		private IAmARandomThing _mock;

		protected override void Given()
		{
			
		}

		protected override void When()
		{
			_mock = SystemUnderTest.Mock<IAmARandomThing>();
		}

		[Then]
		public void ShouldYieldMockOfCorrectType()
		{
			_mock.ShouldBeTypeOf<IAmARandomThing>();
		}
	}

	public interface IAmARandomThing
	{
		string Bar { get; }
	}
}
