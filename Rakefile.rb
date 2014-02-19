require 'bundler'
Bundler.require :build, :debugging
require 'rake/clean'
require 'pathname'
require './automation/automation.rb'
require './configuration/configuration.rb'
require './configuration/configuration_generator.rb'
require './configuration/paymentsapi_environment.rb'
include Cocaine

name = ENV['component'] || 'JustEat.Testing'
jer = ENV['justeat_root'] # JUSTEAT_ROOT should be defined in TeamCity build parameters
team = ENV['JUSTEAT_TEAM'] || 'prs'
verbosity = ENV['VERBOSITY'] || 'warn'
@log = setup_logging(verbosity)
configuration = ENV['msbuild_configuration'] || 'Release'
environment = ENV['environment'] || 'dev'
cmd_opts = {logger: @log}
v = Versioning.new
version = v.version
p = Publishing.new(version, 'Default')
p.define

out_dir = 'out'
directory out_dir

task :directories => 'out'
XUnit.new.setup_xunit configuration: configuration, depend_on: [:compile]
contract = NugetPackage.new(name, version, "src/JE.Api.Payments.Contracts", ["bin/#{configuration}/JE.Api.Payments.Contracts.{dll,pdb,xml}"], skip_dependencies: true)
contract.define do |nuspec|
  nuspec.id = name
  nuspec.version = version
  nuspec.authors = "Peter Mounce"
  nuspec.owners = "Payment and Reporting Team"
  nuspec.description = "JustEat.Testing is our BDD helper for C# unit-tests"
  nuspec.summary = "JustEat.Testing is our BDD helper for C# unit-tests"
  nuspec.language = "en-GB"
  nuspec.licenseUrl = "https://github.je-labs.com/PRS/#{name}/blob/master/LICENSE.md"
  nuspec.projectUrl = "https://github.je-labs.com/PRS/#{name}"
  nuspec.output_file = "#{name}.nuspec"
  nuspec.tags = "bdd tests testing helper general library"

  #Exclude servicestack dependencies, they'll be included by dependency resolution.
  contract_dependencies = NugetPackage::dependencies("src/#{name}/packages.config")
  contract_dependencies = contract_dependencies.select { |dependency| dependency[:name] !~ /^ServiceStack/i }

  contract_dependencies.uniq.each do |d|
    nuspec.dependency d[:name], d[:version]
  end

end

NugetRestore.new.define
setup_nunit configuration: configuration
setup_ndepend configuration: configuration, third_party_path: '3rdparty', in_dirs: FileList.new("src/*/bin/#{configuration}/")

AssemblyInfoGenerator.new(log: @log, version: version, internals_visible_to: 'JustEat.Testing.Tests' ).generate
desc 'Bootstrap all build-dependencies'
task :bootstrap => ['nuget:restore', :assembly_info, :directories]

EnvironmentConfiguration.new(name, jer, team).define
data = Environment.new(environment, name)
ConfigurationGenerator.new(data, verbosity: verbosity, depend_on: [:environment_config]).define
MsBuild.new(name, configuration: configuration).define

CLEAN.include 'out', '**/obj'
CLEAN.exclude /packages\.config/i
CLEAN.include '**/app.config'
CLOBBER.include 'packages/*'
CLOBBER.exclude /packages\/repositories\.config/i

task :build => [:bootstrap, :compile]
task :quality => [:test, :analyse]
task :package => [:build, :nuget]
task :default => [:package]
