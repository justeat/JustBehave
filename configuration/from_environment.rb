module FromEnvironment
  def self.included(recipient)
    recipient.extend ClassMethods
    recipient.class_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods
    def from_environment(key, &block)
      value = nil
      # we want a depth-first match - this isn't ideal, but it's unlikely that we'll have two apps that want the same key
      glob = "#{justeat_root}/configuration/**/#{key}.config-key.txt"
      logger.debug "globbing", {key: key, glob: glob}
      matches = Dir.glob(glob)
      logger.debug "Matches", {key: key, matches: matches}
      matches.map{|f| Pathname.new f}.sort{|a,b| a.to_s.length <=> b.to_s.length}.reverse.each do |match|
        logger.debug "Looking for #{key} at #{match.to_s}", {key: key, match: match.to_s}
        if match.exist?
          value = match.read.chomp
          break
        end
      end
      if value.nil?
        logger.warn "No configuration exists for #{key}.", {key: key}
        if block_given?
          value = yield
          logger.warn "Could not read default value.", {key: key} if value.nil?
        end
      end
      if value.nil?
        machine = `hostname`
        if machine =~ /je-ba/i
          if key == 'statsd_endpoint'
            return 'monitoring-test.je-labs.com'
          else
            return "dummy value because build agent"
          end
        else
          fail "No configuration. #{{key: key}.to_json}"
        end
      else
        logger.info "Config: #{key} -- '#{value.chomp}'", {key: key, value: value.chomp}
      end
      value.chomp
    end

    private
    def justeat_root
      (ENV['JUSTEAT_ROOT'] || 'c:\\justeat').gsub('\\','/')
    end
  end

  module ClassMethods
  end
end
