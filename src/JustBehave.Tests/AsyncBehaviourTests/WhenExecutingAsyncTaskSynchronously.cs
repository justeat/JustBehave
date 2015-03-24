using System.Threading;
using System.Threading.Tasks;
using NUnit.Framework;
using Shouldly;

namespace JustBehave.Tests.AsyncBehaviourTests
{
    public class WhenExecutingAsyncTaskSynchronously
    {
        [Test]
        public void ThenExecutesOnTheSameThread()
        {
            var testThread = Thread.CurrentThread.ManagedThreadId;
            var asyncThread = AsyncExtensions.RunSynchronously(async () =>
            {
                await Task.Delay(0);
                return Thread.CurrentThread.ManagedThreadId;
            });
            testThread.ShouldBe(asyncThread);
        }

        [Test]
        public void ThenBlocksUntilCompletion()
        {
            var resumed = false;
            AsyncExtensions.RunSynchronously((async () =>
            {
                await Task.Yield();
                resumed = true;
            }));
            resumed.ShouldBe(true);
        }
    }
}
