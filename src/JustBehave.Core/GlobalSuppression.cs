using System.Diagnostics.CodeAnalysis;

[assembly: SuppressMessage("Microsoft.Design", "CA1063:ImplementIDisposableCorrectly", Justification = "FxCop's pattern is wrong.  http://blog.stephencleary.com/2009/08/third-rule-of-implementing-idisposable.html + http://stackoverflow.com/questions/538060/proper-use-of-the-idisposable-interface?rq=1")]
[assembly: SuppressMessage("Microsoft.Design", "CA2210:AssembliesShouldHaveValidStrongNames", Justification = "No they shouldn't.")]
