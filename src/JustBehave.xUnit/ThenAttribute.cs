using System;
using Xunit;

namespace JustBehave.xUnit
{
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class ThenAttribute : FactAttribute { }
}
