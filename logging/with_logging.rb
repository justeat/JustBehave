module WithLogging # todo: rewrite to standard mixin pattern
  def logger
    @logger ||= WithLogging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    include Cabin

    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = Logger.new(STDOUT)
      logger.progname = classname
      channel = Channel.new
      channel.subscribe logger
      channel.level = (ENV['verbosity'] || 'warn').to_sym #todo: get this from recipient constructor
      channel
    end
  end
end
