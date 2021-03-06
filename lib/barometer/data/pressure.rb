module Barometer
  module Data
    class Pressure < ConvertableUnits
      # METRIC_UNITS = "mb"
      # IMPERIAL_UNITS = "in"

      def initialize(*args)
        args = super(*args)
        parse_values!(args)
        freeze_all
      end

      def mb; metric; end
      def in; imperial; end

      def units
        metric? ? 'mb' : 'in'
      end

      private

      def convert_imperial_to_metric(imperial_value)
        imperial_value.to_f * 33.8639
      end

      def convert_metric_to_imperial(metric_value)
        metric_value.to_f * 0.02953
      end
    end
  end
end
