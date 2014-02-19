class MsBuild
  include Rake::DSL
  include TeamCity

  attr_reader :name, :configuration, :publish_profile

  def initialize(name, opts={})
    @name = name
    @configuration = opts[:configuration] || 'Release'
    @publish_profile = opts[:publish_profile] || 'DeploymentPackage'
  end

  def define
    desc "Compile solution"
    msbuild :compile => [:bootstrap] do |m|
      m.targets :Build
      m.solution = "#{name}.sln"
      properties = {TreatWarningsAsErrors: true, BuildInParallel: true, Configuration: configuration, DeployOnBuild: true, PublishProfile: 'DeploymentPackage', VSToolsPath: '../../3rdparty/vstools/'}
      properties.merge!({AspnetMergePath: '3rdparty/bin/NETFX 4.0 Tools'.gsub('/','\\')}) if is_build_agent?
      m.properties = properties
      m.max_cpu_count = 4
      m.log_level = :verbose
    end

    CLEAN.include 'out', '**/obj', 'src/*/bin'
    CLEAN.exclude /packages\.config/i
    CLOBBER.include 'packages/*'
    CLOBBER.exclude /packages\/repositories\.config/i
  end
end
