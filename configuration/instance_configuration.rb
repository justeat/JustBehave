module InstanceConfiguration
  include FromEnvironment

  def self.included(recipient)
    recipient.extend ClassMethods
    recipient.class_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods
    def instance_id
      from_environment('instance_id')
    end

    def instance_logical_name
      match = instance_position_raw.match(/(\d+){,3}$/i)
      logger.debug match
      match[1]
    end

    def instance_position_raw
      from_environment('instance_position')
    end

    def instance_zone
      instance_zone_raw.slice -1
    end

    def instance_region
      match = instance_zone_raw.match /^(.*)\w$/i
      match[1]
    end

    def instance_zone_raw
      from_environment 'zone_raw'
    end
  end

  module ClassMethods
  end
end
