The file NDependReport.xsl is provided as an example to define your own xsl to build your own report.
To define your own Xsl sheet, reference it from:
NDepend Interactive UI > Project Properties Panel > Report Tab > Scroll Down > Use you own Xsl sheet to build report


The Xml information outputed by an analysis can be found in the following Xml files that are in the output directory of the project:

ApplicationMetrics.xml
AssembliesBuildOrder.xml
AssembliesDependencies.xml
AssembliesMetrics.xml
NamespacesMetrics.xml
NamespacesDependencies.xml
TypesDependencies.xml
TypesMetrics.xml
InfoWarnings.xml
CQLRuleResult.xml
CQLQueryResult.xml

The Xml schema of these files is simple. However we don't garantee that it will remain stable in the future.

Make sure to select the project option
'Keep XML files used to build reports and store warnings'
if you want to keep these XML files.

