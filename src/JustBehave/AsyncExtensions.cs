using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace JustBehave
{
    public static class AsyncExtensions
    {
        public static T RunSynchronously<T>(Func<Task<T>> task)
        {
            var oldSychronizationContext = SynchronizationContext.Current;
            var synchronizationContext = new AsyncExtensionsSynchronizationContext();
            SynchronizationContext.SetSynchronizationContext(synchronizationContext);
            var returnedValue = default(T);

            synchronizationContext.Post(async _ =>
            {
                try
                {
                    returnedValue = await task();
                }
                catch (Exception e)
                {
                    synchronizationContext.InnerException = e;
                    throw;
                }
                finally
                {
                    synchronizationContext.EndMessageLoop();
                }
            }, null);
            synchronizationContext.BeginMessageLoop();
            SynchronizationContext.SetSynchronizationContext(oldSychronizationContext);
            return returnedValue;
        }

        public static void RunSynchronously(Func<Task> task)
        {
            var oldSynchronizationContext = SynchronizationContext.Current;
            var synchronizationContext = new AsyncExtensionsSynchronizationContext();
            SynchronizationContext.SetSynchronizationContext(synchronizationContext);

            synchronizationContext.Post(async _ =>
            {
                try
                {
                    await task();
                }
                catch (Exception e)
                {
                    synchronizationContext.InnerException = e;
                    throw;
                }
                finally
                {
                    synchronizationContext.EndMessageLoop();
                }
            }, null);
            synchronizationContext.BeginMessageLoop();

            SynchronizationContext.SetSynchronizationContext(oldSynchronizationContext);
        }

        private class AsyncExtensionsSynchronizationContext : SynchronizationContext
        {
            private bool _done;
            readonly Queue<Tuple<SendOrPostCallback, object>> _items = new Queue<Tuple<SendOrPostCallback, object>>();
            readonly AutoResetEvent _workItemsWaiting = new AutoResetEvent(false);

// ReSharper disable MemberCanBePrivate.Local
            public Exception InnerException { get; set; }
// ReSharper restore MemberCanBePrivate.Local

            public override void Send(SendOrPostCallback sendOrPostCallback, object state)
            {
                throw new NotSupportedException("Sending/posting to the same thread is not supported");
            }

            public override void Post(SendOrPostCallback d, object state)
            {
                lock (_items)
                {
                    _items.Enqueue(Tuple.Create(d, state));
                }

                _workItemsWaiting.Set();
            }

            public void EndMessageLoop()
            {
                Post(_ => _done = true, null);
            }

            public void BeginMessageLoop()
            {
                while (!_done)
                {
                    Tuple<SendOrPostCallback, object> task = null;
                    lock (_items)
                    {
                        if (_items.Count > 0)
                        {
                            task = _items.Dequeue();
                        }
                    }
                    if (task != null)
                    {
                        task.Item1(task.Item2);
                        if (InnerException != null)
                        {
                            throw new AggregateException("AsyncExtensions called lambda threw an exception.", InnerException);
                        }
                    }
                    else
                    {
                        _workItemsWaiting.WaitOne();
                    }
                }
            }

            public override SynchronizationContext CreateCopy()
            {
                return this;
            }
        }
    }
}
