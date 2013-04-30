module Barometer
  class Base
    attr_reader :query, :weather

    def initialize(query)
      @query = Barometer::Query.new(query)
      @weather = Barometer::Weather.new
    end

    def measure(metric=nil)
      @weather.start_at = Time.now.utc

      level = 1
      until @weather.success?
        if sources = Barometer.config[level]
          _dig(sources, nil, metric)
        else
          raise OutOfSources
        end
        level += 1
      end

      @weather.end_at = Time.now.utc
      @weather
    end

    private

    # iterate through the setup until we have a source name (and possibly
    # a config for that source), then measure with that source
    #
    # this allows for many different config formats, like
    # { 1 => :wunderground }
    # { 1 => [:wunderground]}
    # { 1 => [:wunderground, :yahoo]}
    # { 1 => [:wunderground, {:yahoo => {:weight => 2}}]}
    # { 1 => {:wunderground => {:weight => 2}}}
    # { 1 => [{:wunderground => {:weight => 2}}]}
    #
    def _dig(data, config, metric)
      if data.is_a?(String) || data.is_a?(Symbol)
        _measure(data, config, metric)
      elsif data.is_a?(Array)
        data.each do |datum|
          _dig(datum, nil, metric)
        end
      elsif data.is_a?(Hash)
        data.each do |datum, config|
          _dig(datum, config, metric)
        end
      end
    end

    def _measure(source, config, metric)
      options = { :metric => metric }
      options.merge!(config)

      response = Barometer::WeatherService.measure(source.to_sym, @query, options)
      response.weight = config[:weight] if config && config[:weight]

      @weather.responses << response
    end
  end
end
