class XUnit
  include TeamCity
  include Rake::DSL
  include Cocaine
  include WithLogging

  def setup_xunit(params={})
    configuration = params[:configuration] || 'Release'
    depend_on = params[:depend_on] || []
    out = params[:out] || 'out'
    reports = "#{out}/unit-tests"
    glob = params[:glob] || "src/*/bin/#{configuration}/*.Tests.dll"
    cmd_opts = { logger: logger }

    namespace :test do
      file 'packages/xunit-runners' => ['nuget:restore'] do |f|
        runners_glob = "packages/xunit.runners*/tools/"
        puts "rg: #{Dir.glob(runners_glob)}"
        candidates = FileList.new(runners_glob)
        fail "No runner found in #{runners_glob}" if candidates.empty?
        link = f.name.gsub('/','\\')
        real = candidates.first
        linker = CommandLine.new('cmd', "/c mklink /d \"#{link}\" \"#{File.expand_path(real).gsub('/','\\')}\"", cmd_opts)
        logger.debug linker.run unless File.exist? 'packages/xunit-runners'
      end

      desc 'Run all xunit-tests'
      xunit do |xunit|
        xunit.command = "packages/xunit-runners/xunit.console.clr4.exe"
        xunit.assemblies = FileList.new glob
        xunit.html_output = reports
        xunit.options = ["/nunit #{reports.gsub('/','\\')}/unit-tests.nunit.xml"]
        xunit.options << "/teamcity" if is_build_agent?
        xunit.log_level = :verbose
      end

      directory reports
      task 'test:xunit' => [reports]
      CLEAN.include 'out/TestResults.xml'
    end

    desc 'Run all tests'
    task :test => depend_on do
      Rake.application.in_namespace(:test){|x| x.tasks.each{|t| t.invoke}}
    end
    task :directories => reports


    task :bootstrap => ['packages/xunit-runners']
  end
end
