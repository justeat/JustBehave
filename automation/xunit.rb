class XUnit
  include TeamCity
  include Rake::DSL

  def setup_xunit(params={})
    configuration = params[:configuration] || 'Release'
    depend_on = params[:depend_on] || []
    out = params[:out] || 'out'
    reports = "#{out}/unit-tests"
    glob = params[:glob] || "src/*/bin/#{configuration}/*.Tests.dll"

    namespace :test do
      desc 'Run all xunit-tests'
      xunit do |xunit|
        runners_glob = "packages/xunit.runners*/tools/xunit.console.clr4.x86.exe"
        candidate_runners = FileList.new(runners_glob)
        raise "No runner found via 'runners_glob'" if candidate_runners.empty?
        xunit.command = candidate_runners.first
        xunit.assemblies = FileList.new glob
        xunit.html_output = reports
        xunit.options = ["/nunit #{reports.gsub('/','\\')}/unit-tests.nunit.xml"]
        xunit.options << "/teamcity" if is_build_agent?
        xunit.log_level = :verbose
      end

      directory reports
      task 'test:xunit' => reports
      CLEAN.include 'out/TestResults.xml'
    end

    desc 'Run all tests'
    task :test => depend_on do
      Rake.application.in_namespace(:test){|x| x.tasks.each{|t| t.invoke}}
    end
    task :directories => reports
  end
end
