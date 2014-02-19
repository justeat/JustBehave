#6.4.0
##Add
* standard PRS automation sync'd to latest
* xunit now gets nuget'd in and used rather than vendor'd
* update AutoFixture, FakeItEasy dependencies

#6.2.0
##Add
* AutoFixture upgraded to 3.6.6

#6.1.0
##Add
* Ability to assert against logging events
* AutoFixture updated to 3.5.1

#6.0.1
* Dependencies upgraded

#6.0.0
* Introduced XUnit-based `XBehaviourTest<TSut>`, pushing most functionality down into base class `BehaviourTestBase<TSut>`.
* Removed hand-rolled auto-mocking in favour of [AutoFixture](https://github.com/AutoFixture/AutoFixture).
  * Allowed customisation of auto-mocking by new `CustomizeAutoFixture` virtual method - inherit from the base class of your choice.
* Updated automation.

#5.0.3
* Dropped evil Castle Windsor references

#5.0.2
* Update to .NET Framework 4.0
* Update JSON.NET to v2.6.1

#5.0.1
* Update automation compared to bootstrapper and api_content.

#5.0.0
* Swap from OpenWrap to Nuget because it looks like OpenWrap is not going to be maintained going forwards.

#4.0.3
* Remove 4.0.2

#4.0.2
* Reflect Core-HorseCarriage additions - ability to test static IoC from JustEat.Services bootstrapper (as opposed to, you know, splitting away from using that dependency)

#4.0.1
* Project file supports build via OpenWrap, and build when OpenWrap not present, because of source-dependency in main JustEat solution in root.

#4.0.0
##Breaking changes
* Renamed `BehaviourTestBase` to `BehaviourTest` because we still have source-dependencies to root/trunk/JustEat/JustEat.sln

#3.0.0
##Breaking changes
* Renamed `BehaviourTest` to `BehaviourTestBase` for ndepend

#2.0.0

##Breaking changes
* Renamed `PostAssertTearDown` to `PostAssertTeardown` (fix case for FxCop)

##Changed
* FxCop warnings and errors eliminated

#1.1.0
##Added
* Some tests, which was a bit meta but what the hell.

#1.0.0
First release, moved from `root/JustEat/src/JustEat.Testing` -> components tree as standalone OpenWrap'd package
