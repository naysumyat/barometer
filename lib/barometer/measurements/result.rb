$:.unshift(File.dirname(__FILE__))
require 'utility/data_types'

module Barometer
  #
  # Result Measurement
  # a data class for one period of weather data
  # eg: current measurement, forecasted measurement
  #
  class Measurement::Result
    include Barometer::DataTypes

    temperature :temperature, :dew_point, :heat_index, :wind_chill, :high, :low
    vector :wind
    pressure :pressure
    distance :visibility
    number :pop, :humidity
    string :icon, :condition, :description
    local_datetime :current_at, :updated_at, :starts_at, :ends_at
    sun :sun

    attr_reader :date

    def initialize(metric=true)
      @metric = metric
    end

    def date=(date)
      if date.respond_to?(:to_date)
        @date = date.to_date
      else
        @date = Date.parse(date)
      end
      @starts_at = Data::LocalDateTime.new(@date.year,@date.month,@date.day,0,0,0)
      @ends_at = Data::LocalDateTime.new(@date.year,@date.month,@date.day,23,59,59)
    end

    def for_datetime?(datetime)
      raise ArgumentError unless datetime.is_a?(Data::LocalDateTime)
      datetime >= @starts_at && datetime <= @ends_at
    end
  end
end
