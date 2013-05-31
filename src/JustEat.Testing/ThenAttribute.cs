using System;
using NUnit.Framework;

namespace JustEat.Testing
{
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class ThenAttribute : TestAttribute {}
}
