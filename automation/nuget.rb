def setup_nuget opts={}
	name = opts[:name]
	configuration = opts[:configuration]
	version = opts[:version] || version
	nuget = opts[:nuget_exe] || ".nuget/nuget.exe"
	@log = opts[:log] || Logger.new(STDOUT)

	namespace :nuget do
		directory 'packages'
		desc "restore packages"
		task :restore => ['packages'] do
			FileList.new([".nuget/packages.config","**/packages.config"]).map{|pc|Pathname.new(pc)}.each do |pc|
				restore = CommandLine.new(nuget, "install \"#{pc.to_s.gsub('/', '\\')}\" -source http://packages.je-labs.com/nuget/Default/ -source http://nuget.org/api/v2/ -o packages", logger: @log)
				restore.run
			end
		end

		desc "Harvest the output to prepare package"
		task :harvest

		package_dir = "out/package"
		package_lib = "#{package_dir}/lib/net40"
		directory package_dir
		directory package_lib

		task :harvest => [package_lib] do
			lib_files = FileList.new("src/JustEat.Testing/bin/#{configuration}/JustEat.Testing.{exe,config,dll,pdb,xml}")
			lib_files.exclude /(Shouldly|Rhino|nunit|Castle|NLog)/
			lib_files.map{|f|Pathname.new f}.each do |f|
			harvested = "#{package_lib}/#{f.basename}"
				FileUtils.cp_r f, harvested
			end
		end

		desc "Create the nuspec"
		nuspec :nuspec => [package_dir, :harvest] do |nuspec|
			nuspec.id = name
			nuspec.version = version
			nuspec.authors = "Peter Mounce"
			nuspec.owners = "Peter Mounce"
			nuspec.description = "JustEat.Testing is our BDD helper for C# unit-tests"
			nuspec.summary = "JustEat.Testing is our BDD helper for C# unit-tests"
			nuspec.language = "en-GB"
			nuspec.licenseUrl = "https://github.je-labs.com/PRS/#{name}/blob/master/LICENSE.md"
			nuspec.projectUrl = "https://github.je-labs.com/PRS/#{name}"
			nuspec.working_directory = package_dir
			nuspec.output_file = "#{name}.nuspec"
			nuspec.tags = "bdd tests testing helper general library"
      nuspec.dependency "AutoFixture", "3.16.5"
      nuspec.dependency "NLog", "2.1.0"
      nuspec.dependency "NUnit", "2.6.2"
		end

		nupkg = "out/#{name}.#{version}.nupkg"
		desc "Create the nuget package"
		file nupkg => [:nuspec] do |nugetpack|
			pack = CommandLine.new(nuget, "pack out\\package\\#{name}.nuspec -basepath out\\package -o out", logger: @log)
			pack.run
		end
		task :build => nupkg

		task :default => [:harvest, :nuspec, :build]
	end
	task :nuget => 'nuget:default'
end
