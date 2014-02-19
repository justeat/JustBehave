class FunctionalTests
  include Rake::DSL

  attr_reader :report_dir

  def initialize
    @report_dir = "out/functional-tests"
  end

  def define
    namespace :cucumber do
      directory report_dir
      common = '-r features --format pretty --color'

      desc "Run features expected to pass"
      Cucumber::Rake::Task.new(:ok) do |t|
        t.cucumber_opts = "#{common} --tags=~@wip --tags=~@ignore #{html(:ok)} #{env}"
      end

      desc "Run features work-in-progress"
      Cucumber::Rake::Task.new(:wip) do |t|
        t.cucumber_opts = "#{common} --tags=@wip --tags=~@ignore #{html(:wip)} #{env}"
      end

      task :ok => report_dir
      task :wip => report_dir
    end
  end

  private

  def html(task)
    "--format html --out #{report_dir}/cucumber.#{task}.html"
  end

  def env
    possibilities = %w(environment integrate_against verbosity http_log http_long http_proxy msbuild_configuration)
    vars = []
    possibilities.each do |p|
      vars << "#{p}=#{ENV[p]}" if ENV[p]
    end
    vars.join ' '
  end
end
