using System;
using System.Linq.Expressions;
using NLog.Targets;
using Shouldly;

namespace JustEat.Testing
{
    public static class LogExt
    {
        public static void ShouldHaveLogged(this TargetWithLayout target, string message)
        {
            MemoryTarget(target).Logs.ShouldContain(message);
        }

        public static void ShouldHaveLogged(this TargetWithLayout target, Expression<Func<string, bool>> predicate)
        {
            MemoryTarget(target).Logs.ShouldContain(predicate);
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
