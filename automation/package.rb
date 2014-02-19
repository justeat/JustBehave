class Package
  include Rake::DSL
  include WithLogging
  include Cocaine

  attr_reader :cmd_opts
  attr_reader :feature, :version, :depend_on, :configuration, :out_dir
  attr_accessor :harvest_into, :items, :after

  def initialize(opts={}, &block)
    @feature = opts[:feature]
    @version = opts[:version]
    @depend_on = opts[:depend_on] || [:compile]
    @configuration = opts[:configuration] || 'Release'
    @out_dir = opts[:out_dir] || 'out'
    @cmd_opts = { logger: logger }
    @harvest_into = Pathname.new "#{@out_dir}/pkg/JustEat.#{@feature}"
    @items = [
      {from: Pathname.new('deploy')},
      {from: Pathname.new('configuration')}
    ]
    @after = [lambda {Dir.glob("#{harvest_into}/**/*.config").each{|f|rm_rf f unless f =~ /PrecompiledApp/i }}]
    yield self if block_given?
  end

  def define
    namespace :packaging do
      directory harvest_into.to_s
      task :harvest => @depend_on
      task :harvest => harvest_into.to_s

      desc "Assemble the package for #{@feature}"
      task :harvest do
        @items.each do |i|
          logger.debug "harvesting item", {item: i}
          to = i[:to].nil? ? harvest_into.join(i[:from].basename) : harvest_into.join(i[:to])
          logger.debug "to", {to: to}
          cp_r i[:from].to_s, to.to_s
        end
        after.each {|t|t.call}
        Pathname.glob("#{harvest_into.to_s}/**/production.yml").each {|yml| yml.delete }
        File.open("#{harvest_into.to_s}/version.txt", "w") {|f| f.puts @version}
        logger.debug "Contents harvested", {harvest_into: harvest_into, entries: harvest_into.entries}
      end

      desc "Compress the site package"
      task :compress do
        logger.debug "Contents zipping up", {harvest_into: harvest_into, entries: harvest_into.entries}
        chdir harvest_into.to_s do
          zip = CommandLine.new('../../../3rdparty/7-zip/7za.exe', "a #{@feature}.7z .\\*", cmd_opts)
          logger.debug zip.run
          mv "#{@feature}.7z", "../../../#{@out_dir}/JustEat.#{@feature}-#{@configuration}-v#{@version}.7z"
        end
      end
      task :default => [:harvest, :compress]
    end

    desc "Package up the API site"
    task :package => 'packaging:default'
  end
end
