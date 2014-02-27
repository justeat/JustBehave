class Gendarme
  include Rake::DSL
  include Cocaine
  include TeamCity

  def initialize(opts={})
    @out_dir = opts[:out_dir] || 'out'
    @exe = opts[:exe] || FileList.new("packages/Mono.Gendarme*/tools/gendarme.exe").first
    @configuration = opts[:configuration] || Release
    @includes = opts[:includes] || ["src/*/bin/J*.{exe,dll}", "src/*/bin/#{@configuration}/J*.{exe,dll}"]
    @excludes = opts[:excludes] || [/AspnetCompileMerge/, /PackageTmp/]
  end

  def define
    namespace :analysis do
      namespace :gendarme do
        directory @out_dir
        report_dir = "#{@out_dir}/gendarme"
        directory report_dir
        gendarme_output = ''
        desc 'Run gendarme across build-output'
        task :run => [report_dir] do
          html = "#{report_dir}/gendarme.html".gsub('/','\\')
          list = FileList.new
          @includes.each {|g| list.include g}
          @excludes.each {|g| list.exclude g}
          assemblies = list.map{|i| Pathname.new i}.uniq{|i| i.basename }
          runner = CommandLine.new(@exe, "--html #{html} --severity all --confidence all --v #{assemblies}", logger: Logger.new(STDOUT), expected_outcodes: [0,1,3])
          gendarme_output = runner.run
        end

        task :run => [:bootstrap, :compile] unless is_build_agent?

        task :publish => :run do
          if gendarme_output
            defects = gendarme_output.match(/^(\d+) defects found/i)
            puts "##teamcity[buildStatisticValue key='Gendarme_Defects' value='#{defects}']"
          end
        end
        task :default => [:run, :publish]
      end

      desc "Run and publish gendarme analysis"
      task :gendarme => 'analysis:gendarme:default'
    end

    task :analyse => 'analysis:gendarme:default'
  end
end
