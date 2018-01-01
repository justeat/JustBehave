call build.bat
if %errorlevel% neq 0 exit /b %errorlevel%

dotnet pack -c Release JustBehave.sln
if %errorlevel% neq 0 exit /b %errorlevel%
