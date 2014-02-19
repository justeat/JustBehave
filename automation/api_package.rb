class ApiPackage
  include Rake::DSL
  include Cabin
  include Cocaine

  attr_reader :cmd_opts, :logger

  def initialize(opts={})
    @site_name = opts[:site_name]
    @version = opts[:version]
    @depend_on = opts[:depend_on] || [:compile]
    @configuration = opts[:configuration] || 'Release'
    @out_dir = opts[:out_dir] || 'out'
    verbosity = (opts[:verbosity] || ENV['verbosity'] || 'warn').to_sym
    log = Logger.new(STDOUT)
    @logger = Channel.new
    @logger.subscribe(log)
    @logger.level = verbosity
    @cmd_opts = { logger: @logger }
  end

  def define
    namespace :packaging do
      namespace :site do
        task :harvest => @depend_on

        harvest_to = Pathname.new("#{@out_dir}/pkg/api_site")

        desc "Assemble the package for #{@site_name}"
        task :harvest do
          cp_r "deploy", "#{harvest_to.to_s}"
          cp_r "configuration", "#{harvest_to.to_s}/configuration"
          cp_r "logging", "#{harvest_to.to_s}/logging"
          Pathname.glob("#{harvest_to.to_s}/**/production.yml").each {|yml| yml.delete }
          File.open("#{harvest_to.to_s}/version.txt", "w") {|f| f.puts @version}
          logger.debug "Contents harvested", {harvest_to: harvest_to, entries: harvest_to.entries}
        end

        desc "Compress the site package"
        task :compress do
          logger.debug "Contents zipping up", {harvest_to: harvest_to, entries: harvest_to.entries}
          chdir harvest_to.to_s do
            zip = CommandLine.new('../../../3rdparty/7-zip/7za.exe', "a #{@site_name}.7z .\\*", cmd_opts)
            logger.debug zip.run
            mv "#{@site_name}.7z", "../../../#{@out_dir}/#{@site_name}-#{@configuration}-v#{@version}.7z"
          end
        end
        task :default => [:harvest, :compress]
      end
    end

    desc "Package up the API site"
    task :package => 'packaging:site:default'
  end
end
