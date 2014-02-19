class Environment
  include Cabin
  include StatsDConfiguration
  include InstanceConfiguration
  include ConnectionStrings
  include WithLogging
  include ApiKnowledge

  ConfigLocations = ['configuration', '../configuration']
  EnvironmentLocation = 'environments'
  ConfigFileName = 'config.yml'
  SecretsName = 'secrets.yml'

  attr_reader :tenants, :name, :basis, :source_files, :feature

  def initialize(name, feature, opts={})
    verbosity = (opts[:verbosity] || ENV['verbosity'] || 'warn').to_sym
    @feature = feature

    @name = name.to_sym
    @source_files = []
  end

  def read
    source = find_config_file(ConfigFileName)
    @basis = {}
    @basis = YAML::load_file source if source
    @source_files << source if source
    merge_environment_specific_config()
    merge_secrets_files()
    @tenants = @basis[:tenants] || {}
  end

  def debug?
    debug = (! [:production, :staging].include?(name))
    debug.to_s.downcase
  end

  def get_binding
    binding
  end

  def proxy_url
    'http://localhost:1338/' if dev?
  end

  private

  def production?
    name == :production
  end

  def dev?
    name == :dev
  end

  def qa?
    name =~ /qa/i
  end

  def merge_environment_specific_config
    environment_file = find_config_file(File.join(EnvironmentLocation,name.to_s,ConfigFileName))
    @source_files <<  environment_file if environment_file
    @basis = @basis.deep_merge(YAML::load_file(environment_file)) if environment_file
  end

  def merge_secrets_files
    logger.debug 'Secrets merge beginning:'
    available_secrets_files = find_secrets_files
    available_secrets_files.each do | secret_file |
      logger.info "merging into configuration.", {secret_file: secret_file}
      @basis = @basis.deep_merge(YAML::load_file(secret_file))
      @source_files <<  secret_file
    end
    if(available_secrets_files.count > 0) then
      logger.info 'Secrets merging complete.'
    else
      logger.info 'No Secrets merged'
    end
  end

  def find_config_file(filename)
    existing = ConfigLocations.map{|l| Pathname.new(File.join(l,filename))}.select{|p| p.exist? }
    fail "Could not determine which config source to merge.  candidates: #{existing}" if(existing.length > 1)
    existing.first
  end

  def find_secrets_files
    secrets_file_location = "#{justeat_root}/secure/#{@feature}/#{SecretsName}"
    logger.debug "searching for secrets file", {target_location: secrets_file_location}
    secrets_file = Dir[secrets_file_location]
    logger.warn "No secrets files found, no secrets will be merged." if secrets_file.count < 1
    secrets_file
  end

end
