class Publishing
  include Rake::DSL
  include TeamCity

  def initialize(version, nuget_feed_name)
    @values = {
      version: version,
      nuget_feed_name: nuget_feed_name
    }
  end

  def define
    namespace :publishing do
      @values.each do |key, value|
        desc "Set '#{key}' parameter in CI:TeamCity"
        task key.to_sym do
          tc_set_parameter key, value
        end

        task :default => key.to_sym
      end
    end

    desc 'Inform CI about the values of parameters that it should set, to publish'
    task :publish => 'publishing:default'
  end
end
