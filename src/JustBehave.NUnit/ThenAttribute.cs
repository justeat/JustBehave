using System;
using NUnit.Framework;

namespace JustBehave.NUnit
{
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class ThenAttribute : TestAttribute {}
}
