# Barometer

[![Build Status](https://travis-ci.org/attack/barometer.png?branch=master)](https://travis-ci.org/attack/barometer)
[![Gem Version](https://badge.fury.io/rb/barometer.png)](http://badge.fury.io/rb/barometer)
[![Code Climate](https://codeclimate.com/github/attack/barometer.png)](https://codeclimate.com/github/attack/barometer)
[![Coverage Status](https://coveralls.io/repos/attack/barometer/badge.png?branch=master)](https://coveralls.io/r/attack/barometer)

A multi API consuming weather forecasting superstar.

Barometer provides a common public API to one or more weather services (APIs)
of your choice.  Weather services can co-exist to retrieve extensive
information, or they can be used in a hierarchical configuration where lower
preferred weather services are only used if previous services are
unavailable.

Barometer handles all conversions of the supplied query, so that the
same query can be used for all (or most) services, even if they don't
support the query directly. See the "[Queries](#queries)" section for more info.

## Key Features

* works with ruby 1.8.7, 1.9.x, 2.0, Rubinius, REE (see
  [Travis CI status](https://travis-ci.org/attack/barometer) to confirm)
* supports 4 weather services, more planned
* the same query can be used with any supported weather service
* provides a powerful data object to hold the weather information
* provides a simple plugin api to allow more weather services to be added
* failover configuration
* multiple services configuration to provide average values

## Usage

You can use barometer right out of the box, as it is configured to use one
register-less (no API key required) international weather service
(wunderground.com).

```ruby
require 'barometer'

barometer = Barometer.new('Paris')
weather = barometer.measure

puts weather.current.temperature
```

*See [detailed usage](#detailed-usage) further down.*

## Dependencies

[![Dependency Status](https://gemnasium.com/attack/barometer.png)](https://gemnasium.com/attack/barometer)

### Api Keys

The '~/.barometer' file can hold all your weather service API keys.

eg. weatherbug.com

```yaml
weather_bug:
  code: YOUR_API_CODE
```

eg. Yahoo! Placemaker

```yaml
yahoo:
  app_id: YOUR_APP_ID
```

## Queries

The query handling is one of the most beneficial and powerful features of
Barometer.  Every weather service accepts a different set of possible
queries, so it usually is the case that the same query can only be used
for a couple weather services.

Barometer will allow the use of all query formats for all services.
It does this by first determining the original query format,
then converting the query to a compatible format for each specific
weather service.

For example, Yahoo! only accepts US Zip Code or Weather.com ID.  With Barometer
you can query Yahoo! with a simple location (ie: Paris) or even an Airport
code (ICAO) and it will return the weather as expected.

### Acceptable Formats

* zipcode
* icao (international airport code)
* coordinates (latitude and longitude)
* postal code
* weather.com ID
* location name (ie address, city, state, landmark, etc.)
* woeid (where on earth id, by Yahoo!)

## Detailed Usage

### Sources

The current available sources are:

* Wunderground.com (:wunderground) [default]
* Yahoo! Weather (:yahoo)
* WeatherBug.com (:weather_bug) [requires key]
* NOAA (:noaa)

### Source Configuration

Barometer can be configured to use multiple weather service APIs (either in
a primary/failover config or in parallel).  Each weather service can also
have its own config.

Weather services in parallel

```ruby
Barometer.config = { 1 => [:yahoo, :wunderground] }
```

Weather services in primary/failover

```ruby
Barometer.config = { 1 => [:yahoo], 2 => :wunderground }
```

Weather services, one with some configuration. In this case we are setting
a weight value, this weight is respected when calculating averages.

```ruby
Barometer.config = { 1 => [{:wunderground => {:weight => 2}}, :yahoo] }
```

Weather services, one with keys.

```ruby
Barometer.config = { 1 => [:yahoo, {:weather_bug => {:keys => {:code => CODE_KEY} }}] }
```

#### Multiple weather API, with hierarchy

```ruby
require 'barometer'

# use yahoo and weather bug, if they both fail, use wunderground
Barometer.config = { 1 => [:yahoo, {:weather_bug => {:keys => {:code => CODE_KEY} }}], 2 => :wunderground }

barometer = Barometer.new('Paris')
weather = barometer.measure

puts weather.current.temperture
```

### Command Line

You can use barometer from the command line. 

```sh
% barometer berlin
```

This will output the weather information for the given query.
See the help for more command line information.

```sh
% barometer -h
```

### Searching

After you have measured the data, Barometer provides several methods to help
you get the data you are after. All examples assume you already have measured
the data as shown in the above examples.

#### By preference (default service)

```ruby
weather.default         # returns measurement for default source
weather.current         # returns current_measurement for default
weather.now             # returns current_measurement for default
weather.forecast        # returns all forecast_measurements for default
weather.today           # returns forecast_measurement for default today
weather.tomorrow        # returns forecast_measurement for default tomorrow

puts weather.now.temperature.c
puts weather.tomorrow.high.c
```

#### By date

```ruby
# note, the date is the date of the locations weather, not the date of the
# user measuring the weather
date = Date.parse('01-01-2009')
weather.for(date)       # returns forecast_measurement for default on date 

puts weather.for(date).high.c
```

#### By time

```ruby
# note, the time is the time of the locations weather, not the time of the
# user measuring the weather
time = Time.parse('13:00 01-01-2009')
weather.for(time)       # returns forecast_measurement for default at time 

puts weather.for(time).low.f
```

### Averages

If you consume more then one weather service, Barometer can provide averages
for the values (currently only for the 'current' values and not the forecasted
values).

```ruby
require 'barometer'

# use yahoo and wunderground
Barometer.config = { 1 => [:yahoo, :wunderground] }

barometer = Barometer.new('90210')
weather = barometer.measure

puts weather.temperture
```

This will calculate the average temperature as given by :yahoo and :wunderground

#### Weights

You can weight the values from a weather service so that the values from that
web service have more influence then other values.  The weights are set in the
config ... see the [config section](#source-configuration)

## Contributions

Thank you to these developers who have contributed. No contribution is too small.

* nofxx (https://github.com/nofxx)
* floere (https://github.com/floere)
* plukevdh (https://github.com/plukevdh)
* gkop (https://github.com/gkop)

## Links

* repo: http://github.com/attack/barometer
* rdoc: http://rdoc.info/projects/attack/barometer
* travis ci: https://travis-ci.org/attack/barometer
* code climate: https://codeclimate.com/github/attack/barometer

## Copyright

Copyright (c) 2009-2013 Mark G. See LICENSE for details.
