using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace JustEat.Testing
{
	public class AutoMocker<T>
	{
		private readonly MockManager _mockManager;
		private T _constructedObject;

		public AutoMocker(MockManager mockManager)
		{
			_mockManager = mockManager;
		}

		public T ConstructedObject()
		{
			if (_constructedObject == null)
			{
				_constructedObject = GenerateObject();
			}

			return _constructedObject;
		}

		private T GenerateObject()
		{
			var constructor = GreediestConstructor();
			var constructorParameters = new List<object>();

			foreach (var parameterInfo in constructor.GetParameters())
			{
				constructorParameters.Add(_mockManager.Mock(parameterInfo.ParameterType));
			}

			return (T)constructor.Invoke(constructorParameters.ToArray());
		}

		private static ConstructorInfo GreediestConstructor()
		{
			return typeof(T).GetConstructors()
				.OrderByDescending(x => x.GetParameters().Length)
				.First();
		}
	}
}