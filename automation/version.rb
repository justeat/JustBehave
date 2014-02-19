class Versioning
  include TeamCity
  include WithLogging
  include Rake::DSL

  def initialize(opts={})
    @version_file = opts[:version_file] || 'version'
    desc 'Publish the version into a teamcity parameter'
    task :teamcity_version_publish do
      print "##teamcity[setParameter name='build.version' value='#{version}']\n"
    end
    task :bootstrap => :teamcity_version_publish  if is_build_agent?
  end

  def define
  end

  def version
    main = Pathname.new(@version_file).read.chomp
    main += ".#{ENV['BUILD_NUMBER']}" if is_build_agent?
    main
  end
end
