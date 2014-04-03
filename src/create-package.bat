call build.bat
if %errorlevel% neq 0 exit /b %errorlevel%

.nuget\nuget pack "JustBehave\JustBehave.csproj" -Properties Configuration=Release
if %errorlevel% neq 0 exit /b %errorlevel%