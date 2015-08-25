require 'data_kitten'
require 'fakeweb'
require 'linkeddata'
require 'pry'

if ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear!
  FakeWeb.allow_net_connect = %r{^https://coveralls.io}
end

RSpec.configure do |config|

  config.order = "random"

end

def load_fixture(file)
  File.read( File.join( File.dirname(File.realpath(__FILE__)) , "fixtures", file ) )
end
