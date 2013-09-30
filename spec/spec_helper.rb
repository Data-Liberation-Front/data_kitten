require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

require 'data_kitten'
require 'fakeweb'
require 'linkeddata'

RSpec.configure do |config|

  config.order = "random"

end
