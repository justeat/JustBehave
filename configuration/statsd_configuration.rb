module StatsDConfiguration
  include FromEnvironment

  def self.included(recipient)
    recipient.extend ClassMethods
    recipient.class_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods
    def statsd_endpoint
      from_environment('statsd_endpoint')
    end

    def statsd_port
      from_environment('statsd_port') { 8125 }
    end
  end

  module ClassMethods
  end
end
