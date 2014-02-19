class EnvironmentConfiguration
  include WithLogging
  include Rake::DSL

  attr_reader :justeat_root, :team, :feature

  def initialize(feature, justeat_root, team)
    @feature = feature
    @justeat_root = justeat_root
    @team = team
    fail "Must supply team via JUSTEAT_TEAM environment variable" if team.nil? || team == ''
  end

  def define
    config_dir = "#{justeat_root}/configuration/#{feature}"
    directory config_dir
    [
      {key: 'domain', value: "#{team}.je-labs.com"},
      {key: 'instance_id', value: `hostname`.chomp},
      {key: 'instance_position', value: "all\\#{feature}_000"},
      {key: 'internal_port', value: 80},
      {key: 'statsd_endpoint', value: "monitoring.#{team}.je-labs.com"},
      {key: 'statsd_port', value: 8125},
      {key: 'statsd_prefix', value: ''},
      {key: 'team', value: team},
      {key: 'zone_raw', value: 'eu-west-1a'}
    ].each do |item|
      config_file = "#{justeat_root}/configuration/#{feature}/#{item[:key]}.config-key.txt"
      file config_file => config_dir do |task|
        File.open(config_file, 'w') do |f|
          f.puts item[:value]
        end
        logger.debug "Created environment config stub #{{key: item[:key], value: item[:value], path: config_file}.to_json}"
      end
      task :environment_config => config_file
    end

    secrets_dir = "#{justeat_root}/secure/#{feature}"
    directory secrets_dir
    source_secrets = Dir["secrets/*"]
    source_secrets.each do | source_secret |
      secret = "#{secrets_dir}/#{source_secret}"
      file secret => [secrets_dir, source_secret] do
        FileUtils.cp_r source_secret, secrets_dir
        logger.debug "copied #{source_secret} to #{secrets_dir}"
      end
      task :environment_config => secret
    end

    desc 'Set up some valid environment configuration as cfn-init would produce based on Cloud::Init files'
    task :environment_config
    Rake::Task[:bootstrap].prerequisites.unshift :environment_config

    CLEAN.include config_dir, secrets_dir
  end
end
