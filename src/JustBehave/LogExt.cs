using System;
using System.Linq.Expressions;
using NLog.Targets;
using Shouldly;

namespace JustBehave
{
    public static class LogExt
    {
        public static void ShouldHaveLogged(this TargetWithLayout target, string message)
        {
            MemoryTarget(target).Logs.ShouldContain(message);
        }

        public static void ShouldHaveLogged(this TargetWithLayout target, Func<string, bool> predicate)
        {
            var expression = FuncToExpression(predicate);
            MemoryTarget(target).Logs.ShouldContain(expression);
        }

        private static Expression<Func<T, bool>> FuncToExpression<T>(Func<T, bool> f)
        {
            return x => f(x);
        }

        private static MemoryTarget MemoryTarget(TargetWithLayout target)
        {
            var memoryTarget = target as MemoryTarget;
            if (memoryTarget == null)
            {
                throw new ArgumentNullException("target", "target must derive from NLog.Targets.MemoryTarget");
            }
            return memoryTarget;
        }
    }
}
