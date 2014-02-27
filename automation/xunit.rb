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
    link_dir = "#{ENV['JUSTEAT_ROOT']}/xunit-runners"

    namespace :test do
      file link_dir => ['nuget:restore'] do |f|
        real = figure_out_xunit_runner_directory
        link = f.name.gsub('/','\\')
        linker = CommandLine.new('cmd', "/c mklink /d \"#{link}\" \"#{File.expand_path(real).gsub('/','\\')}\"", cmd_opts)
        logger.debug linker.run unless File.exist? link_dir
      end

      desc 'Run all xunit-tests'
      xunit do |xunit|
        xunit.command = "#{link_dir}/xunit.console.clr4.exe"
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

    task :bootstrap => link_dir

    task :delete_symlink do
      real = figure_out_xunit_runner_directory
      del = CommandLine.new('cmd', "/c rmdir /q \"#{File.expand_path(link_dir).gsub('/','\\')}\"", cmd_opts)
      logger.debug del.run if File.exist? link_dir
    end

    task :package => :delete_symlink
  end

  def figure_out_xunit_runner_directory
    runners_glob = "packages/xunit.runners*/tools/"
    candidates = FileList.new(runners_glob)
    fail "No runner found in #{runners_glob}" if candidates.empty?
    candidates.first
  end
end
