class NugetPackage
  include WithLogging
  include Cocaine
  include Rake::DSL

  attr_accessor :name, :version, :src_dir, :nuget, :out_dir
  attr_accessor :includes, :excludes

  def initialize(name, version, src_dir, includes, opts={})
    @name = name
    @version = version
    @src_dir = src_dir
    @includes = includes.map{|i| "#{src_dir}/#{i}"}
    @nuget = opts[:nuget_exe] || ".nuget/nuget.exe"
    @out_dir = opts[:out_dir] || "out"
    @excludes = opts[:excludes] || [/(Shouldly|Rhino|nunit|Test|Castle|NLog|^ServiceStack)/i]
    @skip_dependencies = opts[:skip_dependencies]
    yield self if block_given?
  end

  def define(&nuspec_block)
    fail "Must supply a nuspec block.  See https://github.com/Albacore/albacore/wiki/NuSpec-Task" if nuspec_block.nil?
    namespace :nuget do
      namespace name.to_sym do
        desc "Harvest the output to prepare package"
        task :harvest

        package_lib = "#{package_dir}/lib/net40"
        directory package_dir
        directory package_lib

        task :harvest => [package_lib] do
          lib_files = FileList.new(includes)
          excludes.each {|e| lib_files.exclude e }
          lib_files.map{|f|Pathname.new f}.each do |f|
            harvested = "#{package_lib}/#{f.basename}"
            logger.debug "Harvesting", {from: f.to_s, to: harvested}
            FileUtils.cp_r f, harvested
          end
        end

        desc "Create the nuspec"
        nuspec :nuspec => [package_dir, :harvest] do |nuspec|
          nuspec_block.call nuspec
          nuspec.working_directory = package_dir
          if (!@skip_dependencies)
            NugetPackage::dependencies(packages_config).each do |d|
              logger.debug 'dependency', {dependency: d}
              nuspec.dependency d[:name], d[:version]
            end
          end
        end

        nupkg = "#{out_dir}/#{name}.#{version}.nupkg"
        desc "Create the nuget package"
        file nupkg => [:nuspec] do |nugetpack|
          pack = CommandLine.new(nuget, "pack \"#{spec_path_win}\" -basepath \"#{package_dir_win}\" -o \"#{out_dir_win}\"", logger: logger)
          logger.debug pack.run
        end
        task :nupkg => nupkg

        task :default => [:harvest, :nuspec, :nupkg]
      end
    end
    task :nuget => "nuget:#{name}:default"

    CLEAN.include "*.{pdb,dll,xml}"
    CLEAN.include "src/*/*.{dll,pdb,xml}"
    CLEAN.exclude 'CustomDictionary.xml'
  end

  private

  def packages_config
    File.join src_dir, 'packages.config'
  end

  def package_dir_win
    windows(package_dir)
  end

  def out_dir_win
    windows(out_dir)
  end

  def spec_path
    File.join package_dir, "#{name}.nuspec"
  end

  def spec_path_win
    windows(spec_path)
  end

  def windows(path)
    path.gsub('/','\\')
  end

  def package_dir
    File.join working_dir, name
  end

  def working_dir
    File.join out_dir, 'nugets'
  end

  def self.dependencies(package_config_file)
    xml = Nokogiri::XML(File.read package_config_file)
    package_source = xml.xpath('//package').map{|n| {name: n['id'], version: n['version'], allowedVersions: n['allowedVersions']}}
     package_source.each do |p|
      if(p[:allowedVersions])  then
        allowed_version_components = p[:allowedVersions].scan(/(\(|\[)([0-9\.]*),([0-9\.]*)(\)|\])/).first
        if(allowed_version_components) then
          lower_bound_type, lower_bound_version, upper_bound_version, upper_bound_type = allowed_version_components
          if(lower_bound_version.to_s.empty?) then
            lower_bound_type = '['
            lower_bound_version = p[:version]
          end
          p[:version] = "#{lower_bound_type}#{lower_bound_version},#{upper_bound_version}#{upper_bound_type}"
        end
      end
    end
  end

end
