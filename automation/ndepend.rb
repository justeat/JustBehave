class NDepend
  def create_parameters
    params = []
    params << File.expand_path(@project_file).gsub('/','\\') #NDepend v3 forces absolute windows-path
    return params
  end
end

def setup_ndepend(params={})
	configuration = params[:configuration] || 'Release'
	third_party_path = params[:third_party_path] || '3rdparty'
	project_file = params[:project_file] || FileList.new('*.ndproj').first
	dotnet_framework = params[:dotnet_framework] || 'v4.0'
  in_dirs = params[:in_dirs] || FileList.new("src/*/bin/*/")
	previous_analysis = params[:previous_analysis] || 'previous_ndepend'
	namespace :analysis do
		report_dir = "out/ndependout"
		directory report_dir

		desc 'Run NDepend analysis; see out/NDependOut/**/NDependReport.html'
		task :ndepend => [report_dir, :compile] do |nd|
			raise ArgumentError, "Project file not found at #{project_file}" unless File.exist? project_file
			project_file = File.expand_path(project_file).gsub('/','\\')
			out_dir = File.expand_path('out/ndependout/').gsub('/','\\')
			compare_with = '/AnalysisResultToCompareWith ' + File.expand_path("#{previous_analysis}/VisualNDepend.bin").gsub('/','\\') if File.exist?("#{previous_analysis}/VisualNDepend.bin")
			ndepend_in_dirs = in_dirs.map{|d| File.expand_path(d)}.join(' ').gsub('/','\\')
      cmd = Cocaine::CommandLine.new("#{third_party_path}/ndepend/ndepend.console.exe", "#{project_file} /outdir #{out_dir} /concurrent #{compare_with} /indirs #{ndepend_in_dirs}", logger: @log, expected_outcodes:[0,1])
			stdout = cmd.run
			puts stdout
		end

		task :publish do
        critical_result_path = Pathname.new('out/ndependout/CodeRuleCriticalResult.xml')
        rule_result_path=Pathname.new('out/ndependout/CodeRuleResult.xml')

        if FileTest.file?(critical_result_path) then
          critical_xml = critical_result_path.read
			else
          critical_xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>
            <RuleCriticalResult></RuleCriticalResult>"
			end

      critical_doc = Nokogiri::XML critical_xml
      violations = 0

      if(critical_doc.css('RuleCritical').length > 0) then
        # find the QueryIds for the violated critical rules
        query_ids = critical_doc.css('RuleCritical[QueryId]').to_a.map {|i| i["QueryId"] }

        # for each QueryId look it up in rule_result_path and sum the NbNodeMatched
        result_doc = Nokogiri::XML rule_result_path.read

        accumulate = 0
        query_ids.each {|id|
          accumulate += result_doc.at_css("Query[QueryId=#{id}]")["NbNodeMatched"].to_i
        }

        violations = accumulate
      end

      puts "##teamcity[buildStatisticValue key='NDepend_Critical_Rule_Violations' value='#{violations}']"
		end
		task :default => [:ndepend, :publish]
	end

	desc 'Run all static analysis'
	task :analyse => 'analysis:default'
end
