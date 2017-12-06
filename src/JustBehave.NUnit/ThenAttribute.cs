using System;
using NUnit.Framework;

namespace JustBehave
{
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class ThenAttribute : TestAttribute {}
}
