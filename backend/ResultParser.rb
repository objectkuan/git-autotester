class ResultParser
  class << self
    def method_missing(name, *args)
      LOGGER.error "Parser not found #{name}"
      args.first
    end
  end
end