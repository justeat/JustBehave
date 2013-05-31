require 'bundler'
Bundler.require :default
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
include Cocaine

name = 'JustEat.Testing'
@log = setup_logging(ENV['verbosity'] || 'info')
configuration = ENV['msbuild_configuration'] || 'Release'

out_dir = 'out'
directory out_dir
task :test => out_dir
setup_nunit configuration: configuration
setup_ndepend configuration: configuration, dotnet_framework: 'v3.5'
setup_nuget name: name, configuration: configuration, version: version

desc 'Bootstrap all build-dependencies'
task :bootstrap
task :bootstrap => 'nuget:restore'

AssemblyInfoGenerator.new(log: @log, version: version).generate
task :bootstrap => [:assembly_info]

desc "Compile solution"
msbuild :compile => [:bootstrap, 'nuget:restore'] do |m|
	m.properties :configuration => configuration
	m.targets :Build
	m.solution = "#{name}.sln"
end
CLEAN.include 'out', '**/obj'
CLOBBER.include 'packages'

task :build => [:bootstrap, :assembly_info, :compile, :test, :analyse]
task :package => [:build, :nuget]
task :default => [:package]
