def setup_xunit(params={})
  third_party_path = params[:third_party_path] || '3rdparty'
  configuration = params[:configuration] || 'Release'
  depend_on = ['test:default'].concat(params[:depend_on] || [])
  out = params[:out] || 'out'
  reports = "#{out}/unit-tests"
  glob = params[:glob] || "src/*/bin/#{configuration}/*.Tests.dll"
  namespace :test do
    desc 'Run all xunit-tests'
    xunit do |xunit|
      runners_glob = "#{third_party_path}/xunit/xunit.console.clr4.x86.exe"
      candidate_runners = FileList.new(runners_glob)
      raise "No runner found via 'runners_glob'" if candidate_runners.empty?
      xunit.command = candidate_runners.first
      xunit.assemblies = FileList.new glob
      xunit.html_output = reports
      xunit.options = ["/nunit #{reports.gsub('/','\\')}/JustEat.Client.Tests.dll.nunit.xml"]
      xunit.options << "/teamcity" if is_build_agent?
      xunit.log_level = :verbose
    end
    directory reports
    task 'test:xunit' => reports
    task :default => 'test:xunit'
    CLEAN.include 'out/TestResults.xml'
  end
  desc 'Run all tests'
  task :test => depend_on
  task :test => 'test:xunit'
  task :directories => reports
end
