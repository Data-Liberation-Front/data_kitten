require 'coveralls'
Coveralls.wear!

require 'data_kitten'
require 'fakeweb'
require 'linkeddata'
require 'pry'

FakeWeb.allow_net_connect = %w{coveralls.io}

RSpec.configure do |config|

  config.order = "random"

end

def load_fixture(file)
  File.read( File.join( File.dirname(File.realpath(__FILE__)) , "fixtures", file ) )
end
