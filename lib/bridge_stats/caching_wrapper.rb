module BridgeStats
  class CachingWrapper

    attr_reader :delegate, :cache

    def initialize(delegate)
      @delegate = delegate
      @cache = {}
    end

    def method_missing(symbol, *args)
      enclosing_cache = cache
      final_arg = symbol
      cached_result = cache[symbol]
      cached_result = (cache[symbol] = {}) if cached_result.nil?
      args.each do |arg|
        enclosing_cache = cached_result
        final_arg = arg
        cached_result = enclosing_cache[arg]
        cached_result = (enclosing_cache[arg] = {}) if cached_result.nil?
      end
      return cached_result unless cached_result == {}
      return enclosing_cache[final_arg] = delegate.send(symbol, *args) if delegate.respond_to?(symbol)
      super
    end

    def respond_to_missing?(name, include_private = false)
      delegate.respond_to?(name, include_private) || super
    end
  end
end
