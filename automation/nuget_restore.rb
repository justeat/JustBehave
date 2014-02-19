class NugetRestore
  include WithLogging
  include Cocaine
  include Rake::DSL

  attr_accessor :sources, :configs, :packages_dir, :nuget

  def initialize(configs=[".nuget/packages.config", "**/packages.config"], sources=[NugetFeed.new, NugetFeed.new('nuget.org', '/api', name='v2/')], opts={})
    @nuget = opts[:nuget_exe] || ".nuget/nuget.exe"
    @configs = configs
    @sources = sources
    @packages_dir = opts[:packages_dir] || 'packages'
    yield self if block_given?
  end

  def define
    namespace :nuget do
      directory packages_dir

      desc "restore packages"
      task :restore => [packages_dir] do
        restore_all configs
      end
    end
  end

  private

  def restore_all(globs)
    package_configs = FileList.new globs
    package_configs.map{|pc|Pathname.new(pc)}.each do |pc|
      logger.debug "restoring", {config: pc.to_s, exists: pc.exist?}
      restore_for pc if pc.exist?
    end
  end

  def restore_for(package_config)
    s = sources.map {|source| "-source #{source}"}.join(' ')
    pc_win = package_config.to_s.gsub('/', '\\')
    pd_win = packages_dir.gsub('/','\\')
    restore = CommandLine.new(nuget, "install \"#{pc_win}\" #{s} -o \"#{pd_win}\"", logger: logger)
    logger.debug restore.run
  end
end
