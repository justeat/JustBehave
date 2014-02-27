def setup_nunit(params={})
	third_party_path = params[:third_party_path] || '3rdparty'
	configuration = params[:configuration] || 'Release'
	depend_on = ['test:default'].concat(params[:depend_on] || [])
	namespace :test do
		desc 'Run all nunit-tests'
		nunit do |nunit|
			nunit.command = "#{third_party_path}/nunit/bin/net-2.0/nunit-console.exe"
			nunit.assemblies = FileList.new "src/*/bin/#{configuration}/*.Tests.dll"
			nunit.options = ['/xml=out\\TestResults.xml']
			nunit.log_level = :verbose
		end
		task :default => 'test:nunit'
		CLEAN.include 'out/TestResults.xml'
	end
	desc 'Run all tests'
	task :test => depend_on
end
