require 'digest'
class ConfigurationGenerator
  include WithLogging
  include Rake::DSL

  attr_reader :includes, :excludes, :sources, :data

  def initialize(data, opts={})
    @data = data
    @includes = ["src/*/*.erb", "src/**/*.erb", "**/validFromGeneration.config.erb"]
    @excludes = [/src\/.*\/(bin|obj)\/.*\/*.erb/i]
    @depend_on = opts[:depend_on] || []
  end

  def define
    namespace :configuration do

      task :initialize do
        data.read
        depend_on_all_found_config_files
      end

      task :generate => :initialize

      list = FileList.new(includes)
      excludes.each{|e|list.exclude e}
      template_files = list.map{|f|Pathname.new f}
      template_files.each do |tf|
        logger.debug "Template found:", {template_file: tf.to_s}
        output = Pathname.new(tf.to_s.gsub(tf.extname, ''))
        hash = Pathname.new("#{output}.sha1")
        logger.debug "Render to", {output: output.to_s, hash: hash.to_s}
        logger.debug "Creating file task for output", {template: tf.to_s, output: output.to_s}
        file output.to_s => tf
        file output.to_s do
          renderer = ERB.new(tf.read, nil, '%<>')
          generated = renderer.result(data.get_binding)
          logger.debug "Generated.", {template: tf.to_s, output: output.to_s}
          output.open('w') {|f| f.write generated }
        end

        file hash.to_s => output.to_s
        file hash.to_s do
          signature = Digest::SHA1.hexdigest File.read(output)
          logger.debug "Signed.", {template: tf.to_s, signature: signature}
          hash.open('w') {|f| f.write signature }
        end

        CLEAN.include output.to_s
        CLEAN.include hash.to_s

        task :generate => [output.to_s, hash.to_s]
      end

      desc "Generate configuration files"
      task :generate => @depend_on

      task :default => [:generate]
    end

    task :bootstrap => 'configuration:generate'
  end

  def depend_on_all_found_config_files
        file_tasks = Rake::Task["configuration:generate"].prerequisite_tasks.select { | task | task.kind_of?(Rake::FileTask) }
        file_tasks.each do | task |
          task.enhance data.source_files.map { | source_file | file source_file}
        end
  end
end
