require 'json'
require 'rake'
require 'cocaine'

class AssemblyInfoGenerator
	include Rake::DSL
	include Cocaine

	def initialize(params={})
		@projects = params[:projects] || FileList.new("**/*.csproj").map{|p|Pathname.new p}
		@svn = params[:svn] || "3rdparty/svn/bin/svn.exe"
    @internals_visible_to = params[:internals_visible_to] || nil
		@log = params[:log] || Logger.new(STDOUT)
		@checkout_root = params[:checkout_root] || '.'
		@version = params[:version]
	end

	def generate
		@projects.each {|p| generate_assembly_info_for p}
	end

	def generate_assembly_info_for(project)
		name = project.basename.sub(project.extname, '').to_s
		@log.debug "generate assembly info for #{name}"

		dir = File.join(project.dirname.to_s, 'Properties')
		directory dir
		output = File.join dir, "AssemblyInfo.cs"
		desc "Generate AssemblyInfo.cs for #{name}"
		assemblyinfo :assembly_info => [dir] do |asm|
			asm.version = @version
			asm.company_name = "Just-Eat Holding Ltd"
			asm.title = name
			asm.copyright = "Copyright #{Time.now.year}, by Just-Eat Holding Ltd"
			asm.custom_attributes :CLSCompliant => false
      @log.info "IVT: #{@internals_visible_to}"
      if @internals_visible_to
        asm.custom_attributes.merge!({:InternalsVisibleTo => @internals_visible_to})
      end
      @log.info "asm:ca = #{asm.custom_attributes}"
			asm.com_visible = false
			asm.description = assembly_description.to_json
			asm.namespaces = ['System', 'System.Runtime.CompilerServices']
			asm.output_file = output
		end
		CLEAN.include output
	end

	def assembly_description
		{
			branch: read_branch,
			revision: read_revision,
			build: {
				at: Time.now.utc,
				by: ENV['username'],
				on: `hostname`.chomp
			}
		}
	end

	def read_branch
		case source_control
			when :git then `git branch --no-color`.match(/\* (.*)$/i)[1]
			when :svn_post17, :svn_pre17 then svn_branch
			else raise "Unsupported source control #{scm}"
		end
	end

	def source_control
		return @scm unless @scm.nil?
		sh "git status" do |ok,result|
			@scm = :git
			return :git if ok
		end
		sh "#{@svn} info" do |ok,result|
			@scm = :svn_post17
			return :svn_post17 if ok		
		end
		sh "svn info" do |ok, result|
			@scm = :svn_pre17
			@svn = 'svn'
			return :svn_pre17 if ok
		end
		raise 'Unsupported source control'
	end

	def svn_info
		return @svn_info_result unless @svn_info_result.nil?
		@svn_info_result = CommandLine.new(@svn, "info #{@checkout_root}", logger: @log).run
		if @svn_info_result.include? 'not a working copy'
			# <= 1.6.x exe on >= 1.7.x working copy
			@svn_info_result = `svn info`
		end
		@svn_info_result
	end

	def read_revision
		case source_control
			when :git then `git log -1 --no-color`.match(/commit (.*)$/i)[1]
			when :svn_post17, :svn_pre17 then svn_info.match(/Revision: (\d+)/i)[1]
			else raise "Unsupported source control #{scm}"
		end
	end

	def svn_branch
		return @branch unless @branch.nil?
		root = svn_info.match(/Repository Root: (.*)$/i)[1]
		url = svn_info.match(/URL: (.*)$/i)[1]
		path = url.to_s.sub(root.to_s, '')
		@log.debug "svn_branch: url - #{url}, path - #{path}"
		if path.to_s =~ /branches/i
			@branch = path.to_s.match(/branches\/([^\/]+)\/?/i)[1]
		elsif path.to_s =~ /tags/i
			@branch = path.to_s.match(/tags\/([^\/]+)\/?/i)[1]
		else
			@branch = 'trunk' #assume trunk by standard layout
		end
		@branch
	end
end
