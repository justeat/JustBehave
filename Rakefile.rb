require 'bundler'
Bundler.require :build, :debugging
require 'rake/clean'
require 'pathname'
require './automation/logging.rb'
require './automation/teamcity.rb'
require './automation/version.rb'
require './automation/clean.rb'
require './automation/assembly_info.rb'
require './automation/nuget.rb'
require './automation/nunit.rb'
require './automation/ndepend.rb'
require './automation/xunit.rb'
include Cocaine

name = ENV['name'] || 'JustEat.Testing'
@log = setup_logging(ENV['verbosity'] || 'info')
configuration = ENV['msbuild_configuration'] || 'Release'
cmd_opts = {logger: @log}

directory 'out'

task :directories => 'out'
setup_xunit configuration: configuration, depend_on: [:compile]
setup_nuget name: name, configuration: configuration, version: version
setup_nunit configuration: configuration
setup_ndepend configuration: configuration, third_party_path: '3rdparty', in_dirs: FileList.new("src/*/bin/#{configuration}/")

AssemblyInfoGenerator.new(log: @log, version: version, internals_visible_to: 'JustEat.Testing.Tests' ).generate
desc 'Bootstrap all build-dependencies'
task :bootstrap => ['nuget:restore', :assembly_info, :directories]

desc "Compile solution"
msbuild :compile => [:bootstrap] do |m|
	m.targets :Build
	m.solution = "#{name}.sln"
	m.properties = {TreatWarningsAsErrors: true, BuildInParallel: true, Configuration: configuration}
	m.max_cpu_count = 4
	m.log_level = :verbose
end

CLEAN.include 'out', '**/obj'
CLEAN.exclude /packages\.config/i
CLEAN.include '**/app.config'
CLOBBER.include 'packages/*'
CLOBBER.exclude /packages\/repositories\.config/i

task :build => [:bootstrap, :compile]
task :quality => [:test, :analyse]
task :package => [:build, :nuget]
task :default => [:package]
