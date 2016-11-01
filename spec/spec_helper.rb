$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "resque/change_queue"

ENV['RACK_ENV'] ||= 'test'

def clear_resque
  ns = "resque:change_queue"
  Resque.redis.namespace = ns
  keys = Resque.keys
  keys.each {|k| Resque.redis.del(k)}
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
  config.before(:each) do
    clear_resque
  end

  config.after(:each) do
    clear_resque
  end

end
